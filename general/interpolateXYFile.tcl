#xList: in ascending order

proc interpolateXYFile {inFile xClmn yClmn inX {ascendX 1} } {
	set file [open $inFile r]
	set lines [split [read $file] \n]
	close $file
	set line [lindex $lines 0]
	set numCols [llength $line]
	set maxCol [expr max($xClmn,$yClmn)]
	incr xClmn -1
	incr yClmn -1
	set fnd 0
	set n -1
	foreach line $lines {
		if {$line == ""} continue
		if {[llength $line] < $maxCol} {
			puts "WARNING! not enough data columns in file: $inFile"
			return ""
		}
		set x [lindex $line $xClmn]
		incr n
		if {$ascendX == 1} {
			if {$inX <= $x} {
				incr fnd
				break
			}
		} else {
			if {$inX >= $x} {
				incr fnd
				break
			}
		}
	}
	if {$fnd < 1} {
		puts "WARNING! interpolateXYFile::the x range does not include inX value: $inX; extrapolating the range"
		incr n -1
	}
	set lin2 [lindex $lines $n]
	if {$n >= 1} {
		set lin1 [lindex $lines [expr $n-1]]
	} else {
        for {set i 0} {$i < $numCols} {incr i} {
            lappend lin1 0
        }
	}
	set y2 [lindex $lin2 $yClmn]
	set y1 [lindex $lin1 $yClmn]
	set x2 [lindex $lin2 $xClmn]
	set x1 [lindex $lin1 $xClmn]
	set dx [expr $x2-$x1]
	if {[expr abs($dx)] < 1e-6} {
		set a 0
	} else {
		set a [expr ($inX-$x1)/$dx]
	}
	set y [expr $y1*(1-$a)+$y2*$a]
	return	"$y $n $a"
}