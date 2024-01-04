proc computeFij {nflrs iMode fName S shapeRecN logFileN massVecN patternType} {
    upvar $fName f
    upvar 2 $massVecN massVec
    if {$S == 0} {
        # the spectral term will zero the mode's effect
        for {set i 1} {$i <= $nflrs} {incr i 1} {
            set f($iMode,$i) 0
        }
        return 0
    }
    #obtain mass-normalized mode shapes
    computePhi $nflrs $shapeRecN $iMode Phi $logFileN $massVecN
    set MPF 0
    # set denom 0
    for {set i 1} {$i <= $nflrs} {incr i 1} {
        set v $Phi($iMode,$i)
        set MPF [expr $MPF+$massVec($i)*$v]
        # set denom [expr $denom+$massVec($i)*$v**2.]; #becomes unity since mass-normalize Phi is used
    }
    # modal participation factor: MPF
    # set MPF [expr $MPF/$denom]
    set Phi_1 0;
    for {set i 1} {$i <= $nflrs} {incr i 1} {
        set Phi_2 $Phi($iMode,$i)
        set f($iMode,$i) [expr $S*($Phi_2-$Phi_1)*$MPF*$massVec($i)]
        if {$patternType != "force"} {
            set Phi_1 $Phi_2
        }
    }
    return $MPF
}
