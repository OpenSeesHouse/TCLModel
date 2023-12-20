# check to see if inputs(resFolder) = ...$record/$sa exists, if yes,
# check for analysis completeness; set resAvailable to true
# otherwise, set resAvailable to false so that the IDA algorithm performs an analysis for
# this Im

#the ratio of TmaxCheck considered as acceptable as analysis end time
set resAvailable 0
set completeTimeRatio 0.98
#check to see inputs(resFolder) exists
puts -nonewline "------------- Checking result availability: "
if {[file exists $inputs(resFolder)] == 0} {
	puts "result folder does not exist --------"
	return
}

#check to see analysis has been completed
if [catch {open $inputs(resFolder)/envelopeDrifts/CMX1.out r} inFileID] {
	puts "could not open $inputs(resFolder)/envelopeDrifts/CMX1.txt --------"
	return
}
close $inFileID

#check for analsysis completeness:
#assumes globalDriftX.out to be recorded in $inputs(resFolder) with the time column switched on
set analCmpl 1
if [catch {open $inputs(resFolder)/globalDriftX.out r} inFileID] {
	puts "could not open $inputs(resFolder)/globalDriftX.out --------"
	return
}
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

if {$lastTime < [expr $completeTimeRatio*$TmaxCheck]} {
	puts -nonewline "end time= $lastTime, "
	set analCmpl 0
}
#check for vibration cease
set freeVibCmpl 1
if {$inputs(doFreeVibrate) && $lastTime < $inputs(maxFreeVibrTime)} {
	for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
		set dirs X
		if {$inputs(numDims) == 3} {
			set dirs "X Y"
		}
		foreach dir $dirs {
			if [catch {open $inputs(resFolder)/envelopeDrifts/CM$dir$j-amp.out r} file] {
				puts "could not open envelopeDrifts/CM$dir$j-amp.out --------"
				return
			}
			set lines [split [read $file] \n]
			if {$lines == ""} {
				puts "envelopeDrifts/CM$dir$j-amp.out is empty --------"
				return
			}
			close $file
			set l1 [lindex $lines 0]
			set l2 [lindex $lines 1]
			set dmin [lrange $l1 end end]
			set dmax [lrange $l2 end end]
			set amp [expr ($dmax-$dmin)]
			if {$amp > $inputs(freeVibTol)} {
				set freeVibCmpl 0
				puts -nonewline "vibration amp= $amp, "
				break
			}
		}
		if {$freeVibCmpl == 0} break
	}
}

if {$analCmpl && $freeVibCmpl} {
	puts "data available --------"
	set resAvailable 1
	set endTime $lastTime
	set failureFlag 0
	return
}

#not complete:check for collapse
set hasClpsd 0
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set dirs X
	if {$inputs(numDims) == 3} {
		set dirs "X Y"
	}
	foreach dir $dirs {
		set file [open $inputs(resFolder)/envelopeDrifts/CM$dir$j.out r]
		set lines [split [read $file] \n]
		close $file
		set l3 [lindex $lines 2]
		set dmax [lrange $l3 end end]
		if {$dmax > $inputs(colpsDrift)} {
			puts "colpsd at story: $j, data available --------"
			set resAvailable 1
			set endTime $lastTime
			set failureFlag 1
			return
		}
	}
}
puts " not complete --------"
return
