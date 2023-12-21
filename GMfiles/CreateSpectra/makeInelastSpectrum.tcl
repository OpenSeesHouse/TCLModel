# set modelName "SdModel-bilin"
# set TList " 0.100 0.200 0.300 0.400 0.500 0.600 0.700 0.800 0.900 1.000 1.100 1.200 1.300 1.400 1.500 1.600 1.700 1.800 1.900 2.000 2.100 2.200 2.300 2.400 2.500 2.600 2.700 2.800 2.900 3.000 3.100 3.200 3.300 3.400 3.500 3.600 3.700 3.800 3.900 4.000"
# set TList "0.1 0.5 1 2"
# set SF 1.526567
# set SF 1
# set zetaDamp 0.020000
# set targMu 1.000
# set dataFile tempFiles/spec_[set targMu]_1.txt
# set iRec 1
# set dataDir tempFiles/tmp

proc tcl::mathfunc::sign {x} {
	if {$x > 0} {
		return 1
	} elseif {$x < 0} {
		return -1
	} else {
		return 0
	}
}
source ../../general/gmData.tcl
set GMFile "$gmPath/transformed/$iRec.txt"
set inFile "$gmPath/$iRec.AT2"
set list [gmData $inFile]
set dtGM [lindex $list 0]
set Tmax [lindex $list 1]
set logStats 0
if {$logStats == 1} {
	file mkdir tempFiles/logFiles/mu-$targMu-rec-$iRec
	logCommands -file tempFiles/logFiles/mu-$targMu-rec-$iRec/cmnds.tcl
}
set pi [expr 4.*atan(1)]
set mass 1.
set tol 1.e-3
set maxiter 50
foreach T $TList {
	puts "T= $T"
	if {$logStats == 1} {
		set logFile [open tempFiles/logFiles/mu-$targMu-rec-$iRec/$T.txt w]
	}
	set omega [expr 2.*$pi/$T]
	set k [expr $mass*$omega**2]
	source elasticModel.tcl
	set b0 [expr 0.9*$dMax]
	set a0 $b0
	set fb 1.
	set fa 0
	set iter 0
	if {$targMu <= 1} {
		set divider [expr sqrt(2.0)]
	} else {
		set divider [expr sqrt($targMu)]
	}
	while {$fa < $targMu} {
		incr iter
		set a0 [expr $a0/$divider]
		set epsilonY $a0
		source $modelName.tcl
		# puts "$epsilonY $dMax"
		if {$ok != 0} {
			set spec($T) ""
			continue
		}
		set fa [expr $dMax/$a0]
	}
	set f $fa
	if {$logStats == 1} {
		puts $logFile "$iter $a0 $b0 $fa $fb [expr $dMax]\n"
	}
	set ok 0
	set a $a0
	set b $b0
	set numStall 0
	set d1 [expr abs($f-$targMu)/$targMu]
	while {$d1 > $tol && $numStall < 6} {
		set fac [expr ($targMu-$fa)/($fb-$fa)]
		if {$fac > 0.8} {
			set fac 0.8
		} elseif {$fac < 0.2} {
			set fac 0.2
		}
		# set fac 0.5
		set x [expr $a + ($b-$a)*$fac]
		set epsilonY $x
		source $modelName.tcl
		if {$ok != 0} {
			break
		}
		set f [expr $dMax/$x]
		if {$f < $targMu} {
			set b $x
			set fb $f
		} else {
			set a $x
			set fa $f
		}
		set d2 [expr abs($f-$targMu)/$targMu]
		# puts "d2= $d2"
		if {[expr abs($d2-$d1)/$d1 < 0.001]} {
			incr numStall
			# puts "numStall= $numStall"
		} else {
			set numStall 0
		}
		set d1 $d2
		incr iter
		if {$logStats == 1} {
			puts $logFile "$iter $x $f [expr $dMax]"
			flush $logFile
		}
		if {$iter >= $maxiter} {
			break
		}
	}
	if {$ok != 0} {
		set spec($T) ""
		continue
	}
	set spec($T) [expr [set $specVar]]

	if {$logStats == 1} {
		close $logFile
	}
}
set file [open $dataFile w]
foreach T $TList {
	puts $file "$T $spec($T)"
}
close $file