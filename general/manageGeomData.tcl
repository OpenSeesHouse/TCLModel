proc manageGeomData {args} {
	global jntData
	global _allJntPos
	global _allElePos
	global otherJntVrts
	global eleData
	global X
	global Y
	global Z
	global storyJnts

	set memVarNames "jntData _allJntPos eleData X Y Z storyJnts"
	if ![info exists otherJntVrts(pp,n)] {
		set otherJntVrts(pp,h) "pn np"
		set otherJntVrts(pp,v) "np pn"
		set otherJntVrts(pn,h) "pp nn"
		set otherJntVrts(pn,v) "nn pp"
		set otherJntVrts(np,h) "nn pp"
		set otherJntVrts(np,v) "pp nn"
		set otherJntVrts(nn,h) "np pn"
		set otherJntVrts(nn,v) "pn np"
	}
	set arg0 [lindex $args 0]

	if {$arg0 == "-initiate"} {
		#unset member variables if the model has been built in a previous loop iteration
		foreach varName $memVarNames {
			if [info exists $varName] {
				unset $varName
			}
		}
	}
	if {$arg0 == "-makeJntList"} {
		set list [array names jntData]
		set _allJntPos ""
		foreach name $list {
			set pos [string trim [lindex [split $name "dim"] 0] ,]
			if {[lsearch $_allJntPos $pos] != -1} continue
			lappend _allJntPos $pos
		}
		if {$_allJntPos == ""} {
			error "manageGeomData is called before computing the jntData array"
		}
		set list [array names eleData]
		set _allElePos ""
		foreach name $list {
			set pos [string trim [lindex [split $name "dim"] 0] ,]
			if {[lsearch $_allElePos $pos] != -1} continue
			lappend _allElePos $pos
		}
		if {$_allElePos == ""} {
			error "manageGeomData is called before computing the jntData array"
		}
		return
	}
	if {$arg0 == "-jntExists"} {
		set pos [lindex $args 1]
		if ![info exists _allJntPos] {
			error "manageGeomData -makeJntList should be called before other options"
		}
		set ind [lsearch $_allJntPos $pos]
		if {$ind != -1} {
			return 1
		}
		return 0
	}
	if {$arg0 == "-eleExists"} {
		set pos [lindex $args 1]
		set ind [lsearch $_allElePos $pos]
		if {$ind != -1} {
			return 1
		}
		return 0
	}
	if {$arg0 == "-getAllJntPos"} {
		if {$_allJntPos == ""} {
			error "manageGeomData is called before computing the jntData array"
		}
		return $_allJntPos
	}
	if {$arg0 == "-getMatchingJntDim"} {
		set pos [lindex $args 1]
		set dir [lindex $args 2]
		set vrt [lindex $args 3]
		set com [lindex $args 4]
		set otherDir(X) Y
		set otherDir(Y) X
		foreach d "$dir $otherDir($dir)" {
			foreach otherVert $otherJntVrts($vrt,$com) {
				set otherName $pos,dim,$d,$otherVert,$com
				if [info exists jntData($otherName)] {
					# puts "jntData($pos,dim,$dir,$vrt,$com) = jntData($otherName)"
					return $jntData($otherName)
				}
			}
		}
	}
	if {$arg0 == "-getEleAlignedJntPos"} {
		set eleCode [lindex $args 1]
		set elePos [lindex $args 2]
		set locs $eleAlignedLocs($eleCode)
		set res ""
		if [info exists eleInternalNodes($eleCode,$elePos)] {
			set res $eleInternalNodes($eleCode,$elePos)
		}
		foreach loc $locs {
			set pos $_pos,$loc*
			foreach p $_allJntPos {
				if [string match $pos $p] {
					lappend res $p
				}
			}
		}
		return $res
	}
	if {$arg0 == "-getClmnAlignedPos"} {
		set _pos [lindex $args 1]
		set locs $clmnAlignedLocs
		set res ""
		foreach loc $locs {
			set pos $_pos,$loc*
			foreach p $_allJntPos {
				if [string match $pos $p] {
					lappend res $p
				}
			}
		}
		return $res
	}
	if {$arg0 == "-setEleSection"} {
		set code $eleCodeMap([lindex $args 1])
		set pos [lindex $args 2]
		set val [lindex $args 3]
		set eleData($code,$pos,section) $val
		if {[lsearch $_allElePos $code,$pos] == -1} {
			lappend _allElePos $code,$pos
		}
		return
	}
	if {$arg0 == "-setEleConfig"} {
		set code $eleCodeMap([lindex $args 1])
		set pos [lindex $args 2]
		set val [lindex $args 3]
		set eleData($code,$pos,config) $val
		return
	}
	if {$arg0 == "-setBraceGussDim"} {
		set whr [lindex $args 1]
		set code $eleCodeMap([lindex $args 2])
		set pos [lindex $args 3]
		set val [lindex $args 4]
		set eleData($code,$pos,GussDim,$whr) $val
		return
	}

}
