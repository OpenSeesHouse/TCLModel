puts "~~~~~~~~~~~~~~~~~~~~~ Defining Diaphragms ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Diaphragms ~~~~~~~~~~~~~~~~~~~~~\n"
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	if {$inputs(numDims) == 3} {
		set CMx $inputs(centerMassX)
		set CMy $inputs(centerMassY)
		if {$j == $inputs(nFlrs)} {
			set CMx $inputs(centerMassXRoof)
			set CMy $inputs(centerMassYRoof)
		}
		set masterNode($j) "$j,99"
		set tag [addNode "$j,99" $CMx $CMy $Z($j)]

		fix $tag 0 0 1 1 1 0
		set slaveNodes $slaveNodeList($j)
		if [info exists leanClmn($j)] {
			lappend slaveNodes $j,98
		}
		addDiaphragm 3 $masterNode($j) $slaveNodes
	} else {
		set ind [lsearch $slaveNodeList($j) $masterNode($j)]
		set slaveNodes $slaveNodeList($j)
		if {$ind != -1} {
			set slaveNodes [lreplace $slaveNodes $ind $ind]
		}
		if [info exists leanClmn($j)] {
			lappend slaveNodes $j,98
		}
		addDiaphragm 1 $masterNode($j) $slaveNodes
	}
}
set roofNode $masterNode($inputs(nFlrs))
set baseNode $masterNode(0)