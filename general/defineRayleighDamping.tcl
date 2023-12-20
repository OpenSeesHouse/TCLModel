puts "~~~~~~~~~~~~~~~~~~~~~ applying rayleigh damping ~~~~~~~~~~~~~~~~~~~~~"
set omegaI [expr sqrt([lindex $omega2List [expr $inputs(modeI)-1]])]
set omegaJ [expr sqrt([lindex $omega2List [expr $inputs(modeJ)-1]])]
set alphaM [expr $inputs(dampRat)*(2.*$omegaI*$omegaJ)/($omegaI+$omegaJ)];	# M-prop. damping; D = alphaM*M
set betaK [expr 2.*$inputs(dampRat)/($omegaI+$omegaJ)];         		# current-K;      +beatKcurr*KCurrent
rayleigh $alphaM 0 $betaK 0
