#########################################################################
#     please keep this notification at the beginning of this file       #
#                                                                       #
#        Code to check for availability of previous analysis data       #
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

# check to see if inputs(resFolder) = ...$record/$sa exists, if yes,
# check for analysis completeness; set resAvailable to true
# otherwise, set resAvailable to false so that the IDA algorithm performs an analysis for
# this Im

#the ratio of TmaxCheck considered as acceptable as analysis end time
set resAvailable 0
set completeTimeRatio 0.8
#check to see inputs(resFolder) exists
puts "Checking availability of previous run data"
if {[file exists $inputs(resFolder)] == 0} {
	# puts "file not exist"
	return
}

#check to see analysis has been completed
if [catch {open $inputs(resFolder)/envelopeDrifts/1.txt r} inFileID] {
	#filde does not exist, return
	# puts "could not open $inputs(resFolder)/envelopeDrifts/1.txt"
	return
}
close $inFileID
#assumes globalDrift.txt to be recorded in $inputs(resFolder) with the time column switched on
if [catch {open $inputs(resFolder)/globalDrift.txt r} inFileID] {
	#filde does not exist, return
	puts "could not open $inputs(resFolder)/globalDrift.txt"
	return
}
# puts "######### previous data AVAILABLE #########"
# set resAvailable 1
# set endTime $TmaxCheck
# set failureFlag 0
# return
set lastTime 0
set lines [split [read $inFileID] \n]
set num [llength $lines]
for {set i  [expr $num -1]} {$i >= 0} {incr i -1} {
	set lastLine [lindex $lines $i]
	if {[llength $lastLine] == 0} {
		continue
	}
	set lastTime [lindex $lastLine 0]
	break
}
close $inFileID

#compare the lastTime with TmaxCheck:
if {$lastTime < [expr $completeTimeRatio*$TmaxCheck]} {
	puts "analysis not complete: $lastTime"
	return
}
puts "######### previous data AVAILABLE #########"
set resAvailable 1
set endTime $TmaxCheck
set failureFlag 0