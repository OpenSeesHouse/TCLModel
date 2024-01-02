#define leaning columns
puts "~~~~~~~~~~~~~~~~~~~~~ Defining Leaning Columns ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Leaning Columns ~~~~~~~~~~~~~~~~~~~~~\n"
set j 0
if {$inputs(numDims) == 2 || $inputs(nBaysY) == 0} {
	set crdX -$X(2)
	set crdY 0.
} else {
	set crdX $inputs(centerMassX)
	set crdY $inputs(centerMassY)
}
set tag [addNode $j,98 $crdX $crdY $Z($j)]
set clmnTrans [addGeomTransf -getZeroOffsetTransf "PDelta Column"]
# set beamTrans [addGeomTransf -getZeroOffsetTransf "PDelta Y-Beam"]
set hFlag 1
if [info exists isoltrLabel] {
	set hFlag 0
}
if {$inputs(numDims) == 3} {
	fix $tag $hFlag $hFlag 1 0 0 0
} else {
	fix $tag $hFlag 1 0
}
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set jNode $j,98
	addNode $j,98 $crdX $crdY $Z($j)
	#rigid column:
	set eleTag $j,1
	set iNode [expr ($j-1)],98
	if {$inputs(numDims) == 3} {
		addElement elasticBeamColumn $eleTag $iNode $jNode "[expr 100*$inputs(typA)] $E $G [expr $inputs(typJ)/1000] \
			[expr $inputs(typIy)/1000.] [expr $inputs(typIz)/1000.] $clmnTrans"
	} else {
		addElement elasticBeamColumn $eleTag $iNode $jNode "[expr 100*$inputs(typA)] $E [expr $inputs(typIz)/1000.] $clmnTrans"
	}
	set leanClmn($j) $eleTag

	#rigid link  ----- replaced with rigidDiaphragm ---------
}
pattern Plain 3 Linear {
	for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
		set load $leanLoad($j)
		if {$inputs(numDims) == 3} {
			load [manageFEData -getNode $j,98] 0. 0 -$load 0. 0. 0.
		} else {
			load [manageFEData -getNode $j,98] 0. -$load 0.
		}
	}
}

