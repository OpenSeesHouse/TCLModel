proc manageJntData {args} {
	global jntData
	global _allJntPos
	global otherVrts
	global otherDir
	if ![info exists otherVrts(pp,n)] {
		set otherVrts(pp,h) "pn np"
		set otherVrts(pp,v) "np pn"
		set otherVrts(pn,h) "pp nn"
		set otherVrts(pn,v) "nn pp"
		set otherVrts(np,h) "nn pp"
		set otherVrts(np,v) "pp nn"
		set otherVrts(nn,h) "np pn"
		set otherVrts(nn,v) "pn np"
		set otherDir(X) Y
		set otherDir(Y) X
	}
	set arg0 [lindex $args 0]
	if {$arg0 == "-makeList"} {
		set list [array names jntData]
		set _allJntPos ""
		foreach name $list {
			set pos [string trim [lindex [split $name "dim"] 0] ,]
			if {[lsearch $_allJntPos $pos] != -1} continue
			lappend _allJntPos $pos
		}
		if {$_allJntPos == ""} {
			error "manageJntData is called before computing the jntData array"
		}
	}
	if {$arg0 == "-exists"} { 
		set pos [lindex $args 1]
		if ![info exists _allJntPos] {
			error "manageJntData -makeList should be called before other options"
		}
		set ind [lsearch $_allJntPos $pos]
		if {$ind != -1} {
			return 1
		}
		return 0
	}
	if {$arg0 == "-getAllPos"} { 
		if {$_allJntPos == ""} {
			error "manageJntData is called before computing the jntData array"
		}
		return $_allJntPos
	}
	if {$arg0 == "-getMatchingDim"} {
		set pos [lindex $args 1]
		set dir [lindex $args 2]
		set vrt [lindex $args 3]
		set com [lindex $args 4]
		foreach d "$dir $otherDir($dir)" {
			foreach otherVert $otherVrts($vrt,$com) {
				set otherName $pos,dim,$d,$otherVert,$com
				if [info exists jntData($otherName)] {
					# puts "jntData($pos,dim,$dir,$vrt,$com) = jntData($otherName)"
					return $jntData($otherName)
				}
			}
		}
	}

}
