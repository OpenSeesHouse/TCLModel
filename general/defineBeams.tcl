#define Beams
puts "~~~~~~~~~~~~~~~~~~~~~ Defining Beams ~~~~~~~~~~~~~~~~~~~~~"
if {$inputs(numDims) == 3} {
	set zAxis(XBeams)		"0. -1. 0."
	set zAxis(YBeams)		"1. 0. 0."
}
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Beams ~~~~~~~~~~~~~~~~~~~~~\n"
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set gravEleWs($j) 0
	logCommands -comment "### story $j\n"
	set sumStrucWeigh([eleCodeMap X-Beam],$j) 0
	set sumStrucWeigh([eleCodeMap Y-Beam],$j) 0
	foreach dir "X Y" nGridX "$inputs(nBaysX) [expr $inputs(nBaysX)+1]" nGridY "[expr $inputs(nBaysY)+1] $inputs(nBaysY)" {
		logCommands -comment "### $dir-dir Beams\n"
		set offsi(X) 0
		set offsi(Y) 0
		set offsi(Z) 0
		set offsj(X) 0
		set offsj(Y) 0
		set offsj(Z) 0
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
				set _hc $pntData([set dir]Dim,$pos)
				set _hc [expr $_hc/2*$inputs(rigidZoneFac)]
				set offsi($dir) $_hc
				set offsj($dir) -$_hc
				set transfTag [manageTags -newGeomtransf "$eleCode,$pos"]
				set cmnd "geomTransf Linear $transfTag"
				if {$inputs(numDims) == 3} {
					foreach str " $zAxis([set dir]Beams) -jntOffset $offsi(X) $offsi(Y) $offsi(Z) $offsj(X) $offsj(Y) $offsj(Z)" {
						lappend cmnd $str
					}
				} else {
					foreach str " -jntOffset $offsi(X) $offsi(Z) $offsj(X) $offsj(Z)" {
						lappend cmnd $str
					}
				}
			    eval $cmnd
				if {$inputs(beamType) == "Hinge"} {
					set id $secIDBeams($j,$k,$i,$dir)
					set kRat 1
					if {$inputs(matType) == "Concrete"} {
						set kRat $kRatBeams($j,$k,$i,$dir)
						if {[info exists inputs(beamCrackOverwrite)] && $inputs(beamCrackOverwrite) != 0} {
							set kRat $inputs(beamCrackOverwrite)
						}
					}
					addHingeBeam $pos $eleCode $iNodePos $jNodePos $sec $id $kRat $release rho
				} else {
					set secI $beamSec($dir,$j,$i,$k,1)
					set secJ $secI
					set secM $secI
					if [info exists beamSec($j,$i,$k,2)] {
						set secM $beamSec($j,$i,$k,2)"
					}
					if [info exists beamSec($j,$i,$k,3)] {
						set secJ $beamSec($j,$i,$k,3)
					}
					set rho 0
					set secTagList ""
					foreach sec "$secI $secM $secJ" {
						source $inputs(secFolder)/$sec.tcl
						source $inputs(secFolder)/convertToM.tcl
						set rho [expr $rho+$Area*$inputs(density)*$inputs(selfWeightMultiplier)]

						if [info exists FRPAttach] {
							set sec $sec-$j
						}
						set secTag $secIDBeams($sec)
						lappend secTagList $secTag
					}
					set rho [expr $rho/3.]
					set p 0
					set eleType $inputs(beamType)
					set integStr $inputs(beamInteg)
					addFiberBeam $eleType $pos $eleCode $iNode $jNode $secTagList $rho $p $integStr
				}
				set eleData(unitSelfWeight,$eleCode,$pos) $rho
				set eleData(length,$eleCode,$pos) $l
				set sumStrucWeigh($eleCode,$j) [expr $sumStrucWeigh($eleCode,$j)+$l*$rho]
			}
		}
	}
}