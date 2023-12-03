#define Columns
puts "~~~~~~~~~~~~~~~~~~~~~ Defining Columns ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Columns ~~~~~~~~~~~~~~~~~~~~~\n"
set offsi(X) 0
set offsi(Y) 0
set offsi(Z) 0
set offsj(X) 0
set offsj(Y) 0
set offsj(Z) 0
set eleCode [eleCodeMap Column]
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	logCommands -comment "### story $j\n"
	set h [expr $Z($j)-$Z([expr $j-1])]
	set sumStrucWeigh($eleCode,$j) 0
	for {set i 1} {$i <= [expr $inputs(nBaysX)+1]} {incr i} {
		for {set k 1} {$k <= [expr $inputs(nBaysY)+1]} {incr k} {
			set elePos $j,$k,$i
			set sec $eleData(section,$eleCode,$j,$k,$i)
			if {$sec == "-"} continue
			set rho 0
			set j1 [expr $j-1]
			set iNodePos $j1,$k,$i,1
			set jNodePos $j,$k,$i,1
			set offsi(Z) [expr ($jntData($iNodePos,dim,X,pp,v) + \
							    $jntData($iNodePos,dim,X,np,v) +	\
							    $jntData($iNodePos,dim,Y,pp,v) + \
							    $jntData($iNodePos,dim,Y,np,v))*0.25*$inputs(rigidZoneFac)]
			set offsj(Z) [expr -($jntData($jNodePos,dim,X,pn,v) + \
							     $jntData($jNodePos,dim,X,nn,v) +	\
							     $jntData($jNodePos,dim,Y,pn,v) + \
							     $jntData($jNodePos,dim,Y,nn,v))*0.25*$inputs(rigidZoneFac)]
			set transfTag [manageTags -newGeomtransf "$eleCode,$elePos"]
			set angle $eleData(angle,$eleCode,$j,$k,$i)
			set zAxis $inputs(defClmnZAxis)
			if {$angle > 1e-3} {
				set zAxis [Vector rotateAboutZ $zAxis $angle]
			}
			set cmnd "geomTransf PDelta $transfTag"
			if {$inputs(numDims) == 3} {
				foreach str " $zAxis -jntOffset $offsi(X) $offsi(Y) $offsi(Z) $offsj(X) $offsj(Y) $offsj(Z)" {
					lappend cmnd $str
				}
			} else {
				foreach str " -jntOffset $offsi(X) $offsi(Z) $offsj(X) $offsj(Z)" {
					lappend cmnd $str
				}
			}
			eval $cmnd
			if {$inputs(columnType) == "Hinge"} {
				set kRat 1
				if {$inputs(matType) == "Concrete"} {
					set kRat $kRatClmns($j,$k,$i,$angle)
					if {[info exists inputs(clmnCrackOverwrite)] && $inputs(clmnCrackOverwrite) != 0} {
						set kRat $inputs(clmnCrackOverwrite)
					}
				}
				set matId2 $secIDClmns($j,$k,$i,2)
				set matId3 $secIDClmns($j,$k,$i,3)
				addHingeColumn $elePos $eleCode $iNodePos $jNodePos $sec $angle $matId2 $matId3 $kRat rho
			} else {
				set srchStr $sec 
				if {[info exists FRPAttach] && $FRPAttach($j,clmn) != ""} {
					set sec $sec-$j
				}
				if {$inputs(matType) == "Concrete"} {
					set secTagList ""
					foreach loc "1 2 3" {
						set loc1 [expr $loc-1]
						set shFac [lindex $clmnShearReinfSFacs $loc1]
						set secTag $secIDClmns($sec,$shFac)
						lappend secTagList $secTag
					}
				} else {
					set secTagList $secIDClmns($sec)
				}
				source $inputs(secFolder)/$sec.tcl
				source $inputs(secFolder)/convertToM.tcl
				set rho [expr $inputs(selfWeightMultiplier)*$inputs(density)*$Area]
				set integType [lindex $inputs(clmnInteg) 0]
				if [info exists inputs(numSegClmn)] {
					set nSeg $inputs(numSegClmn)
					set lSeg 0
				} else {
					set nSeg 0
					set lSeg $inputs(lSegClmn)
				}
				set p $columnGravLoad($j,$k,$i)
				set eleType $inputs(columnType)
				set integStr $inputs(clmnInteg)
				addFiberBeam $eleType $elePos $eleCode $iNodePos $jNodePos $secTagList nSeg $lSeg 1 $rho $p $integStr
				set inputs(numSegClmn) $nSeg
			}
			set eleData(unitSelfWeight,$eleCode,$elePos) $rho
			set eleData(length,$eleCode,$elePos) $h
			set sumStrucWeigh($eleCode,$j) [expr $sumStrucWeigh($eleCode,$j)+$h*$rho]
		}
	}
}
