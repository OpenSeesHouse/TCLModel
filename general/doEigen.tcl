set iCal 0
proc doEigen {{printFlag 1}} {
	global inputs
	global iCal
	# set inputs(numModes) $inputs(nFlrs)
	set omega2List [eigen -genBandArpack $inputs(numModes)]
	set iMode 1
	if {$iCal == 0} {
		set Tout [open periods.out w]
		incr iCal
	} else {
		set Tout [open periods.out a]
	}
	set Tperiods ""
	if {$omega2List == ""} {
		return ""
	}
	foreach omega2 $omega2List {
		if {$omega2 < 0} {
			# set stopUpdating($iMode) 1
			set T 0
		} else {
			set T [expr 2.*3.1415/sqrt($omega2)]
		}
		lappend Tperiods $T
		if {$printFlag} {
			puts "T$iMode= $T"
		}
		puts $Tout "$iMode		$T"

		incr iMode
	}
	close $Tout
	return $omega2List
}
