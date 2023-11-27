proc gmData {gmFile {outfile ""} {energyTol 0.001}} {
	set input [open $gmFile r]
	for {set i 1} {$i <= 4} {incr i} {
		gets $input line
	}
	set dt [lindex $line 3]
	set npnts [lindex $line 1]
	set npnts [lindex [split $npnts ,] 0]
	# puts "npnts= $npnts"
	set Tmax [expr $npnts*$dt]
	set tStart 0
	set tEnd $Tmax
	if {$energyTol == 0 && $outfile == ""} {
		close $input
	} else {
		set lines [split [read $input] \n]
		close $input
		if {$outfile != ""} {
			set output [open $outfile w]
		}
		set i 0
		set AI(0) 0
		foreach line $lines {
			if {$line == ""} continue
			foreach word $line {
				if {$word == ""} continue
				if {$outfile != ""} {
					puts $output $word
				}
				if {$energyTol == 0} continue
				incr i 
				set valArr($i) $word
				set AI($i) [expr $AI([expr $i-1])+$valArr($i)*$valArr($i)]
			}
		}
		if {$outfile != ""} {
			close $output
		}
		if {$energyTol > 0} {
			set numVals $i
			set AIlast $AI($numVals)
			for {set i 1} {$i <= $numVals} {incr i} {
				if {$AI($i) > [expr (1-$energyTol)*$AIlast]} {
					set tEnd [expr $i*$dt]
					break
				}
				if {$tStart == 0 && $AI($i) > [expr $energyTol*$AIlast]} {
					set tStart [expr $i*$dt]
				}
			}
		}
	}
	return "$dt $Tmax $tStart $tEnd"
}