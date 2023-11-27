proc computePhi {nflrs shapeRecN iMode PhiName logFileN {massVecN ""} {upLevel 3} {normalMethod 0}} {
    global apStepCount
    upvar $upLevel $shapeRecN shapeRec
    upvar $PhiName Phi
	#normalMethod: 1:based on maxAbs - 2:mass-normalized
	if {$massVecN != ""} {
		upvar $upLevel $massVecN massVec
	}
    if {$normalMethod == 0} {
		if {$massVecN != ""} {
			set normalMethod 2; #based on PhiT.M.Phi==1
		} else {
			set normalMethod 1; 
		}
	}
    #assemble Phi matrix (modal shapes)
    #iMode: mode number - i : dof (story) number
    set normTerm 0
    for {set i 1} {$i <= $inputs(nFlrs)} {incr i} {
        set v [recorderValue $shapeRec($iMode) $i]
        set Phi($iMode,$i) $v
		# puts "Phi($iMode,$i) $v"
        if {$normalMethod == 1} {
            set absv [expr abs($v)]
            if {$absv > $normTerm} {
                set normTerm $absv
                set refVal $v
            }
        } else {
            set normTerm [expr $normTerm+$massVec($i)*($v**2.)]
        }
    }
	# puts "refVal $refVal"
    remove recorder $shapeRec($iMode)
    set file [open $logFileN a+]
	set line ""
	if [info exists apStepCount] {
		set line "$apStepCount"
	}
	set sumPhi 0
	set sumMiPhi 0
	set sumMiPhi2 0
    for {set i 1} {$i <= $inputs(nFlrs)} {incr i} {
        if {$normalMethod == 1} {
            #normalize over maxAbs
            set Phi($iMode,$i) [expr $Phi($iMode,$i)/$refVal]
        } else {
            #mass-normalize
            set Phi($iMode,$i) [expr $Phi($iMode,$i)/sqrt($normTerm)]
        }
		set sumMiPhi  [expr $sumMiPhi +$massVec($i)*$Phi($iMode,$i)]
		set sumMiPhi2 [expr $sumMiPhi2+$massVec($i)*$Phi($iMode,$i)**2]
		set sumPhi [expr $sumPhi + $Phi($iMode,$i)]
        lappend line $Phi($iMode,$i)
    }
    puts $file $line
    close $file
	return "$sumPhi $sumMiPhi $sumMiPhi2"
}
