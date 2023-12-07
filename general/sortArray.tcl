proc sortArray {inVec1} {
	upvar $inVec1 inVec
	set n [array size inVec]
	for {set iPos 1} {$iPos < $n} {incr iPos} {
		set minVal [lindex $inVec($iPos) 0]
		set minPos $iPos
		for {set j $iPos} {$j <= $n} {incr j} {
			set thisVal [lindex $inVec($j) 0]
			if {$thisVal < $minVal} {
				set minVal $thisVal
				set minPos $j
			}
		}
		set tmp $inVec($iPos)
		set inVec($iPos) $inVec($minPos)
		set inVec($minPos) $tmp
	}
}