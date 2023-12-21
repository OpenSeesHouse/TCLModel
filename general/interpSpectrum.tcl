#procedure for finding sa

proc interpSpectrum {inspec	x} {
	set in [open $inspec r]
	set lines [split [read $in] \n]
	close $in
	set lastLine [lindex $lines [expr [llength $lines] -2]]
	set maxX [lindex  $lastLine 0]
	set x1 0
	set y1 0
	foreach line $lines {
		if {$line == ""} continue
		foreach "x2 y2" $line {}
		if {$x <= $x2 || $x2 == $maxX} {
			break
		}
		set x1 $x2
		set y1 $y2
	}
	return [expr $y1+($y2-$y1)/($x2-$x1)*($x-$x1)]
}