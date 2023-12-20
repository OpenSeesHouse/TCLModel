source $inputs(generalFolder)/getMaxAmp.tcl
set inputs(checkMaxResp) 1
set vibrationAmp [getMaxAmp recTagsAmp]
puts "-------- vibrationAmp= $vibrationAmp, failureFlag= $failureFlag--------"
while {$vibrationAmp > $inputs(freeVibTol) && $Tmax < $inputs(maxFreeVibrTime) && $failureFlag==0} {
	set Tmax [expr [getTime]+$freeVibrPeriod]
	source $inputs(generalFolder)/doTimeControlAnalysis.tcl
	set vibrationAmp [getMaxAmp recTagsAmp]
	puts "-------- vibrationAmp= $vibrationAmp, failureFlag= $failureFlag--------"
}