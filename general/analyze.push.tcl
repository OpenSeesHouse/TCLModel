puts "~~~~~~~~~~~~~~~~~~~~~ applying pushover loading ~~~~~~~~~~~~~~~~~~~~~"
# V = C*W
# Fi = [WiHi^k/Sum(WiHi^k)]V
source $inputs(generalFolder)/getMaxResp.tcl

set sumWiHi 0.
set sumWi 0.
set allEleCodes [eleCodeMap -getAllCodes]
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set mass $diaphMass($j,X)
	foreach eleCode $allEleCodes {
		if [info exists sumStrucWeigh($eleCode,$j)] {
			set mass [expr $mass + $sumStrucWeigh($eleCode,$j)]
		}
	}
	set sumWiHi [expr $sumWiHi+$mass*$g*$Z($j)**$inputs(kPush)]
	set sumWi [expr $sumWi + $mass*$g]
	set massArr($j) $mass
}
puts "pushover sumWi= $sumWi"
pattern Plain 2 Linear {
	for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
		set mass $massArr($j)
		set wi [expr $mass*$g]
		set fi [expr $sumWi*$wi*$Z($j)**$inputs(kPush)/$sumWiHi]
		if {$inputs(numDims) == 3} {
			set nodeTag  [manageFEData -getNode $masterNode($j)]
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
	}
}
if {$inputs(numDims) == 2 || $inputs(pushDir) == "X"} {
	set cntrlDof 1
} else {
	set cntrlDof 2
}
set roofNodeTag [manageFEData -getNode $inputs(roofNode)]
set LBuilding $Z($inputs(nFlrs))
set incr [expr 0.05*$LBuilding/$inputs(numPushSteps)]
set tol 1.e-4
set algoList "Newton ModifiedNewton {NewtonLineSearch 0.65} KrylovNewton Broyden"
source $inputs(generalFolder)/analyze.pushover.run.tcl
remove loadPattern 2