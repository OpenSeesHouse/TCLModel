puts "~~~~~~~~~~~~~~~~~~~~~ Defining Diaphragms ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Diaphragms ~~~~~~~~~~~~~~~~~~~~~\n"
for {set j 0} {$j <= $inputs(nFlrs)} {incr j} {
    if {$j == 0 && ![info exists isoltrLabel]} {
		continue
	}
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
		if [info exists leanClmn] {
			lappend slaveNodes $j,98
		}
		if {$j == 0} {
			addRigidPlate $masterNode($j) $slaveNodes
		} else {
			addDiaphragm 3 $masterNode($j) $slaveNodes
		}
	} else {
		set ind [lsearch $slaveNodeList($j) $masterNode($j)]
		set slaveNodes $slaveNodeList($j)
		if {$ind != -1} {
			set slaveNodes [lreplace $slaveNodes $ind $ind]
		}
		if [info exists leanClmn] {
			lappend slaveNodes $j,98
		}
		if {$j == 0} {
			addRigidPlate $masterNode($j) $slaveNodes
		} else {
			addDiaphragm 1 $masterNode($j) $slaveNodes
		}
	}
}
set inputs(roofNode) $masterNode($inputs(nFlrs))
set inputs(baseNode) $masterNode(0)