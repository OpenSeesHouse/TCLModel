proc addGeomTransf {pos type {zVec ""} {offsiName ""} {offsjName ""}} {
    global inputs
    global zeroOffsetTransf
    if {$pos == "-getZeroOffsetTransf"} {
        foreach "type eleGrp" $type {}
        set keyStr $type-$eleGrp
        if [info exists zeroOffsetTransf($keyStr)] {
            return $zeroOffsetTransf($keyStr)
        }
        set zeroOffsetTransf($keyStr) [manageFEData -newGeomtransf zeroOffs,$keyStr]
        if {$inputs(numDims) == 3} {
            eval "geomTransf $type $zeroOffsetTransf($keyStr) $inputs(defZAxis-$eleGrp)"
        } else {
            geomTransf $type $zeroOffsetTransf($keyStr)
        }
        return $zeroOffsetTransf($keyStr)
    }
    set tag [manageFEData -newGeomtransf $pos]
    if {$inputs(numDims) == 3} {
        set offi "0 0 0"
        set offj "0 0 0"
    } else {
        set offi "0 0"
        set offj "0 0"
        set zVec ""
    }
    if {$offsiName != ""} {
        upvar $offsiName offs
        if {$inputs(numDims) == 3} {
            set offi "$offs(X) $offs(Y) $offs(Z)"
        } else {
            set offi "$offs(X) $offs(Z)"
        }
    }
    if {$offsjName != ""} {
        upvar $offsjName offs
        if {$inputs(numDims) == 3} {
            set offj "$offs(X) $offs(Y) $offs(Z)"
        } else {
            set offj "$offs(X) $offs(Z)"
        }
    }
    eval "geomTransf $type $tag $zVec -jntOffset $offi $offj"
    return $tag
}