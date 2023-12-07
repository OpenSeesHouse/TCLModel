proc addFiberBeam {eleType elePos eleCode iNode jNode nDesStats rhoName p integStr transType zAxis release} {
	global inputs
	global jntData
	global eleData
	global secIDBeams
	global secIDClmns
	upvar $rhoName rho
	set bcType [eleCodeMap -getType $eleCode]
	set mNodes [manageFEData -getEleAlignedJntPos $eleCode $elePos]
	if {$bcType != "Column"} {
		set dir [string index $bcType 0]
	} else {
		set dir Z
	}
	lappend mNodes $jNode
	set iCrds [manageFEData -getNodeCrds $iNode]
	foreach "xi yi zi" $iCrds {}
	set i 0
	foreach mn $mNodes {
		incr i
		set d 0
		foreach x [manageFEData -getNodeCrds $mn] y "$xi $yi $zi" {
			set d [expr $d+($x-$y)**2.]
		}
		set d [expr sqrt($d)]
		set vec($i) "$d $mn"
	}
	set nSeg [expr $i-1]
	set eleL [lindex $vec($i) 0]
	sortArray vec
	set mNodes ""
	set ds ""
	for {set k 1} {$k <= $i} {incr k} {
		lappend ds [lindex $vec($k) 0]
		lappend mNodes [lindex $vec($k) 1]
	}
	set rho 0
	for {set iStat 1} {$iStat <= $inputs(numDesnStats)} {incr iStat} {
		if {$bcType == "Column"} {
			set sec $eleData(section,$eleCode,$elePos)
			set str $sec
			if {[info exists FRPAttach] && $FRPAttach($j,clmn) != ""} {
				set str $sec-$j
			}
			if {$inputs(matType) == "Concrete"} {
				set loc1 [expr $iStat-1]
				set shFac [lindex $clmnShearReinfSFacs $loc1]
				set secTag $secIDClmns($str,$shFac)
			} else {
				set secTag $secIDClmns($sec)
			}
		} else {
			if ![info exists eleData(section,$eleCode,$elePos,$iStat)] {
				continue
			}
			set sec $eleData(section,$eleCode,$elePos,$iStat)
			set str $sec
			if [info exists FRPAttach] {
				set str $sec-$j
			}
			set secTag $secIDBeams($str)
		}
		source $inputs(secFolder)/$sec.tcl
		source $inputs(secFolder)/convertToM.tcl
		set rho [expr $rho+$Area*$inputs(density)*$inputs(selfWeightMultiplier)]

		set secTagArr($iStat) $secTag
	}
	set rho [expr $rho/$inputs(numDesnStats)]

	set zerOffTransTag 0
	if {$nSeg > 1} {
		set zerOffTransTag [addGeomTransf "$eleCode,$elePos,0" $transType $zAxis]
	}
	set integType [lindex $integStr 0]
	set offsVeci(X) 0
	set offsVeci(Y) 0
	set offsVeci(Z) 0
	set offsVecj(X) 0
	set offsVecj(Y) 0
	set offsVecj(Z) 0
	set eleTags ""
	set sumD 0
	set i 0
	if {$bcType == "Column"} {
		set iOfs [expr ($jntData($iNode,dim,X,pp,v) + \
			$jntData($iNode,dim,X,np,v) +	\
			$jntData($iNode,dim,Y,pp,v) + \
			$jntData($iNode,dim,Y,np,v))*0.25*$inputs(rigidZoneFac)]
	} else {
		set iOfs [expr 0.5*($jntData($iNode,dim,$dir,pp,h) + $jntData($iNode,dim,$dir,pn,h))*$inputs(rigidZoneFac)]
	}
	foreach mNode $mNodes d $ds {
		incr i
		set l [expr $d - $sumD]
		set sumD [expr $sumD+$d]
		set iStat [expr int(ceil($d/($eleL/$nDesStats)))]
		set iStat [expr min($iStat,$nDesStats)]
		set secTag $secTagArr($iStat)
		if [string match "HingeRadau*" $integType] {
			if {$eleType != "forceBeamColumn"} {
				error "Expected forceBeamColumn for integType: $integType but got: $eleType"
			}
			if {$inputs(matType) == "Concrete"} {
				set db [expr ($DBarTop+$DBarBot)*0.5]
				set lpI [computeLp $l $H $db $Area $inputs(fc0) $p]
				set lpJ $lpI
				#TODO secTagI? sectagJ secTagM?
			}
		}
		set mOfs 0
		if [manageGeomData -jntExists $mNode] {
			
			if {$bcType == "Column"} {
				set mOfs [expr -($jntData($mNode,dim,X,pn,v) + \
					$jntData($mNode,dim,X,nn,v) +	\
					$jntData($mNode,dim,Y,pn,v) + \
					$jntData($mNode,dim,Y,nn,v))*0.25*$inputs(rigidZoneFac)]
			} else {
				set mOfs [expr -0.5*($jntData($mNode,dim,$dir,np,h) + $jntData($mNode,dim,$dir,nn,h))*$inputs(rigidZoneFac)]
			}
		}
		if {$mOfs < 1e-3 && $iOfs < 1e-3} {
			set transTag $zerOffTransTag
		} else {
			set offsVeci($dir) $iOfs
			set offsVecj($dir) $mOfs
			set transTag [addGeomTransf "$eleCode,$elePos,$i" $transType $zAxis offsVeci offsVecj]
		}
		set eleTag "$eleCode,$elePos,$i"
		set eleArgs "$transTag"
		foreach str $integStr {
			eval "lappend eleArgs $str"
		}
		lappend eleArgs "-mass $rho"
		set eleId [addElement $eleType $eleTag $iNode $mNode $eleArgs]
		lappend eleTags $eleId
		set iOfs 0
		if [manageGeomData -jntExists $mNode] {
			if {$bcType == "Column"} {
				set iOfs [expr ($jntData($mNode,dim,X,pp,v) + \
					$jntData($mNode,dim,X,np,v) +	\
					$jntData($mNode,dim,Y,pp,v) + \
					$jntData($mNode,dim,Y,np,v))*0.25*$inputs(rigidZoneFac)]
			} else {
				set iOfs [expr 0.5*($jntData($mNode,dim,$dir,pp,h) + $jntData($mNode,dim,$dir,pn,h))*$inputs(rigidZoneFac)]
			}
		}
		set iNode $mNode
	}
	return $eleTags
}