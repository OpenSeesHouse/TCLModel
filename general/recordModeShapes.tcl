proc recordModeShapes {nflrs numModes dof masterNodeVec shapeRecVec {filePath ""}} {
    upvar $masterNodeVec masterNode
    upvar $shapeRecVec shapeRec
    set allMasterNds ""
    for {set j 1} {$j <= $nflrs} {incr j} {
        lappend allMasterNds [manageFEData -getNode $masterNode($j)]
    }
    for {set j 1} {$j <= $numModes} {incr j} {
        if {$filePath == ""} {
            set shapeRec($j) [eval "recorder Node -node $allMasterNds -dof $dof \"eigen $j\""]
        } else {
            set shapeRec($j) [eval "recorder Node -file $filePath -node $allMasterNds -dof $dof \"eigen $j\""]
        }
    }
}