puts "~~~~~~~~~~~~~~~~~~~~~ Defining Masses ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Masses ~~~~~~~~~~~~~~~~~~~~~\n"
set eps 1.e-6
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set mass $diaphMass($j,X)
	if {$inputs(numDims) == 2} {
		set numCntrNodes [llength $cntrNodes($j)]
		set mass [expr $mass/$numCntrNodes]
		foreach tag $slaveNodeList($j) {
			mass $tag $mass $eps $eps
		}
	} else {
		set massRot $diaphMass($j,R)
		set tag $masterNode($j)
		mass $tag $mass $mass $eps $eps $eps $massRot
		#TODO add input options for including vertical mass
	}
}
