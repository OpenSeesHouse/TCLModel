
## location codes
# 1: central node
# 2: x beam splice
# 3: y beam splice
# j,99: center of mass
puts "~~~~~~~~~~~~~~~~~~~~~ Defining Nodes ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Nodes ~~~~~~~~~~~~~~~~~~~~~\n"

set masterNodeList ""
set allkiList ""
for {set i 1} {$i <= [expr $inputs(nBaysX)+1]} {incr i} {
	for {set k 1} {$k <= [expr $inputs(nBaysY)+1]} {incr k} {
		lappend allkiList "$k $i"
	}
}
for {set j 0} {$j <= $inputs(nFlrs)} {incr j} {
	logCommands -comment "### story $j ###\n"
	set masterNode($j) 0
	set slaveNodeList($j) ""
	foreach loc "1 2 3" locName "central X-beam-splice Y-beam-splice" {
		logCommands -comment "# $locName nodes ###\n"
		foreach ki $allkiList {
			foreach "k i" $ki {}
			set pos "$j,$k,$i,$loc"
			if ![manageJntData -exists $pos] {
				continue
			}
			set tag [manageTags -newNode $pos]
			addNode $tag $X($k,$i)	$Y($k,$i)	$Z($j)
			lappend slaveNodeList($j) $tag
			if {$masterNode($j) == 0} {
				set masterNode($j) $tag		;#used in numDim == 2 for leaning column
			}
		}
		if {$loc == 1} {
			set numCntrNodes($j) [llength $slaveNodeList($j)]
		}
	}
}

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
		set masterNode($j) [manageTags -newNode "$j,99"]
		lappend masterNodeList $masterNode($j)
		addNode $masterNode($j) $CMx $CMy $Z($j)
		fix $masterNode($j) 0 0 1 1 1 0
		addDiaphragm 3 $masterNode($j) $slaveNodeList($j)
	}
}

puts "~~~~~~~~~~~~~~~~~~~~~ Defining Masses ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Masses ~~~~~~~~~~~~~~~~~~~~~\n"
set eps 1.e-6
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set mass $diaphMass($j,X)
	if {$inputs(numDims) == 2} {
		set mass [expr $mass/$numCntrNodes($j)]
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

puts "~~~~~~~~~~~~~~~~~~~~~ Defining Base Supports ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Base Supports ~~~~~~~~~~~~~~~~~~~~~\n"
set j 0
foreach tag $slaveNodeList($j) {
	if {$inputs(numDims) == 2} {
		fix $tag 1 1 1
	} else {
		fix $tag 1 1 1 1 1 1
	}
	#TODO add input option for variable base support conditions
}

if {$inputs(numDims) == 3} {
	set roofNode [manageTags -getNode $inputs(nFlrs),99]
} else {
	set roofNode [manageTags -getNode $inputs(nFlrs),1,1,1]
}
