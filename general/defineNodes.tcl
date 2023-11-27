puts "~~~~~~~~~~~~~~~~~~~~~ Defining Nodes ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Nodes ~~~~~~~~~~~~~~~~~~~~~\n"
set masterNodeList ""
for {set j 0} {$j <= $inputs(nFlrs)} {incr j} {
	logCommands -comment "### story $j ###\n"
	set masterNode($j) 0
	set slaveNodeList($j) ""
	set mass 0.
	if {$j > 0 && $inputs(numDims) == 2} {
		set mass [expr $diaphMass($j,X)/($inputs(nBaysX)+1)]
	}
	for {set i 1} {$i <= [expr $inputs(nBaysX)+1]} {incr i} {
		for {set k 1} {$k <= [expr $inputs(nBaysY)+1]} {incr k} {
			if {$j == 0} {
				set pos "1,$k,$i"
				set code [eleCodeMap Column]
				if {[info exists eleData(section,$code,$pos)] == 0 || $eleData(section,$code,$pos) == "-"} continue
				set tag [manageTags -newNode $j,$k,$i,1]
				addNode $tag $X($k,$i)	$Y($k,$i)	$Z($j) "-mass $mass $mass 0. 0. 0. 0."
				if {$inputs(numDims) == 3} {
					fix $tag 1 1 1 1 1 1
				} else {
					fix $tag 1 1 1
				}
				lappend slaveNodeList($j) $tag
				set pos "0,$k,$i"
				set pntData(XDim,$pos) 0
				set pntData(YDim,$pos) 0
				set pntData(ZDim,$pos) 0
			} else {
				set numBeams 0
				set ii [expr $i-1]
				set kk [expr $k-1]
				set 	posListX "$j,$k,$i"
				lappend posListX "$j,$k,$ii"
				set posListY 	 "$j,$k,$i"
				lappend posListY "$j,$kk,$i"
				set sumHb 0
				set code [eleCodeMap "X-Beam"]
				foreach pos $posListX {
					if {[info exists eleData(section,$code,$pos,1)] == 0} continue
					if {$eleData(section,$code,$pos,1) == "-"} continue
					source $inputs(secFolder)/$eleData(section,$code,$pos,1).tcl
					source $inputs(secFolder)/convertToM.tcl
					if {$inputs(matType) == "Steel"} {
						set H $t3
					}
					set sumHb [expr $sumHb + $H]
					set beamProps "$Area $I22 $I33 $J"
					incr numBeams
				}
				set code [eleCodeMap "Y-Beam"]
				foreach pos $posListY {
					if {[info exists eleData(section,$code,$pos,1)] == 0} continue
					if {$eleData(section,$code,$pos,1) == "-"} continue
					source $inputs(secFolder)/$eleData(section,$code,$pos,1).tcl
					source $inputs(secFolder)/convertToM.tcl
					if {$inputs(matType) == "Steel"} {
						set H $t3
					}
					set sumHb [expr $sumHb + $H]
					set beamProps "$Area $I22 $I33 $J"
					incr numBeams
				}
				if {$numBeams == 0} continue
				set pos "$j,$k,$i"
				set pntData(ZDim,$pos) [expr $sumHb/$numBeams]
				
				set code [eleCodeMap "Column"]
				set sec $eleData(section,$code,$pos)
				if {$sec == "-"} {
					if [info exists pntData(ZDim,$pos)] {
						set pntData(YDim,$pos) $pntData(ZDim,$pos)
						set pntData(XDim,$pos) $pntData(ZDim,$pos)
					} else {
						set pntData(YDim,$pos) 0
						set pntData(XDim,$pos) 0
					}
				} else {
					source $inputs(secFolder)/$sec.tcl
					source $inputs(secFolder)/convertToM.tcl
					if {$inputs(matType) == "Steel"} {
						set H $t3
						set B $t2
					}
					if {$eleData(angle,$code,$pos) == 0} {
						set pntData(XDim,$pos) $H
						set pntData(YDim,$pos) $B
					} else {
						set pntData(YDim,$pos) $H
						set pntData(XDim,$pos) $B
					}
				}
				# set pntData(ZDim,$pos) 0
				# set pntData(YDim,$pos) 0
				# set pntData(XDim,$pos) 0
				set tag [manageTags -newNode $pos,1]
				lappend slaveNodeList($j) $tag
				addNode $tag $X($k,$i)	$Y($k,$i)	$Z($j) "-mass $mass $mass 0. 0. 0. 0."
				if {$masterNode($j) == 0} {
					set masterNode($j) $tag		;#used in numDim == 2
				}
			}
		}
	}

	if {$inputs(numDims) == 3 && $j != 0} {
		set mass $diaphMass($j,X)
		set massRot $diaphMass($j,R)
		set CMx $inputs(centerMassX)
		set CMy $inputs(centerMassY)
		if {$j == $inputs(nFlrs)} {
			set CMx $inputs(centerMassXRoof)
			set CMy $inputs(centerMassYRoof)
		}
		set masterNode($j) [manageTags -newNode "$j,99"]
		lappend masterNodeList $masterNode($j)
		addNode $masterNode($j) $CMx $CMy $Z($j)	"-mass $mass $mass 0 0 0 $massRot"
		fix $masterNode($j) 0 0 1 1 1 0
		addDiaphragm 3 $masterNode($j) $slaveNodeList($j)
	}
}

if {$inputs(numDims) == 3} {
	set roofNode [manageTags -getNode $inputs(nFlrs),99]
} else {
	set roofNode [manageTags -getNode $inputs(nFlrs),1,1,1]
}
