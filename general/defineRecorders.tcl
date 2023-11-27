#define recorders
file mkdir $inputs(resFolder)/envelopeDrifts
# file mkdir $inputs(resFolder)/Drifts
if {$inputs(numDims) == 3} {
	set perpDirn 3
	# set baseCrnrs ""
	set roofCrnrs ""
	foreach "i k" $inputs(cornerGrdList) {
		set tag [manageTags -getNode "0,$k,$i,1"]
		lappend baseCrnrs $tag
		set tag [manageTags -getNode "$inputs(nFlrs),$k,$i,1"]
		lappend roofCrnrs $tag
	}
	eval "recorder Drift -file $inputs(resFolder)/globalDriftX.out -time -iNode $baseNode -jNode $roofNode -dof 1 -perpDirn $perpDirn"
	eval "recorder Drift -file $inputs(resFolder)/globalDriftY.out -time -iNode $baseNode -jNode $roofNode -dof 2 -perpDirn $perpDirn"
	eval "recorder Drift -file $inputs(resFolder)/globalDriftR.out -time -iNode $baseNode -jNode $roofNode -dof 6 -perpDirn $perpDirn"
	eval "recorder EnvelopeDrift -file $inputs(resFolder)/globalDriftCNX.out -time -process maxAbs -iNode $baseCrnrs -jNode $roofCrnrs -dof 1 -perpDirn $perpDirn"
	eval "recorder EnvelopeDrift -file $inputs(resFolder)/globalDriftCNY.out -time -process maxAbs -iNode $baseCrnrs -jNode $roofCrnrs -dof 2 -perpDirn $perpDirn"
} else {
	set perpDirn 2
	eval "recorder Drift -file $inputs(resFolder)/globalDriftX.out -time -iNode $baseNode -jNode $roofNode -dof 1 -perpDirn 2"
}
if {[info exists inputs(recordCADSees)] == 0} {
	set inputs(recordCADSees) 0
}
if {$inputs(recordCADSees)} {
	set allNodes [getNodeTags]
	if {$inputs(numDims) == 2} {
		eval "recorder Node -file $inputs(resFolder)/allNodeDisps.out -time -node $allNodes -dof 1 2 3 disp"
	} else {
		eval "recorder Node -file $inputs(resFolder)/allNodeDisps.out -time -node $allNodes -dof 1 2 3 4 5 6 disp"
	}
	return
}
set nd1 $refNode(0)
set allNodes $nd1
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	if {$inputs(numDims) == 2} {
		set nd2 $refNode($j)
		set recTags($j) [eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CMX$j.out -time -iNode $nd1 -jNode $nd2 -dof 1 -perpDirn $perpDirn"]
		# recorder Drift -file $inputs(resFolder)/Drifts/$j.out -time -iNode $iNode -jNode $jNode -dof 1 -perpDirn $perpDirn
	} else {
		set crnrNds ""
		foreach "i k" $inputs(cornerGrdList) {
			set tag [manageTags -getNode $j,$k,$i,1]
			lappend crnrNds $tag
		}
		set nd2 [manageTags -getNode "$j,99"]
		set recTags([expr 2*$j-1]) [eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CMX$j.out -time -iNode $nd1 -jNode $nd2 -dof 1 -perpDirn $perpDirn"]
		set recTags([expr 2*$j-0]) [eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CMY$j.out -time -iNode $nd1 -jNode $nd2 -dof 2 -perpDirn $perpDirn"]
		eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CMR$j.out -time -iNode $nd1 -jNode $nd2 -dof 6 -perpDirn $perpDirn"
		eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CNX$j.out -time -process maxAbs -iNode $baseCrnrs -jNode $crnrNds -dof 1 -perpDirn $perpDirn"
		eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CNY$j.out -time -process maxAbs -iNode $baseCrnrs -jNode $crnrNds -dof 2 -perpDirn $perpDirn"
		# recorder Drift -file $inputs(resFolder)/Drifts/$j.out -time -iNode $iNode -jNode $jNode -dof 1 2 6 -perpDirn $perpDirn
		set baseCrnrs $crnrNds
	}
	lappend allNodes $nd2
	set nd1 $nd2
}
if [info exists seriesTagX] {
	eval "recorder EnvelopeNode -file $inputs(resFolder)/allStoryAccelsX.out -node $allNodes -timeSeries $seriesTagX -dof 1 accel"
	if {$inputs(numDims) == 3} {
		eval "recorder EnvelopeNode -file $inputs(resFolder)/allStoryAccelsY.out -node $allNodes -timeSeries $seriesTagY -dof 2 accel"
	}
}

# eval "recorder EnvelopeNode -file $inputs(resFolder)/envbaseReacts.out -time -node $slaveNodeList(0) -dof 1 2 6 reaction"
# eval "recorder Node -file $inputs(resFolder)/baseReacts.out -time -node $slaveNodeList(0) -dof 1 2 6 reaction"

#beam recorders
# file mkdir $inputs(resFolder)/beamForces
file mkdir $inputs(resFolder)/beamDuctils
file mkdir $inputs(resFolder)/beamRtns
file mkdir $inputs(resFolder)/beamEnergies
set timeStr ""
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set list ""
	set list2 ""
	set list1 ""
	set file [open $inputs(resFolder)/beamTags.out w]
	foreach dir "Y X" nGridX "[expr $inputs(nBaysX)+1] $inputs(nBaysX)" nGridY "$inputs(nBaysY) [expr $inputs(nBaysY)+1]" {
		logCommands -comment "### $dir-dir Beams\n"
		for {set k 1} {$k <= $nGridY} {incr k} {
			for {set i 1} {$i <= $nGridX} {incr i} {
				set eleCode [eleCodeMap $dir-Beam]
				set elePos $j,$k,$i
				set sec $eleData(section,$eleCode,$elePos,1)
				if {$sec == "-"} {
					continue
				}
				if {$inputs(beamType) == "Hinge"} {
					set eleTag [manageTags -getElement $eleCode,$elePos]
					puts $file "$dir $i $k"
					lappend list $eleTag
					lappend list1 [manageTags -getElement $eleCode,$elePos,1]
					lappend list2 [manageTags -getElement $eleCode,$elePos,2]
				} else {
					set nSeg $inputs(numSegBeam)
					for {set iSeg 1} {$iSeg <= $nSeg}  {incr iSeg} {
						set eleTag [manageTags -getElement "$eleCode,$elePos,$iSeg"]
						lappend list $eleTag
						puts $file "Y $i $k $iSeg"
					}
					# foreach iSeg $recMemSegs {
						# set eleTag [manageTags -getElement [expr $elePos*100+$iSeg]]
						# lappend list2 $eleTag
						# puts $file "Y $i $k $iSeg"
					# }
				}
			}
		}
	}
	close $file
	if {$inputs(beamType) == "Hinge"} {
		#eval "recorder EnvelopeElement -file $inputs(resFolder)/beamForces/sec-1story$j.out $timeStr -ele $list1 force"		
		#eval "recorder EnvelopeElement -file $inputs(resFolder)/beamForces/sec-2story$j.out $timeStr -ele $list2 force"		
		#eval "recorder EnvelopeElement -file $inputs(resFolder)/beamDuctils/sec-1story$j.out $timeStr -ele $list1 material 1 ductility"		
		#eval "recorder EnvelopeElement -file $inputs(resFolder)/beamDuctils/sec-2story$j.out $timeStr -ele $list2 material 1 ductility"		
		#eval "recorder EnvelopeElement -file $inputs(resFolder)/beamRtns/sec-1story$j.out $timeStr -ele $list1 material 1 strain"		
		#eval "recorder EnvelopeElement -file $inputs(resFolder)/beamRtns/sec-2story$j.out $timeStr -ele $list2 material 1 strain"		
		#eval "recorder ResidElement -file $inputs(resFolder)/beamEnergies/sec-1story$j.out -ele $list1 material 1 energy"		
		#eval "recorder ResidElement -file $inputs(resFolder)/beamEnergies/sec-2story$j.out -ele $list2 material 1 energy"		
	} else {
		if {$inputs(numDims) == 3} {
			set forceDOFs "1 5 6 7 11 12"
			set rotDOFs "2 3"			;# basic 1~6: eps, thetaZ_1, thetaZ_2, thetaY_1, thetaY_2, thetaX
		} else {
			set forceDOFs "1 3 6"
			set rotDOFs "2 3"				;# basic 1~3: eps, thetaZ_1, thetaZ_2
		}
		# eval "recorder EnvelopeElement -file $inputs(resFolder)/beamForces/$j.out $timeStr -process maxAbs -procGrpNum $inputs(numSegBeam) -ele $list -dof $forceDOFs localForce"
		eval "recorder EnvelopeElement -file $inputs(resFolder)/beamDuctils/$j.out $timeStr -ele $list  maxDuctility"
		eval "recorder EnvelopeElement -file $inputs(resFolder)/beamRtns/$j.out $timeStr -process maxAbs -procGrpNum $inputs(numSegBeam) -ele $list -dof $rotDOFs basicDeformation"
		eval "recorder ResidElement -file $inputs(resFolder)/beamEnergies/$j.out $timeStr -ele $list energy"
		# for {set secNum 1} {$secNum <= $numIntegPnts} {incr secNum} {
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/beamForces/sec-[set secNum]story[set j].out $timeStr -ele $list section $secNum force"
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/beamDuctils/sec-[set secNum]story[set j].out $timeStr -ele $list2 section $secNum maxDuctility"
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/beamRtns/sec-[set secNum]story[set j].out $timeStr -ele $list2 section $secNum maxStrain"
			# eval "recorder ResidElement -file $inputs(resFolder)/beamEnergies/sec-[set secNum]story[set j].out -ele $list section $secNum energy"
		# }
	}
}

#Column recorders
# file mkdir $inputs(resFolder)/clmnForces
file mkdir $inputs(resFolder)/storyShears
file mkdir $inputs(resFolder)/clmnDuctils
file mkdir $inputs(resFolder)/clmnEnergies
file mkdir $inputs(resFolder)/clmnRtns
set eleCode [eleCodeMap Column]
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set list ""
	set list2 ""
	set list1 ""
	set file [open $inputs(resFolder)/clmnTags.out w]
	for {set i 1} {$i <= [expr $inputs(nBaysX)+1]} {incr i} {
		for {set k 1} {$k <= [expr $inputs(nBaysY)+1]} {incr k} {
			set elePos $j,$k,$i
			set sec $eleData(section,$eleCode,$elePos)
			if {$sec == "-"} continue
			if {$inputs(columnType) == "Hinge"} {
				set eleTag [manageTags -getElement $eleCode,$elePos]
				puts $file "$i $k"
				lappend list $eleTag
				lappend list1 [manageTags -getElement $eleCode,$elePos,1]
				lappend list2 [manageTags -getElement $eleCode,$elePos,2]
			} else {
				set nSeg $numSegClmn
				for {set iSeg 1} {$iSeg <= $nSeg}  {incr iSeg} {
					set eleTag [manageTags -getElement "$eleCode,$elePos,$iSeg"]
					lappend list $eleTag
					puts $file "$i $k $iSeg"
				}
				# foreach iSeg $recMemSegs {
					# set eleTag [manageTags -getElement [expr $elePos*100+$iSeg]]
					# lappend list2 $eleTag
					# puts $file "Y $i $k $iSeg"
				# }
			}
		}
	}
	close $file
	if {$inputs(columnType) == "Hinge"} {
#		eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnForces/sec-1story$j.out $timeStr -ele $list1 force"		
#		eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnForces/sec-2story$j.out $timeStr -ele $list2 force"		
#		eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnDuctils/sec-1story$j.out $timeStr -ele $list1 material 1 ductility"		
#		eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnDuctils/sec-2story$j.out $timeStr -ele $list2 material 1 ductility"		
#		eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnRtns/sec-1story$j.out $timeStr -ele $list1 material 1 strain"		
#		eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnRtns/sec-2story$j.out $timeStr -ele $list2 material 1 strain"		
#		eval "recorder ResidElement -file $inputs(resFolder)/clmnEnergies/sec-1story$j.out -ele $list1 material 1 energy"		
#		eval "recorder ResidElement -file $inputs(resFolder)/clmnEnergies/sec-2story$j.out -ele $list2 material 1 energy"		
	} else {
		if {$inputs(numDims) == 3} {
			set forceDOFs "1 5 6 7 11 12"
			set rotDOFs "1 4 2 5 3 6"
		} else {
			set forceDOFs "1 3 6"
			set rotDOFs "2 3"
		}
		# eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnForces/$j.out $timeStr -process maxAbs -procGrpNum $numSegClmn -ele $list -dof $forceDOFs localForce"
		eval "recorder EnvelopeElement -file $inputs(resFolder)/storyShears/X$j.out $timeStr -process sum -ele $list -dof 1 force"
		if {$inputs(numDims) == 3} {
			eval "recorder EnvelopeElement -file $inputs(resFolder)/storyShears/Y$j.out $timeStr -process sum -ele $list -dof 2 force"
		}
		eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnDuctils/$j.out $timeStr -ele $list  maxDuctility"
		eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnRtns/$j.out $timeStr -process maxAbs -procGrpNum $numSegClmn -ele $list -dof $rotDOFs basicDeformation"
		eval "recorder ResidElement -file $inputs(resFolder)/clmnEnergies/$j.out $timeStr -ele $list energy"
		# for {set secNum 1} {$secNum <= $numIntegPnts} {incr secNum} {
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnForces/sec-[set secNum]story[set j].out $timeStr -ele $list section $secNum force"
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnDuctils/sec-[set secNum]story[set j].out $timeStr -ele $list section $secNum maxDuctility"
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnRtns/sec-[set secNum]story[set j].out $timeStr -ele $list section $secNum maxStrain"
			# eval "recorder ResidElement -file $inputs(resFolder)/clmnEnergies/sec-[set secNum]story[set j].out -ele $list section $secNum energy"
		# }
	}
}
