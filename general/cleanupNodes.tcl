#remove nodes with no element connections
for {set j 0} {$j <= $inputs(nFlrs)} {incr j} {
	set refNode($j) 0
	set list $slaveNodeList($j)
	set slaveNodeList($j) ""
	foreach node $list {
		set eletags [nodeEleConnects $node]
		if {[llength $eletags] == 0} {
			remove node $node
			continue
		}
		if {$refNode($j) == 0} {
			set refNode($j) $node
			if {$j == 0} {
				set baseNode $node
			}
		}
		lappend slaveNodeList($j) $node
	}
}
