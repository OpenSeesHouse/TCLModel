proc crossProduct {vec1 vec2} {
	set x1	[lindex $vec1 0] 
	set y1	[lindex $vec1 1] 
	set z1	[lindex $vec1 2] 
	set x2	[lindex $vec2 0] 
	set y2	[lindex $vec2 1] 
	set z2	[lindex $vec2 2]
	set x	[expr $y1*$z2-$z1*$y2]
	set y	[expr $z1*$x2-$x1*$z2]
	set z	[expr $x1*$y2-$y1*$x2]
	return "$x $y $z"
}