puts "~~~~~~~~~~~~~~~~~~~~~ Defining Masses ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Masses ~~~~~~~~~~~~~~~~~~~~~\n"
set eps 1.e-6
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set mass $diaphMass($j,X)
	if {$inputs(numDims) == 2} {
		set numSlaveNodeList [llength $slaveNodeList($j)]
		set mass [expr $mass/$numSlaveNodeList]
		foreach pos $slaveNodeList($j) {
			set tag [manageFEData -getNode $pos]
			mass $tag $mass $eps $eps
		}
	} else {
		set massRot $diaphMass($j,R)
		set tag  [manageFEData -getNode $masterNode($j)]
		mass $tag $mass $mass $eps $eps $eps $massRot
		#TODO add input options for including vertical mass
	}
}
