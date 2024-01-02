set n1 [expr $inputs(nBaysX)*($inputs(nBaysY)+1)]
set n2 [expr $inputs(nBaysY)*($inputs(nBaysX)+1)]
set n3 [expr ($inputs(nBaysY)+1)*($inputs(nBaysX)+1)]
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	foreach lName "xBeamSecList yBeamSecList xWallSecList yWallSecList beamLoadListX beamLoadListY xBeamFixityList yBeamReleaseList" n "$n1 $n2 $n1 $n2 $n1 $n2 $n1 $n2" {
		if ![info exists $lName] continue
		set nl [llength [set [set lName]($j)]]
		if {$nl != $n} {
			error "number of elements in $lName-($j) list is $nl but should be $n"
		}
	}
	foreach lName "columnSecList pntLoadList" {
		if ![info exists $lName] continue
		set nl [llength [set [set lName]($j)]]
		if {$nl != $n3} {
			error "number of elements in $lName-($j) list is $nl but should be $n3"
		}
	}

}
foreach lName "xBeamLabels yBeamLabels" n "$n1 $n2" {
	if ![info exists $lName] continue
	set nl [llength [set $lName]]
	if {$nl != $n} {
		error "number of elements in $lName list is $nl but should be $n"
	}
}

foreach lName "gridOffsetListX gridOffsetListY columnLabels baseFixityFlags" {
	if ![info exists $lName] continue
	set nl [llength [set $lName]]
	if {$nl != $n3} {
		error "number of elements in $lName list is $nl but should be $n3"
	}
}

set n1 [llength $diaphMassList]
set n3 [expr $inputs(nFlrs)*2]
if {$n1 < $n3} {
	error "number of elements in diaphMassList($n1) is less than $n3"
}

set n3 [expr $inputs(nBaysX)*$inputs(nBaysY)]
if [info exists slabLoad] {
	for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
		set n1 [llength $slabLoad($j)]
		if {$n1 != $n3} {
			error "number of elements in slabLoad($j) is $n1 but should be $n3"
		}
	}
}
if [info exists deckLoad] {
	for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
		set n1 [llength $deckLoad($j)]
		if {$n1 != $n3} {
			error "number of elements in deckLoad($j) is $n1 but should be $n3"
		}
		if [info exists deckLoadDir] {
			set n1 [llength $deckLoadDir($j)]
			if {$n1 != $n3} {
				error "number of elements in deckLoadDir($j) is $n1 but should be $n3"
			}
		} else {
			error "missing deckLoadDir definition"
		}
	}
}

if [info exists leanLoadList] {
	set n1 [llength $leanLoadList]
	set n3 $inputs(nFlrs)
	if {$n1 != $n3} {
		error "number of elements in leanLoadList($n1) should be $n3"
	}
}