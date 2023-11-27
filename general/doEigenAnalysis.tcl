	puts "~~~~~~~~~~~~~~~~~~~~~ Performing Eigen Analysis ~~~~~~~~~~~~~~~~~~~~~"
	logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Performing Eigen Analysis ~~~~~~~~~~~~~~~~~~~~~\n"
	# set inputs(numModes) 5
	# set omega2List [eigen -genBandArpack $inputs(numModes)]
	set omega2List [eigen $inputs(numModes)]
	set omega2 [lindex $omega2List 0]
	set omega_1 [expr sqrt($omega2)]
	set Tperiod [expr 2.*3.1415/$omega_1]
	set i 0
	foreach omega2 $omega2List {
		puts "T[incr i]= [expr 2.*3.1415/sqrt($omega2)]"
	}
