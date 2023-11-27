proc addFiberBeam {eleType elePos eleCode iNode jNode secTagList rho p integStr} {
    global inputs
	set iCrds [nodeCoord $iNode]
	foreach "xi yi zi" $iCrds {}
	set jCrds [nodeCoord $jNode]
	foreach "xj yj zj" $jCrds {}
	set lx [expr ($xj-$xi)]
	set ly [expr ($yj-$yi)]
	set lz [expr ($zj-$zi)]
	set eleL [expr ($lx**2. + $ly**2. + $lz**2.)**0.5]
	if [info exists inputs(numSegBeam)] {
		set nSeg $inputs(numSegBeam)
	} else {
		set nSeg [expr max(int($eleL/$inputs(lSegBeam)),1)]
		set inputs(numSegBeam) $nSeg
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
		set x0 $xi
		set y0 $yi
		set z0 $zi
		for {set iSeg 1} {$iSeg <= $nSeg}  {incr iSeg} {
			set x2 [expr $x0+$dx]
			set y2 [expr $y0+$dy]
			set z2 [expr $z0+$dz]
			set iStat [expr int(ceil(($y2-$yi)/($ly/3.)))]
			set iStat [expr min($iStat,3)]
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
				set x0 [expr $x0+$dx]
				set y0 [expr $y0+$dy]
				set z0 [expr $z0+$dz]
				addNode $node2 $x0 $y0 $z0
			}
			eval "element $eleType [manageTags -newElement "$eleCode,$elePos,$iSeg"] $node1 $node2 $transfTag $integStr -mass $rho"
		}
	}
}