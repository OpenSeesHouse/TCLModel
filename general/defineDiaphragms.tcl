if {$inputs(numDims) == 3} {
	puts "~~~~~~~~~~~~~~~~~~~~~ Defining Diaphragms ~~~~~~~~~~~~~~~~~~~~~"
	logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Diaphragms ~~~~~~~~~~~~~~~~~~~~~\n"
	for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {

		set CMx $inputs(centerMassX)
		set CMy $inputs(centerMassY)
		if {$j == $inputs(nFlrs)} {
			set CMx $inputs(centerMassXRoof)
			set CMy $inputs(centerMassYRoof)
		}
		set masterNode($j) [addNode "$j,99" $CMx $CMy $Z($j)]
		lappend masterNodeList $masterNode($j)
		
		fix $masterNode($j) 0 0 1 1 1 0
		set slaveNodes $slaveNodeList($j)
		if [info exists leanClmn($j)] {
			lappend slaveNodes [manageFEData -getNode $j,98]
		}
		addDiaphragm 3 $masterNode($j) $slaveNodes
	}
}
if {$inputs(numDims) == 3} {
	set roofNode $masterNode($inputs(nFlrs))
} else {
	set roofNode [lindex $cntrNodes($inputs(nFlrs)) 0]
}
