#define leaning columns
puts "~~~~~~~~~~~~~~~~~~~~~ Defining Leaning Columns ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Leaning Columns ~~~~~~~~~~~~~~~~~~~~~\n"
set j 0
set tag [manageTags -newNode $j,98]
set crdX 0.
if {$inputs(numDims) == 2} {
	set crdX -$X(2)
}
set crdY 0.
addNode $tag $crdX $crdY $Z($j)
lappend slaveNodeList($j) $tag
set clmnTrans [manageTags -newGeomtransf "leaningClmn"]
set beamTrans [manageTags -newGeomtransf "leaningClmnLink"]
if {$inputs(numDims) == 3} {
	eval "geomTransf PDelta $clmnTrans $zAxis(Clmns0)"
	eval "geomTransf Linear $beamTrans $zAxis(XBeams)"
	fix $tag 1 1 1 0 0 0
} else {
	geomTransf PDelta $clmnTrans
	geomTransf Linear $beamTrans
	fix $tag 1 1 0
}
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set jNode [manageTags -newNode $j,98]
	addNode $jNode $crdX $crdY $Z($j)
	# lappend slaveNodeList($j) $tag
	#rigid column:
	set eleTag [manageTags -newElement $j,1]
	set iNode [manageTags -getNode [expr ($j-1)],98]
	if {$inputs(numDims) == 3} {
		element elasticBeamColumn $eleTag $iNode $jNode [expr 100*$inputs(typA)] $E $G [expr $typJ/1000] [expr $typIy/1000.] [expr $typIz/1000.] $clmnTrans
	} else {
		element elasticBeamColumn $eleTag $iNode $jNode [expr 100*$inputs(typA)] $E [expr $typIz/1000.] $clmnTrans
	}
	set leanClmn($j) $eleTag

	#rigid link
	set eleTag [manageTags -newElement $j,2]
	set iNode $jNode
	# set jNode [expr $j*10000+99]
	set jNode $masterNode($j)
	# element zeroLength $eleTag $iNode $jNode -mat $inputs(rigidMatTag) $inputs(rigidMatTag) -dir 1 2 
	if {$inputs(numDims) == 3} {
		element elasticBeamColumn $eleTag $iNode $jNode [expr 100*$inputs(typA)] $E $G [expr $typJ/1000] [expr $typIy/1000.] [expr $typIz/1000.] $beamTrans
	} else {
		element elasticBeamColumn $eleTag $iNode $jNode [expr 100*$inputs(typA)] $E [expr $typIz/1000.] $beamTrans
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
			load [manageTags -getNode $j,98] 0. 0 -$load 0. 0. 0.
		} else {
			load [manageTags -getNode $j,98] 0. -$load 0.
		}
	}
}

