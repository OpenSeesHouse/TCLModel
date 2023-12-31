proc manageFEData {act args} {
	global nodeTagMap
	global eleTagMap
	global transfTagMap
	global matTagMap
	global secTagMap
	global fricModelTagMap
	global dampingEleList
	global dampingNodeList
	global dampingEleList
	global dampingNodeList
	global storyMassMap
	global lastNodeTag
	global lastEleTag
	global lastTransfTag
	global lastMaterialTag
	global lastSecTag
	global lastFricModelTag
	global eleAlignedPos
	global nodeCrds
	global nodeMergeTol
	global zeroOffsetTransf
	if {$act == "-initiate"} {
		set lastNodeTag 0
		set lastEleTag 0
		set lastTransfTag 0
		set lastMaterialTag 0
		set lastSecTag 0
		set nodeMergeTol 0.01  ;#in units of m
		foreach arrName "nodeTagMap eleTagMap transfTagMap matTagMap secTagMap eleAlignedPos nodeCrds zeroOffsetTransf dampingEleList dampingNodeList storyMassMap" {
			if [info exists $arrName] {
				unset $arrName
			}
		}
		# set beamAlignedLocs(X) "2 BX_"
		# set beamAlignedLocs(Y) "3 BY_"
		# set clmnAlignedLocs "C_"
		return
	}
	if {$act == "-newNode"} {
		set pos [lindex $args 0]
		if [info exists nodeTagMap($pos)] {
			error "node with tag: $pos already defined in map"
		}
		set nodeTagMap($pos) [incr lastNodeTag]
		set args [lrange $args 1 end]
		set i 0
		while {$i < [llength $args]} {
			set arg0 [lindex $args $i]
			if {$arg0 == "-setAligned"} {
				set eleCode [lindex $args [expr $i+1]]
				set elePos [lindex $args [expr $i+2]]
				lappend eleAlignedPos($eleCode,$elePos) $pos
				incr i 3
			} elseif {$arg0 == "-addToDamping"} {
				incr i
				lappend dampingNodeList $lastNodeTag
			} else {
				error "unrecognized arg: $arg0"
			}


		}
		return $lastNodeTag
	}
	if {$act == "-getNode"} {
		if [info exists nodeTagMap($args)] {
			return $nodeTagMap($args)
		}
		return 0
	}
	if {$act == "-newElement"} {
		if [info exists eleTagMap($args)] {
			error "element with tag: $args already defined in map"
		}
		set pos [lindex $args 0]
		set eleTagMap($pos) [incr lastEleTag]
		if {[lindex $args 1] == "-addToDamping"} {
			lappend dampingEleList $lastEleTag
		}
		set pos [lindex $args 0]
		set eleTagMap($pos) [incr lastEleTag]
		if {[lindex $args 1] == "-addToDamping"} {
			lappend dampingEleList $lastEleTag
		}
		return $lastEleTag
	}
	if {$act == "-getElement"} {
		if [info exists eleTagMap($args)] {
			return $eleTagMap($args)
		}
		return 0
	}
	if {$act == "-newGeomtransf"} {
		if [info exists transfTagMap($args)] {
			error "geomTransf with tag: $args already defined in map"
		}
		set transfTagMap($args) [incr lastTransfTag]
		return $lastTransfTag
	}
	if {$act == "-getGeomtransf"} {
		if [info exists transfTagMap($args)] {
			return $transfTagMap($args)
		}
		return 0
	}
	if {$act == "-newMaterial"} {
		if [info exists matTagMap($args)] {
			error "material with tag: $args already defined in map"
		}
		set matTagMap($args) [incr lastMaterialTag]
		return $lastMaterialTag
	}
	if {$act == "-setMaterial"} {
		foreach "pos val" $args {}
		if [info exists matTagMap($pos)] {
			error "material with tag: $pos already defined in map"
		}
		set matTagMap($pos) $val
		return
	}
	if {$act == "-getMaterial"} {
		if [info exists matTagMap($args)] {
			return $matTagMap($args)
		}
		return 0
	}
	if {$act == "-newSection"} {
		if [info exists secTagMap($args)] {
			error "section with tag: $args already defined in map"
		}
		set secTagMap($args) [incr lastSecTag]
		return $lastSecTag
	}
	if {$act == "-getSection"} {
		if [info exists secTagMap($args)] {
			return $secTagMap($args)
		}
		return 0
	}
	if {$act == "-newFrictionModel"} {
		if [info exists fricModelTagMap($args)] {
			error "section with tag: $args already defined in map"
		}
		set fricModelTagMap($args) [incr lastFricModelTag]
		return $lastFricModelTag
	}
	if {$act == "-getFrictionModel"} {
		if [info exists fricModelTagMap($args)] {
			return $fricModelTagMap($args)
		}
		return 0
	}
	if {$act == "-getAllPos"} {
		set arg0 [lindex $args 0]
		set arg1 [lindex $args 1]
		if {$arg0 == "node"} {
			return [lsort [array names nodeTagMap]]
		} elseif {$arg0 == "element"} {
			if {$arg1 == ""} {
				return [lsort [array names eleTagMap]]
			}
			set res ""
			foreach pos [array names eleTagMap] {
				if [string match $arg1* $pos] {
					lappend res $pos
				}
			}
			return $res
		}
		error "geomTransf with tag: $args not found in map"
	}
	if {$act == "-getEleAlignedJntPos"} {
		set eleCode [lindex $args 0]
		set elePos [lindex $args 1]
		if [info exists eleAlignedPos($eleCode,$elePos)] {
			return $eleAlignedPos($eleCode,$elePos)
		}
		return ""
	}
	if {$act == "-setNodeCrds"} {
		set pos [lindex $args 0]
		set x [lindex $args 1]
		set y [lindex $args 2]
		set z [lindex $args 3]
		set nodeCrds($pos,x) $x
		set nodeCrds($pos,y) $y
		set nodeCrds($pos,z) $z
		return
	}
	if {$act == "-getNodeCrds"} {
		set pos [lindex $args 0]
		if [info exists nodeCrds($pos,x)] {
			return "$nodeCrds($pos,x) $nodeCrds($pos,y) $nodeCrds($pos,z)"
		}
		error "nodeCrds not found for pos: $pos"
	}
	if {$act == "-getNodeMergeTol"} {
		return $nodeMergeTol
	}
	if {$act == "-mergeNode"} {
		set pos1 [lindex $args 0]; #retained node
		set pos2 [lindex $args 1]; #removed node
		set nodeTagMap($pos2) [$nodeTagMap($pos1)]
		puts "$pos2 merged with $pos1"
		return
	}
	if {$act == "-getDampingEleList"} {
		return $dampingEleList
	}
	if {$act == "-getDampingNodeList"} {
		return $dampingNodeList
	}
	if {$act == "-setStoryMass"} {
		set j [lindex $args 0]; #retained node
		set m [lindex $args 1]; #removed node
		if ![info exists storyMassMap($j)] {
			set storyMassMap($j) $m
		} else {
			set storyMassMap($j) [expr $storyMassMap($j) + $m]
		}
		return
	}
	if {$act == "-getStoryMass"} {
		set j [lindex $args 0]; #retained node
		if ![info exists storyMassMap($j)] {
			return 0
		}
		return $storyMassMap($j)
	}
	error "unknown act: $act in manageFEData"
}