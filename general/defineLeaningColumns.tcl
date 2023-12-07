#define leaning columns
puts "~~~~~~~~~~~~~~~~~~~~~ Defining Leaning Columns ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Leaning Columns ~~~~~~~~~~~~~~~~~~~~~\n"
set j 0
set crdX 0.
if {$inputs(numDims) == 2} {
	set crdX -$X(2)
}
set crdY 0.
set tag [addNode $j,98 $crdX $crdY $Z($j)]
lappend slaveNodeList($j) $tag
set clmnTrans [manageFEData -newGeomtransf "leaningClmn"]
set beamTrans [manageFEData -newGeomtransf "leaningClmnLink"]
if {$inputs(numDims) == 3} {
	eval "geomTransf PDelta $clmnTrans $inputs(defClmnZAxis)"
	eval "geomTransf Linear $beamTrans $inputs(defXBeamZAxis)"
	fix $tag 1 1 1 0 0 0
} else {
	geomTransf PDelta $clmnTrans
	geomTransf Linear $beamTrans
	fix $tag 1 1 0
}
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set jNode [addNode $j,98 $crdX $crdY $Z($j)]
	# lappend slaveNodeList($j) $tag
	#rigid column:
	set eleTag [manageFEData -newElement $j,1]
	set iNode [manageFEData -getNode [expr ($j-1)],98]
	if {$inputs(numDims) == 3} {
		element elasticBeamColumn $eleTag $iNode $jNode [expr 100*$inputs(typA)] $E $G [expr $inputs(typJ)/1000] [expr $inputs(typIy)/1000.] [expr $inputs(typIz)/1000.] $clmnTrans
	} else {
		element elasticBeamColumn $eleTag $iNode $jNode [expr 100*$inputs(typA)] $E [expr $inputs(typIz)/1000.] $clmnTrans
	}
	set leanClmn($j) $eleTag

	#rigid link
	if {$inputs(numDims) == 2} {
		set eleTag [manageFEData -newElement $j,2]
		set iNode $jNode
		set jNode $masterNode($j)
		element elasticBeamColumn $eleTag $iNode $jNode [expr 100*$inputs(typA)] $E [expr $inputs(typIz)/1000.] $beamTrans
	}
}
pattern Plain 3 Linear {
	for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
		if {$j == $inputs(nFlrs)} {
			set dead $inputs(deadRoof)
			set live $inputs(liveRoof)
		} else {
			set dead $inputs(deadFloor)
			set live $inputs(liveFloor)
		}
		set load [expr ($inputs(deadMassFac)*$dead+$inputs(liveMassFac)*$live)*$inputs(leaningArea)*$g]
		if {$inputs(numDims) == 3} {
			load [manageFEData -getNode $j,98] 0. 0 -$load 0. 0. 0.
		} else {
			load [manageFEData -getNode $j,98] 0. -$load 0.
		}
	}
}

