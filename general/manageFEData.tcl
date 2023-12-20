proc manageFEData {act args} {
	global nodeTagMap
	global eleTagMap
	global transfTagMap
	global matTagMap
	global secTagMap
	global lastNodeTag
	global lastEleTag
	global lastTransfTag
	global lastMaterialTag
	global lastSecTag
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
		foreach arrName "nodeTagMap eleTagMap transfTagMap matTagMap secTagMap eleAlignedPos nodeCrds zeroOffsetTransf" {
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
		set arg0 [lindex $args 1]

		if {$arg0 == "-setAligned"} {
			set eleCode [lindex $args 2]
			set elePos [lindex $args 3]
			if ![info exists eleAlignedPos($eleCode,$elePos)] {
				set eleAlignedPos($eleCode,$elePos) $pos
			} else {
				lappend eleAlignedPos($eleCode,$elePos) $pos
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
		set eleTagMap($args) [incr lastEleTag]
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
	error "unknown act: $act in manageFEData"
}