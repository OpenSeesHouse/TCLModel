puts "~~~~~~~~~~~~~~~~~~~~~ applying gravity loading ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "~~~~~~~~~~~~~~~~~~~~~ applying gravity loading ~~~~~~~~~~~~~~~~~~~~~\n"
#
pattern Plain 1 Linear {
	for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
		foreach dir "Y X" nGridX "[expr $inputs(nBaysX)+1] $inputs(nBaysX)" nGridY "$inputs(nBaysY) [expr $inputs(nBaysY)+1]" {
			for {set k 1} {$k <= $nGridY} {incr k} {
				for {set i 1} {$i <= $nGridX} {incr i} {
					set elePos $j,$k,$i
					set eleCode [eleCodeMap $dir-Beam]
					set sec $eleData(section,$eleCode,$elePos,1)
					if {$sec == "-"} {
						continue
					}
					set selfW $eleData(unitSelfWeight,$eleCode,$elePos)
					set load [expr -$selfW-$eleData(load,$eleCode,$elePos)]
					set allPos [manageFEData -getAllPos element $eleCode,$elePos]
					foreach pos $allPos {
						if [string match *h* $pos] {
							continue
						}
						set eleTag [manageFEData -getElement $pos]
						eleLoad -ele $eleTag -type -beamUniform $load 0
					}
				}
			}
		}
		#Columns
		for {set i 1} {$i <= [expr $inputs(nBaysX)+1]} {incr i} {
			for {set k 1} {$k <= [expr $inputs(nBaysY)+1]} {incr k} {
				set ndTag [manageFEData -getNode "$j,$k,$i,1"]
				if {[info exists pntLoadList] && $ndTag != 0} {
					if {$inputs(numDims) == 3} {
						load $ndTag 0. 0. -$pointData(load,$j,$k,$i) 0. 0. 0.
					} else {
						load $ndTag 0. -$pointData(load,$j,$k,$i) 0.
					}
				}
				set elePos $j,$k,$i
				set eleCode [eleCodeMap Column]
				if {$eleData(section,$eleCode,$elePos) != "-"} {
					set w $eleData(unitSelfWeight,$eleCode,$elePos)
					set eleTags ""
					set allPos [manageFEData -getAllPos element $eleCode,$elePos]
					foreach pos $allPos {
						if [string match *h* $pos] {
							continue
						}
						set eleTag [manageFEData -getElement $pos]
						if {$inputs(numDims) == 3} {
							eleLoad -ele $eleTag -type -beamUniform 0 0 -$w
						} else {
							eleLoad -ele $eleTag -type -beamUniform 0 -$w
						}
					}
				}
			}
		}
	}
}
wipeAnalysis
constraints Transformation
# constraints Plain
numberer RCM
# system BandGeneral
system UmfPack
test NormDispIncr 1.e-4 100 
# test NormUnbalance 1.e-4 100 2
algorithm Newton
 #integrator LoadControl 0.02
integrator LoadControl 0.1
analysis Static
 #analyze 50
analyze 10
loadConst -time 0
puts "Gravity Done!"
