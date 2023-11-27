#########################################################################
#     please keep this notification at the beginning of this file       #
#                                                                       #
#  Code to extract maximum response recorded within an analysis session #
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

proc getMaxResp {arrName} {
	upvar $arrName theVec
	if {![info exists theVec]} {
		return 0
	}
	set n [array size theVec]
	set resp 0.
	foreach index [array names theVec] {
		set val [recorderValue $theVec($index) 2]
		# puts "val= $val"
		if {$val > $resp} {
			set resp $val
		}
	}
	return $resp
}