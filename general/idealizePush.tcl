proc idealizePush {pushFile KName VyName b1Name dcName b2Name VrName} {
	upvar $KName	K
	upvar $VyName	Vy
	upvar $b1Name	b1
	upvar $dcName	dc
	upvar $b2Name	b2
	upvar $VrName	Vr
	
	set file [open $pushFile r]
	set lines [split [read $file] \n]
	close $file
	set v1 [lindex [lindex $lines 0] 0]
	set fac 1
	if {$v1 < 0} {
		set fac -1
	}
	set vList ""
	set dList ""
	set numPnts 0
	foreach line $lines {
		if {$line == ""} continue
		set v [lindex $line 0]
		set d [lindex $line 1]
		lappend vList [expr $fac*$v]
		lappend dList $d
		incr numPnts
	}
	set n -1
	set v1 [lindex $vList 0]
	set d1 [lindex $dList 0]
	set kList ""
	foreach d2 $dList v2 $vList {
		incr n
		if {$n == 0} {
			continue
		}
		set k [expr ($v2-$v1)/($d2-$d1)]
		if {$n == 1} {
			set K $k
		}
		lappend kList $k
		set d1 $d2
		set v1 $v2
	}
	set Vy [interpolate $kList $vList [expr 0.02*$K] n 0]
	set dy [interpolate $kList $dList [expr 0.02*$K] n 0]
	set dy [expr ($dy+2*$Vy/$K)/3.]
	set K [expr $Vy/$dy]
	# set K [expr ($K+$Vy/$dy)/2.]
	# set dy [expr $Vy/$K]
	# puts "kList= $kList"
	# puts "vList= $vList"
	foreach "vMax ind" [findMax $vList] {}
	set dc [lindex $dList [expr $ind-1]]
	set k2 [expr ($vMax-$Vy)/($dc-$dy)]
	set b1 [expr $k2/$K]
	if {$ind < $numPnts} {
		set dLast [lindex $dList [expr $numPnts-1]]
		set vLast [lindex $vList [expr $numPnts-1]]
		if {$vLast < 0} {
			set vList [lrange $vList $ind end]
			set dList [lrange $dList $ind end]
			set dLast [interpolate $vList $dList 0 n 0]
			set vLast 0
		}
		set b2 [expr ($vLast-$vMax)/($dLast-$dc)/$K]
		set Vr $vLast
	} else {
		#default descending branch
		set b2 -0.5
		set Vr 0
	}
	return $fac
}
