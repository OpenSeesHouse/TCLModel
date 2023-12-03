proc Vector {args} {
	set arg0 [lindex $args 0]
	if {$arg0 == "crossProduct"} {
		set vec1 [lindex $args 1]
		set vec2 [lindex $args 2]
		foreach "x1 y1 z1" $vec1 {}
		foreach "x2 y2 z2" $vec2 {}
		set x	[expr $y1*$z2-$z1*$y2]
		set y	[expr $z1*$x2-$x1*$z2]
		set z	[expr $x1*$y2-$y1*$x2]
		return "$x $y $z"
	}
	if {$arg0 == "rotateAboutZ"} {
		set vec [lindex $args 1]
		set ang [lindex $args 2]
		set ang [expr $ang/180.*3.1415]
		set c [expr cos($ang)]
		set s [expr sin($ang)]
		foreach "x y z" $vec {}
		set xx [expr $x*$c-$y*$s]
		set yy [expr $x*$s+$y*$c]
		return "$xx $yy $z"
	}
}