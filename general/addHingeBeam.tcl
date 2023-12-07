proc addHingeBeam {elePos eleCode iNode jNode sec springMatId kRat release rhoName zV} {
    global inputs
    upvar $rhoName rho
	global jntData
    set rigidMatTag [manageFEData -getMaterial rigid]
	source $inputs(secFolder)/$sec.tcl
	source $inputs(secFolder)/convertToM.tcl
	set rho [expr $inputs(selfWeightMultiplier)*$Area*$inputs(density)]
    set I33 [expr $kRat*$I33*($inputs(nFactor)+1)/$inputs(nFactor)]
	set dir [string index [eleCodeMap -getType $eleCode] 0]
	set mNodes [manageFEData -getEleAlignedJntPos $eleCode $elePos]
    set iiNode $iNode
    set jjNode $jNode
	set eleTag "$eleCode,$elePos"
    if {$inputs(numDims) == 3} {
        set yV "0. 0. 1."
        set xV [Vector crossProduct $yV $zV]
    }
    set tag1 0
    set tag2 0
    if {$release != 3 && $release != 1} {
        set iiNode "$eleCode,$elePos,h1"
        eval "addNode $iiNode [manageFEData -getNodeCrds $iNode]"
        set tag1 "$eleCode,$elePos,h1"
        if {$inputs(numDims) == 3} {
            set id1 [addElement zeroLength $tag1 $iNode $iiNode \
                "-mat $springMatId $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag \
                -dir 6 1 2 3 4 5 -orient $xV $yV"]
        } else {
            set id1 [addElement zeroLength $tag1 $iNode $iiNode \
                "-mat $springMatId $rigidMatTag $rigidMatTag -dir 3 1 2"]
        }
    }
    if {$release != 3 && $release != 2} {
        set jjNode "$eleCode,$elePos,h2"
        eval "addNode $jjNode [manageFEData -getNodeCrds $jNode]"
        set tag2 "$eleCode,$elePos,h2"
        if {$inputs(numDims) == 3} {
            set id2 [addElement zeroLength $tag2 $jjNode $jNode \
                "-mat $springMatId $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag \
                -dir 6 1 2 3 4 5 -orient $xV $yV"]
        } else {
            set id2 [addElement zeroLength $tag2 $jjNode $jNode \
                "-mat $springMatId $rigidMatTag $rigidMatTag -dir 3 1 2"]
        }
    }
    lappend mNodes $jjNode
	foreach "xi yi zi" [manageFEData -getNodeCrds $iNode] {}
	set i 0
	foreach mn $mNodes {
		incr i
		set d 0
		foreach x [manageFEData -getNodeCrds $mn] y "$xi $yi $zi" {
			set d [expr $d+($x-$y)**2.]
		}
		set d [expr sqrt($d)]
		set vec($i) "$d $mn"
	}
	set nMidNodes $i
	sortArray vec
	set mNodes ""
	set ds ""
	for {set k 1} {$k <= $i} {incr k} {
		lappend ds [lindex $vec($k) 0]
		lappend mNodes [lindex $vec($k) 1]
	}
	set offsVeci(X) 0
	set offsVeci(Y) 0
	set offsVeci(Z) 0
	set offsVecj(X) 0
	set offsVecj(Y) 0
	set offsVecj(Z) 0
	set eleTags "$id1"
	set sumD 0
	set i 0
	set iOfs [expr 0.5*($jntData($iNode,dim,$dir,pp,h) + $jntData($iNode,dim,$dir,pn,h))*$inputs(rigidZoneFac)]
    set iNode $iiNode
	foreach mNode $mNodes d $ds {
		incr i
		set mOfs 0
		set ofsNd $mNode
		if {$i == $nMidNodes} {
			set ofsNd $jNode
		}
		if [manageGeomData -jntExists $ofsNd] {
			set mOfs [expr 0.5*($jntData($ofsNd,dim,$dir,np,h) + $jntData($ofsNd,dim,$dir,nn,h))*$inputs(rigidZoneFac)]
		}
		if {$mOfs < 1e-3 && $iOfs < 1e-3} {
			set transTag $zerOffTransTag
		} else {
			set offsVeci($dir) $iOfs
			set offsVecj($dir) $mOfs
			set transTag [addGeomTransf "$eleCode,$elePos,$i" Linear $zV offsVeci offsVecj]
		}
		set eleTag "$eleCode,$elePos,$i"
        if {$inputs(numDims) == 3} {
            set args "$Area $inputs(E) $inputs(G) $J $I22 $I33 $transTag -mass $rho -release $release"
        } else {
            set args "$Area $inputs(E) $I33 $transTag -mass $rho -release $release"
        }
		set eleId [addElement elasticBeamColumn $eleTag $iNode $mNode $args]
		lappend eleTags $eleId
		if {$i != $nMidNodes} {
			set iOfs [expr 0.5*($jntData($mNode,dim,$dir,pp,h) + $jntData($mNode,dim,$dir,pn,h))*$inputs(rigidZoneFac)]
		}
		set iNode $mNode
    }
    lappend eleTags $id2
    return $eleTags
}