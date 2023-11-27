#########################################################################
#     please keep this notification at the beginning of this file       #
#                                                                       #
#       Code to perform free vibration analysis by avoidance            #
#       of numerical divergence and checking for end of vibration       #
#                                                                       #
#                  Developed by Seyed Alireza Jalali                    #
#        as part of the OpenSees course in civil808 institute           #
#  for more information and any questions about this code,              #
#               Join  "OpenSees SAJ" telegram group:                    #
#            (https://t.me/joinchat/CJlXoECQvxiJXal0PkLfwg)             #
#                     or visit: www.civil808.com                        #
#                                                                       #
#      DISTRIBUTION OF THIS CODE WITHOUT WRITTEN PERMISSION FROM        #
#                THE DEVELOPER IS HEREBY RESTRICTED                     #
#########################################################################
set vibTol 1.e-5
source ../general/getMaxAmp.tcl
set Tmax [expr [getTime]+$freePeriod]
set checkMaxResp 0
set vibrationAmp [getMaxAmp recTagsAmp]
puts "Tmax= $Tmax, vibrationAmp= $vibrationAmp"
while {$vibrationAmp > $vibTol && $Tmax < $maxFreeTime && $failureFlag==0} {
	source ../general/doTimeControlAnalysis.tcl
	set vibrationAmp [getMaxAmp recTagsAmp]
	set Tmax [expr [getTime]+$freePeriod]
	puts "Tmax= $Tmax, vibrationAmp= $vibrationAmp"
}