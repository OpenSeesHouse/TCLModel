proc addNode {pos x y z {eleCode ""} {elePos ""}} {
	global inputs
	manageFEData -setNodeCrds $pos $x $y $z
	if {$eleCode == ""} {
		set tag [manageFEData -newNode $pos]
	} else {
		set tag [manageFEData -newNode $pos -setAligned $eleCode $elePos]
	}
	logCommands -comment "#$pos\n"
	if {$inputs(numDims) == 3} {
		node $tag $x $y $z
	} else {
		node $tag $x $z
	}
	return $tag
}
