proc addNode {pos x y z {eleCode ""} {elePos ""}} {
	global inputs
	manageFEData -setNodeCrds $pos $x $y $z
	# set args [list $pos]
	# if {$addArgs != ""} {
	# 	foreach arg $addArgs {
	# 		lappend args $arg
	# 	}
	# 	# set args [lindex $args 0]
	# 	puts "args= $args"
	# }
	if {$eleCode == ""} {
		set tag [manageFEData -newNode $pos]
	} else {
		set tag [manageFEData -newNode $pos -setAligned $eleCode $elePos]
	}
	if {$inputs(numDims) == 3} {
		node $tag $x $y $z
	} else {
		node $tag $x $z
	}
	return $tag
}
