puts "~~~~~~~~~~~~~~~~~~~~~ Defining Base Supports ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Base Supports ~~~~~~~~~~~~~~~~~~~~~\n"
set j 0
foreach loc "1 2 3" locName "central X-beam-splice Y-beam-splice" {
	logCommands -comment "# $locName nodes ###\n"
	foreach ki $allkiList {
		foreach "k i" $ki {}
		set pos "$j,$k,$i,$loc"
		if ![manageGeomData -jntExists $pos] {
			continue
		}
		set tag [manageFEData -getNode $pos]
		set x 1
		set y 1
		if {$loc == 1} {
			set xy $fixityFlag($k,$i)
			set x [string index $xy 0]
			set y [string index $xy 1]
		}
		if {$inputs(numDims) == 2} {
			fix $tag 1 1 $y
		} else {
			fix $tag 1 1 1 $x $y 1
		}
	}
}
