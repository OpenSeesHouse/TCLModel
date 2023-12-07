proc addGeomTransf {pos type {zVec ""} {offsiName ""} {offsjName ""}} {
    global inputs
    set tag [manageFEData -newGeomtransf $pos]
    if {$inputs(numDims) == 3} {
        set offi "0 0 0"
        set offj "0 0 0"
    } else {
        set offi "0 0"
        set offj "0 0"
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