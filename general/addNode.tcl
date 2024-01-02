proc addNode {pos x y z {args ""}} {
	global inputs
	manageFEData -setNodeCrds $pos $x $y $z
	set cmnd "manageFEData -newNode $pos"
	set i 0
	while {$i < [llength $args]} {
		set arg0 [lindex $args 0]
		if {$arg0 == "-setAligned"} {
			set eleCode [lindex $args 1]
			set elePos [lindex $args 2]
			foreach str "-setAligned $eleCode $elePos" {
				lappend cmnd $str
			}
			incr i 3
		} elseif {$arg0 == "-addToDamping"} {
			incr i 1
			append cmnd " -addToDamping"
		} else {
			error "Unrecognized option: $arg0"
		}
	}
	set tag [eval $cmnd]
	logCommands -comment "#$pos\n"
	if {$inputs(numDims) == 3} {
		node $tag $x $y $z
	} else {
		node $tag $x $z
	}
	return $tag
}
