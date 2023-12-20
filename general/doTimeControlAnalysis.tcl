#inputs: deltaT, Tmax, inputs(checkMaxResp)
set tol 1.e-3
set tol1 $tol
set algoList "Newton ModifiedNewton {NewtonLineSearch 0.65} KrylovNewton BFGS Broyden"
wipeAnalysis
set testType NormDispIncr
set numAlgos [llength $algoList]
constraints Transformation
numberer RCM
system UmfPack
test $testType $tol 100
set dt1 $deltaT
algorithm Newton
set failureFlag 0
set endTime 0
set curTime [getTime]
set DT [expr $Tmax-$curTime]
set nSteps [expr round($DT/$dt1)]

puts "########################## Trying: Newton, dt=$dt1 ##########################"
if {$inputs(analType) == "dynamic"} {
	set tryStep 0.1
	integrator Newmark 0.5 0.25
	analysis Transient
	set ok [analyze $nSteps $dt1]
} else {
	# Static
	set tryStep 1.
	integrator LoadControl $dt1
	analysis Static
	set ok [analyze $nSteps]
}
set curTime [getTime]
set DT [expr $Tmax-$curTime]
set iTry 1
while {$DT >= $deltaT} {
	if {$inputs(checkMaxResp) && [getMaxResp recTags] > 0.1} {
		set failureFlag 1
		break
	}
	puts "~~~~~~~~~~~~~~~~~~~~~~~~~~ curTime= $curTime, DT= $DT ~~~~~~~~~~~~~~~~~~~~~~~~~~"
	if {$iTry <= $numAlgos} {
		set algo [lindex $algoList [expr $iTry-1]]
		puts "########################## Trying: [lindex $algo 0], dt=$dt1 ##########################"
		test $testType $tol1 30
		eval "algorithm $algo"
		set nSteps [expr round($tryStep/$dt1)]
		if {$inputs(analType) == "dynamic"} {
			set ok [analyze $nSteps $dt1]
		} else {
			# Static
			integrator LoadControl $dt1
			analysis Static
			set ok [analyze $nSteps]
		}
		if {$ok == 0} {
			set curTime [getTime]
			set DT [expr $Tmax-$curTime]
			set nSteps [expr round($DT/$deltaT)]
			if {$inputs(analType) == "dynamic"} {
				set ok [analyze $nSteps $deltaT]
			} else {
				# Static
				integrator LoadControl $deltaT
				analysis Static
				set ok [analyze $nSteps]
			}
			set dt1 $deltaT
			set tol1 $tol
			set iTry 0
		}
	} else {
		set iTry 0
		set dt1 [expr $dt1/2.]
		set tol1 [expr $tol1*2.]
		if {[expr $dt1/$deltaT] < 1.e-4} {
			set failureFlag 1
			break
		}
	}
	incr iTry
	set curTime [getTime]
	set DT [expr $Tmax-$curTime]		
}
set endTime [getTime]
if {$failureFlag == 0} {
	puts "########################## Analysis Successful! ##########################"
} else {
	puts "!!!!!!!!!!!!!!!!!!!!!!!!!! Analysis Interrupted !!!!!!!!!!!!!!!!!!!!!!!!!!"
}
puts "~~~~~~~~~~~~~~~~~~~~~~~~~~ endTime= [getTime] ~~~~~~~~~~~~~~~~~~~~~~~~~~"
