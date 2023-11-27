proc addHingeColumn {elePos eleCode iNodePos jNodePos sec angle matIdS matIdW kRat rhoName} {
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
    if {$angle == "90"} {
        #strong (S) axis aligns with global y (ID4)
        set ID4 $matIdW
        set ID5 $matIdS
        set Iz $I33
    } else {
        #strong (S) axis aligns with global x (ID4)
        set ID4 $matIdS
        set ID5 $matIdW
        set Iz $I22
    }
    set iiNode [manageTags -newNode "$eleCode,$elePos,1"]
    eval "addNode $iiNode [nodeCoord $iNode]"
    set tag1 [manageTags -newElement "$eleCode,$elePos,1"]
    set jjNode [manageTags -newNode "$eleCode,$elePos,2"]
    eval "addNode $jjNode [nodeCoord $jNode]"
    set tag2 [manageTags -newElement "$eleCode,$elePos,2"]
    if {$inputs(numDims) == 3} {
        element zeroLength $tag1 $iNode $iiNode \
            -mat $ID4 $ID5 $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag \
            -dir 4 5 6 1 2 3
        element elasticBeamColumn $eleTag $iiNode $jjNode $Area $inputs(E) $inputs(G) $J $I22 $I33 $transfTag -mass $rho ;# -release $release
        element zeroLength $tag2 $jjNode $jNode \
            -mat $ID4 $ID5 $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag \
            -dir 4 5 6 1 2 3
    } else {
        element zeroLength $tag1 $iNode $iiNode \
            -mat $ID5 $rigidMatTag $rigidMatTag -dir 3 1 2 
        element elasticBeamColumn $eleTag $iiNode $jjNode $Area $inputs(E) $Iz $transfTag -mass $rho ;# -release $release
        element zeroLength $tag2 $jjNode $jNode \
            -mat $ID5 $rigidMatTag $rigidMatTag -dir 3 1 2
    }
    return "$tag1 $eleTag $tag2"
}