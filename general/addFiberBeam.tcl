proc addFiberBeam {eleType elePos eleCode iNodePos jNodePos secTagList nSegName lSeg nDesStats rho p integStr} {
    global inputs
	upvar $nSegName nSeg
    set iNode [manageTags -getNode $iNodePos]
    set jNode [manageTags -getNode $jNodePos]
	set iCrds [nodeCoord $iNode]
	foreach "xi yi zi" $iCrds {}
	set jCrds [nodeCoord $jNode]
	foreach "xj yj zj" $jCrds {}
	set lx [expr ($xj-$xi)]
	set ly [expr ($yj-$yi)]
	set lz 0
	set zi 0
	if {$inputs(numDims) == 3} {
		set lz [expr ($zj-$zi)]
	}
	set eleL [expr ($lx**2. + $ly**2. + $lz**2.)**0.5]
	if {$nSeg == 0} {
		set nSeg [expr max(int($eleL/$lSeg),1)]
	}
	set transfTag [manageTags -getGeomtransf "$eleCode,$elePos"]
	set integType [lindex $integStr 0]
	set eleTags ""
	if [string match "HingeRadau*" $integType] {
		if {$nSeg > 1} {
			error "Expected numSeg == 1 for integType: $integType but got: $nSeg"
		}
		if {$eleType != "forceBeamColumn"} {
			error "Expected forceBeamColumn for integType: $integType but got: $eleType"
		}
		set db [expr ($DBarTop+$DBarBot)*0.5]
		set lpI [computeLp $eleL $H $db $Area $inputs(fc0) $p]
		set lpJ $lpI
		set eleTag [manageTags -newElement "$eleCode,$elePos,1"]
		foreach "secTagI secTagM secTagJ" $secTagList {}
		eval "element $eleType $eleTag $iNode $jNode $transfTag $integStr -mass $rho"
		lappend eleTags $eleTag
	} else {
		set dx [expr $lx/$nSeg]
		set dy [expr $ly/$nSeg]
		set dz [expr $lz/$nSeg]
		set dl [expr ($dx**2. + $dy**2. + $dz**2.)**0.5]
		set x $xi
		set y $yi
		set z $zi
		set l 0
		for {set iSeg 1} {$iSeg <= $nSeg}  {incr iSeg} {
			set x [expr $x+$dx]
			set y [expr $y+$dy]
			set z [expr $z+$dz]
			set l [expr $l+$dl]
			set iStat [expr int(ceil($l/($eleL/$nDesStats)))]
			set iStat [expr min($iStat,$nDesStats)]
			incr iStat -1
			set secTag [lindex $secTagList $iStat]
			set node1 $iNode
			set iSeg_1 [expr $iSeg-1]
			if {$iSeg != 1} {
				set node1 [manageTags -getNode "$j,$k,$i,$iSeg_1"]
			}
			set node2 $jNode
			if {$iSeg != $nSeg} {
				set node2 [manageTags -newNode "$j,$k,$i,$iSeg"]
				addNode $node2 $x $y $z
			}
			eval "element $eleType [manageTags -newElement "$eleCode,$elePos,$iSeg"] $node1 $node2 $transfTag $integStr -mass $rho"
		}
	}
}