proc addHingeBeam {elePos eleCode iNodePos jNodePos sec springMatId kRat release rhoName zV} {
    global inputs
    upvar $rhoName rho
    set rigidMatTag $inputs(rigidMatTag)
    foreach "j k i" [split $elePos ,] {}
	source $inputs(secFolder)/$sec.tcl
	source $inputs(secFolder)/convertToM.tcl
	set rho [expr $inputs(selfWeightMultiplier)*$Area*$inputs(density)]
    set iNode [manageTags -getNode $iNodePos]
    set jNode [manageTags -getNode $jNodePos]
    set I33 [expr $kRat*$I33*($inputs(nFactor)+1)/$inputs(nFactor)]
    set iiNode $iNode
    set jjNode $jNode
	set eleTag [manageTags -newElement "$eleCode,$elePos"]
	set transfTag [manageTags -getGeomtransf "$eleCode,$elePos"]
    if {$inputs(numDims) == 3} {
        set yV "0. 0. 1."
        set xV [Vector crossProduct $yV $zV]
    }
    set tag1 0
    set tag2 0
    if {$release != 3 && $release != 1} {
        set iiNode [manageTags -newNode "$eleCode,$elePos,1"]
        eval "addNode $iiNode [nodeCoord $iNode]"
        set tag1 [manageTags -newElement "$eleCode,$elePos,1"]
        if {$inputs(numDims) == 3} {
            eval "element zeroLength $tag1 $iNode $iiNode \
                -mat $springMatId $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag \
                -dir 6 1 2 3 4 5 -orient $xV $yV"
        } else {
            element zeroLength $tag1 $iNode $iiNode \
                -mat $springMatId $rigidMatTag $rigidMatTag -dir 3 1 2 
        }
    }
    if {$release != 3 && $release != 2} {
        set jjNode [manageTags -newNode "$eleCode,$elePos,2"]
        eval "addNode $jjNode [nodeCoord $jNode]"
        set tag2 [manageTags -newElement "$eleCode,$elePos,2"]
        if {$inputs(numDims) == 3} {
            eval "element zeroLength $tag2 $jjNode $jNode \
                -mat $springMatId $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag \
                -dir 6 1 2 3 4 5 -orient $xV $yV"
        } else {
            element zeroLength $tag2 $jjNode $jNode \
                -mat $springMatId $rigidMatTag $rigidMatTag -dir 3 1 2
        }
    }
    if {$inputs(numDims) == 3} {
        element elasticBeamColumn $eleTag $iiNode $jjNode $Area $inputs(E) $inputs(G) $J $I22 $I33 $transfTag -mass $rho -release $release
    } else {
        element elasticBeamColumn $eleTag $iiNode $jjNode $Area $inputs(E) $I33 $transfTag -mass $rho -release $release
    }
    return "$tag1 $eleTag $tag2"
}