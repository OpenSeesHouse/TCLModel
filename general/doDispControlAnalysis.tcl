#########################################################################
#     please keep this notification at the beginning of this file       #
#                                                                       #
# Code to perform disp-control analysis by avoidance of numerical divergence#
#                                                                       #
#                  Developed by Seyed Alireza Jalali                    #
#        as part of the OpenSees course in civil808 institute           #
#  for more information and any questions about this code,              #
#               Join  "OpenSees SAJ" telegram group:                    #
#            (https://t.me/joinchat/CJlXoECQvxiJXal0PkLfwg)             #
#                     or visit: www.civil808.com                        #
#                                                                       #
#      DISTRIBUTION OF THIS CODE WITHOUT WRITTEN PERMISSION FROM        #
#                THE DEVELOPER IS HEREBY RESTRICTED                     #
#########################################################################

#source this file after building the model and applying the pushover load pattern
set tol 1.e-1										;#minimum tolerance of convergence test
set tol1 $tol
set algoList "ModifiedNewton {NewtonLineSearch 0.65} KrylovNewton Newton" ;#the desired list of algorithms; broyden and BFGS may lead to unacceptable values in static analysis
# wipeAnalysis
set testType NormDispIncr  
set numAlgos [llength $algoList]
constraints Transformation
numberer RCM
system BandGeneral
test $testType $tol 100
set incr1 $incr
set failureFlag 0
set endDisp 0
for {set iDrift 0} {$iDrift < [llength $inputs(targetDriftList)]} {incr iDrift} {
	set targetDrift [lindex $inputs(targetDriftList) $iDrift]
	set targetDisp [expr $targetDrift*$LBuilding]
	puts "***************** Applying targetDrift= $targetDrift, targetDisp= $targetDisp ****************"
	set curD [nodeDisp $roofNode 1]
	set deltaD [expr $targetDisp - $curD]
	set sgn [expr $deltaD/abs($deltaD)]
	set nSteps [expr int(abs($deltaD)/$incr1)]
	algorithm Newton
	integrator DisplacementControl $roofNode 1 [expr abs($deltaD)/$deltaD*$incr]
	analysis Static
	puts "########################## Trying: Newton, incr=$incr1 ##########################"
	analyze 1	;#single step to examine time (V) sign
	set T0 [getTime]
	set ok [analyze $nSteps]
	set curD [nodeDisp $roofNode 1]
	set deltaD [expr $targetDisp-$curD]
	if {[expr $deltaD*$sgn] < 0} {
		set deltaD 0
	}
	set iTry 1
	while {[expr abs($deltaD)] > 0.001 && [expr [getTime]/$T0] > 0} {
		puts "~~~~~~~~~~~~~~~~~~~~~~~~~~ curD= $curD, deltaD= $deltaD ~~~~~~~~~~~~~~~~~~~~~~~~~~"
		integrator DisplacementControl $roofNode 1 [expr $sgn*$incr1]
		analysis Static
		if {$iTry <= $numAlgos} {
			set algo [lindex $algoList [expr $iTry-1]]
			puts "########################## Trying: [lindex $algo 0], incr=$incr1 ##########################"
			test $testType $tol1 30
			eval "algorithm $algo"
			set nSteps [expr int(abs($deltaD)/$incr1)+1]
			set ok [analyze $nSteps]
			if {$ok == 0} {
				set curD [nodeDisp $roofNode 1]
				set deltaD [expr $targetDisp-$curD]
				if {[expr $deltaD*$sgn] < 0} {
					set deltaD 0
				}
				integrator DisplacementControl $roofNode 1 [expr $sgn*$incr]
				analysis Static
				set nSteps [expr int(abs($deltaD)/$incr)]
				set ok [analyze $nSteps]
				set incr1 $incr
				set tol1 $tol
				set iTry 0
			}
		} else {
			set iTry 0
			set incr1 [expr $incr1/2.]
			set tol1 [expr $tol1*2.]
			if {[expr $incr1/$incr] < 1.e-4} {
				set failureFlag 1
				break
			}
		}
		incr iTry
		set curD [nodeDisp $roofNode 1]
		set deltaD [expr $targetDisp-$curD]		
		if {[expr $deltaD*$sgn] < 0} {
			set deltaD 0
		}
	}
	set endDisp [nodeDisp $roofNode 1]
	if {$failureFlag == 0} {
		puts "########################## Analysis Successful! ##########################"
	} else {
		puts "!!!!!!!!!!!!!!!!!!!!!!!!!! Analysis Interrupted !!!!!!!!!!!!!!!!!!!!!!!!!!"
	}
	puts "~~~~~~~~~~~~~~~~~~~~~~~~~~ endDisp= $endDisp ~~~~~~~~~~~~~~~~~~~~~~~~~~"
}
