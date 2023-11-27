proc addNode {tag x y {z NaN} {massArgs ""}} {
	global inputs
	if {$inputs(numDims) == 3} {
		eval "node $tag $x $y $z $massArgs"
	} else {
		if {$massArgs != ""} {
			set massArgs "[lrange $massArgs 0 1] 0 0"
		}
		if {$z eq NaN} {
			set z $y
		}
		eval "node $tag $x $z $massArgs"
	}
}
