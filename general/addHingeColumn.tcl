proc addHingeColumn {elePos eleCode iNode jNode sec angle matId2 matId3 kRat rhoName zAxis nSegName} {
    global inputs
    global jntData
    upvar $rhoName rho
    upvar $nSegName nSeg
    set nSeg 1
    set rigidMatTag [manageFEData -getMaterial rigid]
    foreach "j k i" [split $elePos ,] {}
	source $inputs(secFolder)/$sec.tcl
	source $inputs(secFolder)/convertToM.tcl
	set rho [expr $inputs(selfWeightMultiplier)*$Area*$inputs(density)]
    set eleTag "$eleCode,$elePos"
    set offsi(X) 0
    set offsi(Y) 0
    set offsj(X) 0
    set offsj(Y) 0
    set offsi(Z) [expr ($jntData($iNode,dim,X,pp,v) + \
                        $jntData($iNode,dim,X,np,v) +	\
                        $jntData($iNode,dim,Y,pp,v) + \
                        $jntData($iNode,dim,Y,np,v))*0.25*$inputs(rigidZoneFac)]
    set offsj(Z) [expr -($jntData($jNode,dim,X,pn,v) + \
                         $jntData($jNode,dim,X,nn,v) +	\
                         $jntData($jNode,dim,Y,pn,v) + \
                         $jntData($jNode,dim,Y,nn,v))*0.25*$inputs(rigidZoneFac)]
	set transfTag [addGeomTransf "$eleCode,$elePos" $inputs(clmnGeomtransfType) $zAxis offsi offsj]                         
    set I33 [expr $kRat*$I33*($inputs(nFactor)+1)/$inputs(nFactor)]
    set I22 [expr $kRat*$I22*($inputs(nFactor)+1)/$inputs(nFactor)]
    set iiNode "$eleCode,$elePos,1"
    eval "addNode $iiNode [manageFEData -getNodeCrds $iNode]"
    set tag1 "$eleCode,$elePos,h1"
    set jjNode "$eleCode,$elePos,2"
    eval "addNode $jjNode [manageFEData -getNodeCrds $jNode]"
    set tag2 "$eleCode,$elePos,h2"
    if {$inputs(numDims) == 3} {
        set xV "0 0 1"
        set zV $inputs(defZAxis-Column)
        if {$angle > 1e-3} {
            set zV [Vector rotateAboutZ $zV $angle]
        }
        set yV [Vector crossProduct $zV $xV]
        set id1 [addElement zeroLength $tag1 $iNode $iiNode \
            "-mat $matId3 $matId3 $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag \
            -dir 6 5 1 2 3 4 -orient $xV $yV"]
        set id [addElement elasticBeamColumn $eleTag $iiNode $jjNode "$Area $inputs(E) $inputs(G) $J $I22 $I33 $transfTag -mass $rho" -addToDamping]
        set id2 [addElement zeroLength $tag2 $jjNode $jNode \
            "-mat $matId3 $matId2 $rigidMatTag $rigidMatTag $rigidMatTag $rigidMatTag \
            -dir 6 5 1 2 3 4 -orient $xV $yV"]
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
        set id1 [addElement zeroLength $tag1 $iNode $iiNode "-mat $ID $rigidMatTag $rigidMatTag -dir 3 1 2"]
        set id [addElement elasticBeamColumn $eleTag $iiNode $jjNode "$Area $inputs(E) $Iz $transfTag -mass $rho" -addToDamping]
        set id2 [addElement zeroLength $tag2 $jjNode $jNode "-mat $ID $rigidMatTag $rigidMatTag -dir 3 1 2"]
    }
    return "$id1 $id $id2"
}