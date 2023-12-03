
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
			if {$inputs(numDims) == 2 && $masterNode($j) == 0} {
				set masterNode($j) $tag		;#used in numDim == 2 for leaning column
			}
		}
		if {$loc == 1} {
			set cntrNodes($j) $slaveNodeList($j)
		}
	}
}
