#define Beams
puts "~~~~~~~~~~~~~~~~~~~~~ Defining Beams ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Beams ~~~~~~~~~~~~~~~~~~~~~\n"
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set gravEleWs($j) 0
	logCommands -comment "### story $j\n"
	set sumStrucWeigh([eleCodeMap X-Beam],$j) 0
	set sumStrucWeigh([eleCodeMap Y-Beam],$j) 0
	foreach dir "X Y" nGridX "$inputs(nBaysX) [expr $inputs(nBaysX)+1]" nGridY "[expr $inputs(nBaysY)+1] $inputs(nBaysY)" {
		logCommands -comment "### $dir-dir Beams\n"
		for {set k 1} {$k <= $nGridY} {incr k} {
			for {set i 1} {$i <= $nGridX} {incr i} {
				if {$dir == "X"} {
					set l [lindex $inputs(lBayX) [expr $i-1]]
				} else {
					set l [lindex $inputs(lBayY) [expr $k-1]]
				}
				set pos $j,$k,$i
				set eleCode [eleCodeMap $dir-Beam]
				set sec $eleData(section,$eleCode,$pos,1)
				if {$sec == "-"} {
					continue
				}
				set eleData(numSeg,$eleCode,$pos) 0
				set rho 0
				set fixStr $eleData(fixity,$eleCode,$pos)
				set iNodePos "$j,$k,$i,1"
				if {$dir == Y} {
					set jNodePos "$j,[expr $k+1],$i,1"
				} else {
					set jNodePos "$j,$k,[expr $i+1],1"
				}
				set zAxis $inputs(defZAxis-$dir-Beam)
				set sg $eleData(SG,$eleCode,$pos)
				if {$inputs($sg,eleType) == "Hinge"} {
					set id [manageFEData -getMaterial beamHinge,$j,$k,$i,$dir]
					set kRat 1
					if {$inputs(matType) == "Concrete"} {
						set kRat $kRatBeams($j,$k,$i,$dir)
						if {[info exists inputs(beamCrackOverwrite)] && $inputs(beamCrackOverwrite) != 0} {
							set kRat $inputs(beamCrackOverwrite)
						}
					}
					addHingeBeam $pos $eleCode $iNodePos $jNodePos $sec $id $kRat $fixStr rho $zAxis eleData(numSeg,$eleCode,$pos)
				} else {
					set p 0
					set eleType $inputs($sg,eleType)
					set integStr $inputs($sg,IntegStr)
					addFiberMember $eleType $pos $eleCode $iNodePos $jNodePos $inputs(numDesnStats) rho $p $integStr Linear $zAxis $fixStr eleData(numSeg,$eleCode,$pos)
				}
				set eleData(unitSelfWeight,$eleCode,$pos) $rho
				set eleData(length,$eleCode,$pos) $l
				set sumStrucWeigh($eleCode,$j) [expr $sumStrucWeigh($eleCode,$j)+$l*$rho]
			}
		}
	}
}