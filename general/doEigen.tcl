	proc inputs(doEigen) {nflrs {printFlag 1}} {
		set inputs(numModes) $inputs(nFlrs)
		set omega2List [eigen -genBandArpack $inputs(numModes)]
		set iMode 1
		set Tout [open periods.txt a]
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
		# }
		close $Tout
		return $Tperiods
	}
