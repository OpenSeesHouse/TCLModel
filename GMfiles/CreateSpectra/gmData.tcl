#########################################################################


proc gmData {gmFile outFile dtNew truncate} {
	set iVal 0
	set pga 0
	set input [open $gmFile r]
	set output 0
	if {$outFile != "null" && $outFile != ""} {
		set output [open $outFile w]
	}
	set lineList [split [read $input] \n]
	set n 0
	# set tmpOut [open tmp.txt w]
	foreach line $lineList {
		incr n
		if {$n == 4} {
			set dt [lindex $line 3]
			set npnts [lindex $line 1]
			set npnts [lindex [split $npnts ,] 0]
			# puts "npnts= $npnts"
			set Tmax [expr $npnts*$dt]
		}
		if {$n > 4} {
			foreach word $line {
				if {$output != 0 && $truncate == 0 && $dtNew == 0} {
					puts $output $word
				}
				set valArr([incr iVal]) $word
				set val [expr abs($word)]
				if {$val > $pga} {
					set pga $val
				}
			}
		}
	}
	set tStart 0
	set tEnd $Tmax
	if {$truncate} {
		set AI(0) 0
		set tStart 0
		set tEnd 0
		for {set i 1} {$i <= $iVal} {incr i} {
			set AI($i) [expr $AI([expr $i-1])+$valArr($i)*$valArr($i)]
		}
		set AIlast $AI($iVal)
		for {set i 1} {$i <= $iVal} {incr i} {
			if {$AI($i) > [expr 0.99*$AIlast]} {
				set tEnd [expr $i*$dt]
				break
			}
			if {$tStart == 0 && $AI($i) > [expr 0.01*$AIlast]} {
				set tStart [expr $i*$dt]
			}
		}
		set Tmax [expr $tEnd-$tStart]
	}
	if {$output != 0 && $truncate == 0 && $dtNew == 0} {
		close $output
	} else {
		if {$dtNew == 0} {
			set dtNew $dt
		}
		if {$output != 0} {
			set j 1
			set t1 0
			set t2 $dt
			set valArr(0) 0
			for {set i 1} {$i <= [expr int($Tmax/$dtNew)+1]} {incr i} {
				set t [expr $tStart +($i-1)*$dtNew]
				while {$t > $t2 && $j < $iVal} {
					incr j
					set t2 [expr ($j)*$dt]
				}
				set t1 [expr $t2-$dt]
				set val1 $valArr([expr $j-1])
				set val2 $valArr($j)
				set val [expr $val1+($val2-$val1)*($t2-$t1)*($t-$t1)]
				puts $output $val
			}
			close $output
		}
		set dt $dtNew
	}
	# close $tmpOut
	return "$dt $Tmax $pga $tStart $tEnd"
}