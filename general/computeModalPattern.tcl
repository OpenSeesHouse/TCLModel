#compute updated lateral pattern
set apStepCount 0
proc computeModalPattern {massVecName folder outF shapeRecName combinMethod patternType {specFile ""} {Tperiods ""} {specFac {1}}} {
    global apStepCount
    global inputs
    upvar $outF F
    upvar $shapeRecName shapeRec
    set x $inputs(dampRat)
    incr apStepCount

    #read and store the spectrun in T and S lists
    set specTList ""
    set specSList ""
    if {$specFile != ""} {
        set file [open $specFile r]
        set lines [split [read $file] \n]
        close $file
        foreach line $lines {
            if {$line == ""} continue
            foreach "t v" $line {
                lappend specTList $t
                lappend specSList $v
            }
        }
    }
    set nflrs [array size F]
    set numModes [array size shapeRec]
    #compute modal forces
    file mkdir $folder/modeShapes
    for {set iMode 1} {$iMode <= $numModes} {incr iMode 1} {
        set logFileN $folder/modeShapes/$iMode.out
        set S 1
        set T($iMode) 0
        if {$specFile != "" && $Tperiods != ""} {
            set T($iMode) [lindex $Tperiods [expr $iMode-1]]
            set S [interpolate $specTList $specSList $T($iMode) "" 1 1]
            set S [expr $S*$specFac]
        }
        computeFij $nflrs $iMode f $S $shapeRecName $logFileN $massVecName $patternType
    } 
    #combine modal forces
    set sumF 0
    set file [open $folder/apF.out a+]
    set line "$apStepCount"
    for {set i 1} {$i <= $nflrs} {incr i 1} {
        for {set iMode 1} {$iMode <= $numModes} {incr iMode 1} {
            if {$combinMethod == "SRSS"} {
                set Fj [expr $f($iMode,$i)**2]
            } else {
                #CQC
                if {$T($iMode) == 0} {
                   set Fj [expr $f($iMode,$i)**2] 
                } else {
                    set wj [expr 2.*3.1415/$T($iMode)]
                    set fji $f($iMode,$i)
                    set Fj 0
                    for {set k 1} {$k <= $numModes} {incr k} {
                        if {$T($k) == 0} continue
                        set wk [expr 2.*3.1415/$T($k)]
                        set r [expr $wk/$wj]
                        set rho [expr (8*($x**2)*(1.+$r)*$r**1.5)/((1-$r**2)**2+4*$x**2.*$r*(1+$r)**2.)]
                        set fki $f($k,$i)
                        set Fj [expr $Fj+$fji*$rho*$fki]
                    }
                }
            }
            set F($i) [expr $F($i)+$Fj]
        }
        set F($i) [expr sqrt($F($i))]
        if {$patternType != "force" && $i > 1} {
            # we should add-up the drifts to get the disps.
            set F($i) [expr $F($i)+$F([expr $i-1])]
        }
        lappend line $F($i)
        set sumF [expr $sumF + $F($i)]
    }
    puts $file $line
    close $file
    if {$patternType == "force"} {
        return "$sumF"
    } else {
        return $F($nflrs)
    }
}