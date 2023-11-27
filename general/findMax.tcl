proc findMax {inList} {
	set n 0
	set max -1e20
	foreach val $inList {
		if {$val > $max} {
			set ind $n
			set max $val
		}
		incr n
	}
	return "$max $ind"
}