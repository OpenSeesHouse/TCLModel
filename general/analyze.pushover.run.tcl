
set testType NormDispIncr  
set incr1 $incr
set tol1 $tol
set numAlgos [llength $algoList]
wipeAnalysis
# constraints Plain
constraints Transformation
# constraints Penalty 1000 1000
numberer RCM
system UmfPack
test $testType $tol 100
set failureFlag 0
set endDisp 0
for {set iDrift 0} {$iDrift < [llength $inputs(targetDriftList)]} {incr iDrift} {
	set targetDrift [lindex $inputs(targetDriftList) $iDrift]
	set targetDisp [expr $targetDrift*$LBuilding]
	puts "***************** Applying targetDrift= $targetDrift, targetDisp= $targetDisp ****************"
	set curD [nodeDisp $roofNodeTag $cntrlDof]
	set deltaD [expr $targetDisp - $curD]
	set nSteps [expr int(abs($deltaD)/$incr1)]
	algorithm Newton
	set sign [expr abs($deltaD)/$deltaD]
	integrator DisplacementControl $roofNodeTag $cntrlDof [expr $sign*$incr]
	analysis Static
	puts "########################## Trying: Newton, incr=$incr1 ##########################"
	set ok [analyze $nSteps]
	set curD [nodeDisp $roofNodeTag $cntrlDof]
	set deltaD [expr $targetDisp-$curD]
	set iTry 1
	while {1} {
		if {$sign > 0 && $deltaD < $incr} break
		if {$sign < 0 && $deltaD > -$incr} break
		puts "~~~~~~~~~~~~~~~~~~~~~~~~~~ curD= $curD, deltaD= $deltaD ~~~~~~~~~~~~~~~~~~~~~~~~~~"
		integrator DisplacementControl $roofNodeTag $cntrlDof [expr $sign*$incr1]
		analysis Static
		if {$iTry <= $numAlgos} {
			set algo [lindex $algoList [expr $iTry-1]]
			puts "########################## Trying: [lindex $algo 0], incr=$incr1 ##########################"
			test $testType $tol1 30
			eval "algorithm $algo"
			set nSteps [expr int(1.*$incr/$incr1)]
			set ok [analyze $nSteps]
			if {$ok == 0} {
				set curD [nodeDisp $roofNodeTag $cntrlDof]
				set deltaD [expr $targetDisp-$curD]
				integrator DisplacementControl $roofNodeTag $cntrlDof [expr $sign*$incr]
				analysis Static
				set nSteps [expr int(abs($deltaD)/$incr)]
				set ok [analyze $nSteps]
				set incr1 $incr
				set tol1 $tol
				set iTry 0
			}
		} else {
			set iTry 0
			set incr1 [expr $incr1/3.]
			set tol1 [expr $tol1*3.]
			if {[expr $incr1/$incr] < 1.e-3} {
				set failureFlag 1
				break
			}
		}
		incr iTry
		set curD [nodeDisp $roofNodeTag $cntrlDof]
		set deltaD [expr $targetDisp-$curD]		
	}
	set endDisp [nodeDisp $roofNodeTag $cntrlDof]
	if {$failureFlag == 0} {
		puts "########################## Analysis Successful! ##########################"
	} else {
		puts "!!!!!!!!!!!!!!!!!!!!!!!!!! Analysis Interrupted !!!!!!!!!!!!!!!!!!!!!!!!!!"
	}
	puts "~~~~~~~~~~~~~~~~~~~~~~~~~~ endDisp= $endDisp ~~~~~~~~~~~~~~~~~~~~~~~~~~"
}
