proc addFiberMember {eleType elePos eleCode iNode jNode nDesStats rhoName p integStr transType zAxis fixStr nSegName} {
	global inputs
	global jntData
	global eleData
	global secIDBeams
	global secIDClmns
	upvar $rhoName rho
	upvar $nSegName nSeg
	set bcCodeType [eleCodeMap -getType $eleCode]
	set mNodes [manageFEData -getEleAlignedJntPos $eleCode $elePos]
	if {$bcCodeType != "Column"} {
		set dir [string index $bcCodeType 0]
		set bcType [string range $bcCodeType 2 end]
	} else {
		set bcType Column
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
	set nSeg $i
	set eleL [lindex $vec($i) 0]
	sortArray vec
	set mNodes ""
	set ds ""
	set d1 0
	set pos1 $iNode
	for {set k 1} {$k <= $i} {incr k} {
		set d2 [lindex $vec($k) 0]
		set pos2 [lindex $vec($k) 1]
		if {[expr abs($d2-$d1)] < [manageFEData -getNodeMergeTol]} {
			manageFEData -mergeNode $pos1 $pos2
			puts "manageFEData -mergeNode $pos1 $pos2"
		} else {
			lappend ds $d2
			lappend mNodes $pos2
		}
		set d1 $d2
		set pos1 $pos2
	}
	set rho 0
	for {set iStat 1} {$iStat <= $inputs(numDesnStats)} {incr iStat} {
		if {$bcType == "Column"} {
			set sec $eleData(section,$eleCode,$elePos)
			set str $sec
			if {$inputs(matType) == "Concrete"} {
				if {[info exists FRPAttach] && $FRPAttach($j,clmn) != ""} {
					set str $sec-$j
				}
				set loc1 [expr $iStat-1]
				set shFac [lindex $clmnShearReinfSFacs $loc1]
				set secTag [manageFEData -getSection clmn,$str,$shFac)
			} else {
				set secTag [manageFEData -getSection clmn,$sec]
			}
		} elseif {$bcType == "Beam"} {
			if ![info exists eleData(section,$eleCode,$elePos,$iStat)] {
				continue
			}
			set sec $eleData(section,$eleCode,$elePos,$iStat)
			set str $sec
			if [info exists FRPAttach] {
				set str $sec-$j
			}
			set secTag [manageFEData -getSection beam,$str]
		} else {
			set sec $eleData(section,$eleCode,$elePos)
			set secTag [manageFEData -getSection brace,$elePos]
		}
		source $inputs(secFolder)/$sec.tcl
		source $inputs(secFolder)/convertToM.tcl
		set rho [expr $rho+$Area*$inputs(density)*$inputs(selfWeightMultiplier)]

		set secTagArr($iStat) $secTag
	}
	set rho [expr $rho/$inputs(numDesnStats)]

	set zerOffTransTag 0
	if {$nSeg > 1} {
		set zerOffTransTag [addGeomTransf -getZeroOffsetTransf "$transType $bcCodeType"]
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
	set iOfs 0
	set i 0
	if {$bcType == "Column"} {
		set iOfs [expr ($jntData($iNode,dim,X,pp,v) + \
			$jntData($iNode,dim,X,np,v) +	\
			$jntData($iNode,dim,Y,pp,v) + \
			$jntData($iNode,dim,Y,np,v))*0.25*$inputs(rigidZoneFac)]
	} elseif {$bcType == "Beam"} {
		set iOfs [expr 0.5*($jntData($iNode,dim,$dir,pp,h) + $jntData($iNode,dim,$dir,pn,h))*$inputs(rigidZoneFac)]
		set fixI [string range $fixStr 0 0]
		set fixJ [string range $fixStr 1 1]
		set rigidMatTag [manageFEData -getMaterial rigid]
		if {!$fixI} {
			set iiNode "$eleCode,$elePos,h1"
			eval "addNode $iiNode $iCrds"
			set tag1 "$eleCode,$elePos,h1"
			if {$inputs(numDims) == 3} {
				set id1 [addElement zeroLength $tag1 $iNode $iiNode \
					"-mat $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag \
					-dir 1 2 3 4 5 -orient $xV $yV"]
			} else {
				set id1 [addElement zeroLength $tag1 $iNode $iiNode \
					"-mat $rigidMatTag $rigidMatTag -dir 1 2"]
			}
			set iNode $iiNode
		}
		if {!$fixJ} {
			set jjNode "$eleCode,$elePos,h2"
			set jCrds [manageFEData -getNodeCrds $jNode]
			eval "addNode $jjNode $jCrds"
			set tag1 "$eleCode,$elePos,h2"
			if {$inputs(numDims) == 3} {
				set id1 [addElement zeroLength $tag1 $jjNode $jNode \
					"-mat $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag \
					-dir 1 2 3 4 5 -orient $xV $yV"]
			} else {
				set id1 [addElement zeroLength $tag1 $jjNode $jNode \
					"-mat $rigidMatTag $rigidMatTag -dir 1 2"]
			}
			set mNodes [lreplace $mNodes end end $jjNode]
		}
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
			} elseif {$bcType == "Beam"} {
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
		set eleId [addElement $eleType $eleTag $iNode $mNode $eleArgs -addToDamping]
		lappend eleTags $eleId
		set iOfs 0
		if [manageGeomData -jntExists $mNode] {
			if {$bcType == "Column"} {
				set iOfs [expr ($jntData($mNode,dim,X,pp,v) + \
					$jntData($mNode,dim,X,np,v) +	\
					$jntData($mNode,dim,Y,pp,v) + \
					$jntData($mNode,dim,Y,np,v))*0.25*$inputs(rigidZoneFac)]
			} elseif {$bcType == "Beam"} {
				set iOfs [expr 0.5*($jntData($mNode,dim,$dir,pp,h) + $jntData($mNode,dim,$dir,pn,h))*$inputs(rigidZoneFac)]
			}
		}
		set iNode $mNode
	}
	return $eleTags
}