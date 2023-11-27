proc getMax {columnin indexin absolute} {
	upvar $columnin column
	upvar $indexin ind
	set indices [lsort -integer [array names column]]
	set max -1.e32
	set ii 0
	foreach index $indices {
		set val $column($index)
		if {$absolute} {set val [expr abs($val)]}
		if {$val > $max} {
			set max $val
			set ind $index
		}
	}
	return $max
}