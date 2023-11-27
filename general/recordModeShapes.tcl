proc recordModeShapes {nflrs inputs(numModes) masterNodeVec shapeRecVec {filePath ""}} {
    upvar $masterNodeVec masterNode
    upvar $shapeRecVec shapeRec
    set dof 1
    set allMasterNds ""
    for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
        lappend allMasterNds $masterNode($j)
    }
    for {set j 1} {$j <= $inputs(numModes)} {incr j} {
        if {$filePath == ""} {
            set shapeRec($j) [eval "recorder Node -node $allMasterNds -dof $dof \"eigen $j\""]
        } else {
            set shapeRec($j) [eval "recorder Node -file $filePath -node $allMasterNds -dof $dof \"eigen $j\""]
        }
    }
}