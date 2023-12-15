#remove nodes with no element connections
#currently, only mesh nodes with close coordinates are merged by removing one
for {set j 0} {$j <= $inputs(nFlrs)} {incr j} {
	set list $slaveNodeList($j)
	set slaveNodeList($j) ""
	foreach node $list {
		set tag [manageFEData -getNode $node]
		set eletags [nodeEleConnects $tag]
		if {[llength $eletags] == 0} {
			remove node $tag
			continue
		}
		lappend slaveNodeList($j) $node
	}
}
