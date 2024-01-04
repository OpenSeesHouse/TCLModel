source $inputs(generalFolder)/computeModalPattern.tcl
source $inputs(generalFolder)/interpolate.tcl
source $inputs(generalFolder)/computePhi.tcl
source $inputs(generalFolder)/computeFij.tcl
source $inputs(generalFolder)/recordModeShapes.tcl
set roofNodeTag [manageFEData -getNode $inputs(roofNode)]
set tol 1.e-4
set algoList "Newton ModifiedNewton {NewtonLineSearch 0.65} KrylovNewton Broyden"
source $inputs(generalFolder)/getMaxResp.tcl

set sumWi 0.
set allEleCodes [eleCodeMap -getAllCodes]
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set mass [manageFEData -getStoryMass $j]
	set sumWi [expr $sumWi + $mass*$g]
	set massArr($j) $mass
}
puts "pushover sumWi= $sumWi"

if {$inputs(pushDir) == "X"} {
	set cntrlDof 1
} else {
	set cntrlDof 2
}
set prevV $sumWi    ;# will be used in consequtive steps to track V increment in the F vecs.
set LBuilding	$Z($inputs(nFlrs))							;#the total height of the building in units of length
set targetDrift $inputs(targetDriftList)
set apDeltaD [expr $targetDrift/$inputs(numPushSteps)]
# initiae lateral load vector. This will update sequentially in  new steps by adding the modal load increments
for {set j 1} {$j <= $inputs(nFlrs)} {incr j 1} {
	set apF($j) 0
}
set numModes $inputs(nFlrs)
set inputs(numModes) $inputs(nFlrs)
for {set iStep 1} {$iStep <= $inputs(numPushSteps)} {incr iStep} {
	set targD [expr $LBuilding*$iStep*$apDeltaD]
	set curRoofD [nodeDisp $roofNodeTag $cntrlDof]
	set deltaD [expr $targD-$curRoofD]
	puts -nonewline "iStep = $iStep roofDisp = $curRoofD"
	recordModeShapes $inputs(nFlrs) $numModes $cntrlDof masterNode shapeRecrdrs   ;# recorders will be removed inside proc:computeModalPattern
	set omega2s [doEigen 0]
	if {$omega2s == ""} {
		puts "\n-------failed in eigen analysis-----------"
		break
	}
	set Tperiods ""
	foreach omega2 $omega2s {
		if {$omega2 == "" || $omega2 < 0} {
			puts "\n-------failed in eigen analysis-----------"
			break
		}
		lappend Tperiods [expr 2*3.1415/sqrt($omega2)]
	}
	puts  " -- eigen done!"
	for {set iMode 1} {$iMode <= $inputs(nFlrs)} {incr iMode} {
		record $shapeRecrdrs($iMode)
	}
	if ![info exists specFac] {
		set specFac 1
	}
	set res [computeModalPattern massArr $inputs(resFolder) apF shapeRecrdrs $combinMethod $patternType $inputSpec $Tperiods $specFac]
	pattern Plain [expr $iStep*100] Linear {
		for {set j 1} {$j <= $inputs(nFlrs)} {incr j 1} {
			set refNode $masterNode($j)
			if {$patternType == "force"} {
				# FAP
				set sumF $res
				set normFac [expr $prevV/$sumF]
				set fi [expr $normFac*$apF($j)]
				if {$inputs(numDims) == 3} {
					set nodeTag  [manageFEData -getNode $refNode]
					if {$inputs(pushDir) == "X"} {
						load $nodeTag $fi 0. 0. 0. 0. 0.
					} else {
						load $nodeTag 0. $fi 0. 0. 0. 0.
					}
				} else {
					set numSlaveNodeList [llength $slaveNodeList($j)]
					set fi [expr $fi/$numSlaveNodeList]
					foreach pos $slaveNodeList($j) {
						set nodeTag  [manageFEData -getNode $pos]
						load $nodeTag $fi 0. 0.
					}
				}
			} else {
				# DAP
				set roofD $res
				if {$updateMethod == "incremental"} {
					set curD [nodeDisp $refNode $cntrlDof]
					set normFac [expr $deltaD/$roofD]
				} else {
					set normFac [expr $LBuilding*$iStep*$apDeltaD/$roofD]
					set curD 0
				}
				set di [expr $curD+$normFac*$apF($j)]
				set nodeTag  [manageFEData -getNode $refNode]
				sp $nodeTag $cntrlDof [expr $curD+$normFac*$apF($j)]
			}
		}
	}
	if {$patternType == "force"} {
		set inputs(targetDriftList) [expr $iStep*$apDeltaD]
		set incr [expr $apDeltaD*$LBuilding/$numStepDivs]		;#maximum displacement increment in units of length
		source $inputs(generalFolder)/doDispControlAnalysis.tcl
		if {$updateMethod == "incremental"} {
			loadConst
		} else {
			remove loadPattern [expr $iStep*100]
		}
	} else {
		set Tmax 1.
		set deltaT 1.
		set analType "push"
		set checkMaxResp 0
		source $inputs(generalFolder)/doTimeControlAnalysis.tcl
		wipeAnalysis
		setTime 0
	}
}
