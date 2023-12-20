	puts "~~~~~~~~~~~~~~~~~~~~~ Performing Eigen Analysis ~~~~~~~~~~~~~~~~~~~~~"
	logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Performing Eigen Analysis ~~~~~~~~~~~~~~~~~~~~~\n"
	# set inputs(numModes) 5
	# set omega2List [eigen -genBandArpack $inputs(numModes)]
	set omega2List [eigen $inputs(numModes)]
	set i 0
	foreach omega2 $omega2List {
		set T[incr i] [expr 2.*3.1415/sqrt($omega2)]
		puts "T$i= [set T$i]"
	}
