proc lNorm {list} {
	set res 0.
	foreach val $list {
		set res [expr $res+$val*$val]
	}
	set res [expr $res**0.5]
	return $res
}