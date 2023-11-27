#xList: in ascending order

proc interpolate {xList yList inX {nName ""} {ascendX 1} {allowExtra 0}} {
	if {$nName != ""} {
		upvar $nName n
	}
	set n 0
	set fnd 0
	foreach x $xList {
		incr n
		if {$ascendX == 1} {
			if {$inX <= $x} {
				set fnd 1
				break
			}
		} else {
			if {$inX >= $x} {
				set fnd 1
				break
			}
		}
	}
	if {!$fnd} {
		if {$allowExtra} {
		} else {
			error "interpolate::the x range does not include inX value: $inX; nterpolation aborted"
		}
	}
	set x2 [lindex $xList [expr $n-1]]
	set y2 [lindex $yList [expr $n-1]]
	if {$n >= 2} {
		set x1 [lindex $xList [expr $n-2]]
		set y1 [lindex $yList [expr $n-2]]
	} else {
		set x1 0
		set y1 0
	}
	set m [expr ($y2-$y1)/($x2-$x1)]
	set y [expr $y1+$m*($inX-$x1)]
	return	$y
}