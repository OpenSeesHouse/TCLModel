proc covar {vec1Name vec2Name} {
    upvar $vec1Name x
    upvar $vec2Name y
    set n [array size x]
    set m [array size y]
    if {$n != $m} {
        error "n != m"
    }
    set t1 0    ; #sumxiyi
    set t2 0    ; #sumxi
    set t3 0    ; #sumxi2
    set t4 0    ; #sumyi
    set t5 0    ; #sumyi2
    for {set i 1} {$i <= $n} {incr i} {
        set t1 [expr $t1+$x($i)*$y($i)]
        set t2 [expr $t2+$x($i)]
        set t3 [expr $t3+$x($i)**2]
        set t4 [expr $t4+$y($i)]
        set t5 [expr $t5+$y($i)**2]
    }
    set res [expr ($n*$t1-$t2*$t4)/(sqrt($n*$t3-$t2**2.)*sqrt($n*$t5-$t4**2.))]
    return $res
}