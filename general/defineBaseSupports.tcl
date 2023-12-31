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
		#TODO allow column support hinging in presence of isolators
		set x 1
		set y 1
        if [info exists isoltrLabel] {
			#bottom isolator node
			set pos $k,$i,$loc,i
		} elseif {$loc == 1} {
			set xy $fixityFlag($k,$i)
			set x [string index $xy 0]
			set y [string index $xy 1]
		}
		set tag [manageFEData -getNode $pos]
		if {$inputs(numDims) == 2} {
			fix $tag 1 1 $y
		} else {
			fix $tag 1 1 1 $x $y 1
		}
	}
}
