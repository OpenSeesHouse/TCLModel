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
				set rho 0
				set rlsStr $eleData(release,$eleCode,$pos)
				set release [releaseFromChar $rlsStr]
				set iNodePos "$j,$k,$i,1"
				if {$dir == Y} {
					set jNodePos "$j,[expr $k+1],$i,1"
				} else {
					set jNodePos "$j,$k,[expr $i+1],1"
				}
				set zAxis $inputs(def[set dir]BeamZAxis)
				if {$inputs(beamType) == "Hinge"} {
					set id [manageFEData -getMaterial beamHinge,$j,$k,$i,$dir]
					set kRat 1
					if {$inputs(matType) == "Concrete"} {
						set kRat $kRatBeams($j,$k,$i,$dir)
						if {[info exists inputs(beamCrackOverwrite)] && $inputs(beamCrackOverwrite) != 0} {
							set kRat $inputs(beamCrackOverwrite)
						}
					}
					set eleTags [addHingeBeam $pos $eleCode $iNodePos $jNodePos $sec $id $kRat $release rho $zAxis]
				} else {
					set p 0
					set eleType $inputs(beamType)
					set integStr $inputs(beamInteg)
					set eleTags [addFiberMember $eleType $pos $eleCode $iNodePos $jNodePos $inputs(numDesnStats) rho $p $integStr Linear $zAxis $release]
				}
				#TODO use eleTags list for defining internal element resp. recorders
				set eleData(unitSelfWeight,$eleCode,$pos) $rho
				set eleData(length,$eleCode,$pos) $l
				set sumStrucWeigh($eleCode,$j) [expr $sumStrucWeigh($eleCode,$j)+$l*$rho]
			}
		}
	}
}