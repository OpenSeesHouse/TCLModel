proc getMaxAmp {arrName} {
	upvar $arrName theVec
	if {![info exists theVec]} {
		return 0
	}
	set n [array size theVec]
	set resp 0.
	foreach index [array names theVec] {
		set maxVib [recorderValue $theVec($index) 1 1]
		set minVib [recorderValue $theVec($index) 1 2 -reset]
		set val [expr $maxVib-$minVib]
		# puts "val= $val"
		if {$val > $resp} {
			set resp $val
		}
	}
	return $resp
}