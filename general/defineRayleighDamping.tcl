puts "~~~~~~~~~~~~~~~~~~~~~ applying rayleigh damping ~~~~~~~~~~~~~~~~~~~~~"
set omegaI [expr sqrt([lindex $omega2List [expr $inputs(modeI)-1]])]
set omegaJ [expr sqrt([lindex $omega2List [expr $inputs(modeJ)-1]])]
set alphaM [expr $inputs(dampRat)*(2.*$omegaI*$omegaJ)/($omegaI+$omegaJ)];	# M-prop. damping; D = alphaM*M
set betaK [expr 2.*$inputs(dampRat)/($omegaI+$omegaJ)];         		# current-K;      +beatKcurr*KCurrent
set dampingNodeList [manageFEData -getDampingNodeList]
set dampingEleList  [manageFEData -getDampingEleList]
eval "region 1 -nodeOnly $dampingNodeList -rayleigh $alphaM 0. 0. 0."
eval "region 2 -eleOnly $dampingEleList -rayleigh 0. 0. 0. $betaK"