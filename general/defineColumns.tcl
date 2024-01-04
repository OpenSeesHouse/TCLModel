#define Columns
puts "~~~~~~~~~~~~~~~~~~~~~ Defining Columns ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Columns ~~~~~~~~~~~~~~~~~~~~~\n"
set eleCode [eleCodeMap Column]
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	logCommands -comment "### story $j\n"
	set h [expr $Z($j)-$Z([expr $j-1])]
	set sumStrucWeigh($eleCode,$j) 0
	for {set i 1} {$i <= [expr $inputs(nBaysX)+1]} {incr i} {
		for {set k 1} {$k <= [expr $inputs(nBaysY)+1]} {incr k} {
			set elePos $j,$k,$i
			set sec $eleData(section,$eleCode,$elePos)
			if {$sec == "-"} continue
			set eleData(numSeg,$eleCode,$elePos) 0
			set rho 0
			set j1 [expr $j-1]
			set iNodePos $j1,$k,$i,1
			set jNodePos $elePos,1
			set angle $eleData(angle,$eleCode,$elePos)
			set zAxis ""
			if {$inputs(numDims) == 3} {
				set zAxis $inputs(defZAxis-Column)
				if {$angle > 1e-3} {
					set zAxis [Vector rotateAboutZ $zAxis $angle]
				}
			}
			set sg $eleData(SG,$eleCode,$elePos)
			if {$inputs($sg,eleType) == "Hinge"} {
				set kRat 1
				if {$inputs(matType) == "Concrete"} {
					set kRat $kRatClmns($elePos,$angle)
					if {[info exists inputs(clmnCrackOverwrite)] && $inputs(clmnCrackOverwrite) != 0} {
						set kRat $inputs(clmnCrackOverwrite)
					}
				}
				set matId2 [manageFEData -getMaterial clmnHinge,$elePos,2]
				set matId3 [manageFEData -getMaterial clmnHinge,$elePos,3]
				addHingeColumn $elePos $eleCode $iNodePos $jNodePos $sec $angle $matId2 $matId3 $kRat rho $zAxis eleData(numSeg,$eleCode,$elePos)
			} else {
				set p $columnGravLoad($elePos)
				set eleType $inputs($sg,eleType)
				set integStr $inputs($sg,IntegStr)
				addFiberMember $eleType $elePos $eleCode $iNodePos $jNodePos 1 rho $p $integStr $inputs(clmnGeomtransfType) $zAxis 0 eleData(numSeg,$eleCode,$elePos)
			}
			set eleData(unitSelfWeight,$eleCode,$elePos) $rho
			set eleData(length,$eleCode,$elePos) $h
			set sumStrucWeigh($eleCode,$j) [expr $sumStrucWeigh($eleCode,$j)+$h*$rho]
			manageFEData -setStoryMass $j [expr $h*$rho]
		}
	}
}
