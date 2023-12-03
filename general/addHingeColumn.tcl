proc addHingeColumn {elePos eleCode iNodePos jNodePos sec angle matId2 matId3 kRat rhoName} {
    global inputs
    upvar $rhoName rho
    set rigidMatTag $inputs(rigidMatTag)
    foreach "j k i" [split $elePos ,] {}
	source $inputs(secFolder)/$sec.tcl
	source $inputs(secFolder)/convertToM.tcl
	set rho [expr $inputs(selfWeightMultiplier)*$Area*$inputs(density)]
    set iNode [manageTags -getNode $iNodePos]
    set jNode [manageTags -getNode $jNodePos]
    set eleTag [manageTags -newElement "$eleCode,$elePos"]
	set transfTag [manageTags -getGeomtransf "$eleCode,$elePos"]
    set I33 [expr $kRat*$I33*($inputs(nFactor)+1)/$inputs(nFactor)]
    set I22 [expr $kRat*$I22*($inputs(nFactor)+1)/$inputs(nFactor)]
    set iiNode [manageTags -newNode "$eleCode,$elePos,1"]
    eval "addNode $iiNode [nodeCoord $iNode]"
    set tag1 [manageTags -newElement "$eleCode,$elePos,1"]
    set jjNode [manageTags -newNode "$eleCode,$elePos,2"]
    eval "addNode $jjNode [nodeCoord $jNode]"
    set tag2 [manageTags -newElement "$eleCode,$elePos,2"]
    if {$inputs(numDims) == 3} {
        set xV "0 0 1"
        set zV $inputs(defClmnZAxis)
        if {$angle > 1e-3} {
            set zV [Vector rotateAboutZ $zV $angle]
        }
        set yV [Vector crossProduct $zV $xV]
        eval "element zeroLength $tag1 $iNode $iiNode \
            -mat $matId2 $matId3 $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag \
            -dir 5 6 1 2 3 4 -orient $xV $yV"
        element elasticBeamColumn $eleTag $iiNode $jjNode $Area $inputs(E) $inputs(G) $J $I22 $I33 $transfTag -mass $rho ;
        eval "element zeroLength $tag2 $jjNode $jNode \
            -mat $matId2 $matId3 $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag \
            -dir 5 6 1 2 3 4 -orient $xV $yV"
    } else {
        if {$angle < 1e-3} {
            #local z axis aligns with global Y
            set ID $matId3
            set Iz $I33
        } elseif [expr abs($angle-90) < 1.e-3] {
            #local z axis aligns with global X
            set ID $matId2
            set Iz $I22
        } else {
            error ("Currently, only 0 and 90 degrees are allowed for column rotation angle")
        }
        element zeroLength $tag1 $iNode $iiNode -mat $ID $rigidMatTag $rigidMatTag -dir 3 1 2 
        element elasticBeamColumn $eleTag $iiNode $jjNode $Area $inputs(E) $Iz $transfTag -mass $rho ;
        element zeroLength $tag2 $jjNode $jNode -mat $ID $rigidMatTag $rigidMatTag -dir 3 1 2
    }
    return "$tag1 $eleTag $tag2"
}