proc lsum {list {numEle ""}} {
	set sum 0
	set num 1
	foreach val $list {
		if {$numEle != "" && $num > $numEle} break
		set sum [expr $sum+$val]
		incr num
	}
	return $sum
}