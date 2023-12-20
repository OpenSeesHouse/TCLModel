puts "~~~~~~~~~~~~~~~~~~~~~ defining recorders ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "~~~~~~~~~~~~~~~~~~~~~ defining recorders ~~~~~~~~~~~~~~~~~~~~~\n"
# recorder display Frame 10 10 500 500 -wipe
# vup 0 1 0
# prp 0 0 1000000
# display 1 1 1
#define recorders
if {[info exists inputs(recordCADSees)] == 0} {
	set inputs(recordCADSees) 0
}
file mkdir $inputs(resFolder)/envelopeDrifts
# file mkdir $inputs(resFolder)/Drifts
if {$inputs(numDims) == 3} {
	file mkdir $inputs(resFolder)/envelopeAccels
	set perpDirn 3
	set baseCrnrs ""
	set roofCrnrs ""
	foreach "i k" $inputs(cornerGrdList) {
		set tag [manageFEData -getNode "0,$k,$i,1"]
		lappend baseCrnrs $tag
		set tag [manageFEData -getNode "$inputs(nFlrs),$k,$i,1"]
		lappend roofCrnrs $tag
	}
	set rnTag [manageFEData -getNode $roofNode]
	set bnTag [manageFEData -getNode $baseNode]
	eval "recorder Drift -file $inputs(resFolder)/globalDriftX.out -time -iNode $bnTag -jNode $rnTag -dof 1 -perpDirn $perpDirn"
	if {$inputs(analType) == "push"} {
		eval "recorder Drift -file $inputs(resFolder)/globalDriftY.out -time -iNode $bnTag -jNode $rnTag -dof 2 -perpDirn $perpDirn"
		eval "recorder Drift -file $inputs(resFolder)/globalDriftR.out -time -iNode $bnTag -jNode $rnTag -dof 6 -perpDirn $perpDirn"
	}
	# eval "recorder EnvelopeDrift -file $inputs(resFolder)/globalDriftCNX.out -time -process maxAbs -iNode $baseCrnrs -jNode $roofCrnrs -dof 1 -perpDirn $perpDirn"
	# eval "recorder EnvelopeDrift -file $inputs(resFolder)/globalDriftCNY.out -time -process maxAbs -iNode $baseCrnrs -jNode $roofCrnrs -dof 2 -perpDirn $perpDirn"
} else {
	set perpDirn 2
	set bsnTag [manageFEData -getNode $baseNode]
	set rnTag [manageFEData -getNode $roofNode]
	eval "recorder Drift -file $inputs(resFolder)/globalDriftX.out -time -iNode $bsnTag -jNode $rnTag -dof 1 -perpDirn 2"
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
set nd1 [manageFEData -getNode $baseNode]
set allNodes $nd1
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set nd2 [manageFEData -getNode $masterNode($j)]
	if {$inputs(numDims) == 2} {
		set recTags($j) [eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CMX$j.out -iNode $nd1 -jNode $nd2 -dof 1 -perpDirn $perpDirn"]
		if {$inputs(doFreeVibrate)} {
			set recTagsAmp($j) [eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CMX$j-amp.out -iNode $nd1 -jNode $nd2 -dof 1 -perpDirn $perpDirn"]
		}
	} else {
		set crnrNds ""
		foreach "i k" $inputs(cornerGrdList) {
			set tag [manageFEData -getNode $j,$k,$i,1]
			lappend crnrNds $tag
		}
		set recTags([expr 2*$j-1]) [eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CMX$j.out -iNode $nd1 -jNode $nd2 -dof 1 -perpDirn $perpDirn"]
		set recTags([expr 2*$j-0]) [eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CMY$j.out -iNode $nd1 -jNode $nd2 -dof 2 -perpDirn $perpDirn"]
		if {$inputs(doFreeVibrate)} {
			set recTagsAmp([expr 2*$j-1]) [eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CMX$j-amp.out -iNode $nd1 -jNode $nd2 -dof 1 -perpDirn $perpDirn"]
			set recTagsAmp([expr 2*$j-0]) [eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CMY$j-amp.out -iNode $nd1 -jNode $nd2 -dof 2 -perpDirn $perpDirn"]
		}
		eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CMR$j.out -iNode $nd1 -jNode $nd2 -dof 6 -perpDirn $perpDirn"
		eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CNX$j-max.out -process maxAbs -iNode $baseCrnrs -jNode $crnrNds -dof 1 -perpDirn $perpDirn"
		eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CNY$j-max.out -process maxAbs -iNode $baseCrnrs -jNode $crnrNds -dof 2 -perpDirn $perpDirn"
		eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CNX$j.out                     -iNode $baseCrnrs -jNode $crnrNds -dof 1 -perpDirn $perpDirn"
		eval "recorder EnvelopeDrift -file $inputs(resFolder)/envelopeDrifts/CNY$j.out                     -iNode $baseCrnrs -jNode $crnrNds -dof 2 -perpDirn $perpDirn"
		# recorder Drift -file $inputs(resFolder)/Drifts/$j.out -iNode $iNode -jNode $jNode -dof 1 2 6 -perpDirn $perpDirn
		set baseCrnrs $crnrNds
		if {$inputs(numDims) == 3 && [info exists seriesTagX]} {
			eval "recorder EnvelopeNode -file $inputs(resFolder)/envelopeAccels/CNX$j.out -node $crnrNds -timeSeries $seriesTagX -dof 1 accel"
			eval "recorder EnvelopeNode -file $inputs(resFolder)/envelopeAccels/CNY$j.out -node $crnrNds -timeSeries $seriesTagY -dof 2 accel"
		}
	}
	lappend allNodes $nd2
	set nd1 $nd2
}
if [info exists seriesTagX] {
	eval "recorder EnvelopeNode -file $inputs(resFolder)/envelopeAccels/allCMX.out -node $allNodes -timeSeries $seriesTagX -dof 1 accel"
	if {$inputs(numDims) == 3} {
		eval "recorder EnvelopeNode -file $inputs(resFolder)/envelopeAccels/allCMY.out -node $allNodes -timeSeries $seriesTagY -dof 2 accel"
	}
}

# eval "recorder EnvelopeNode -file $inputs(resFolder)/envbaseReacts.out -node $slaveNodeList(0) -dof 1 2 6 reaction"
# eval "recorder Node -file $inputs(resFolder)/baseReacts.out -node $slaveNodeList(0) -dof 1 2 6 reaction"

for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set shearList($j) ""
}
#TODO add gusset elements to the story shear element list

foreach typ "Hinge Fiber" {
	#beam recorders
	# file mkdir $inputs(resFolder)/beamForces-$typ
	file mkdir $inputs(resFolder)/beamDuctils-$typ
	file mkdir $inputs(resFolder)/beamRtns-$typ
	file mkdir $inputs(resFolder)/beamEnergies-$typ
	set timeStr ""
	for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
		set list ""
		set list2 ""
		set list1 ""
		foreach dir "Y X" nGridX "[expr $inputs(nBaysX)+1] $inputs(nBaysX)" nGridY "$inputs(nBaysY) [expr $inputs(nBaysY)+1]" {
			for {set k 1} {$k <= $nGridY} {incr k} {
				for {set i 1} {$i <= $nGridX} {incr i} {
					set eleCode [eleCodeMap $dir-Beam]
					set elePos $j,$k,$i
					set sec $eleData(section,$eleCode,$elePos,1)
					if {$sec == "-"} {
						continue
					}
					set sg $eleData(SG,$eleCode,$elePos)
					if {$inputs($sg,eleType) != "Hinge" && $typ == "Hinge"} {
						continue
					}
					if {$inputs($sg,eleType) == "Hinge" && $typ == "Fiber"} {
						continue
					}
					if {$typ == "Hinge"} {
						lappend list1 [manageFEData -getElement $eleCode,$elePos,h1]
						lappend list2 [manageFEData -getElement $eleCode,$elePos,h2]
					} else {
						set nSeg $eleData(numSeg,$eleCode,$elePos)
						for {set iSeg 1} {$iSeg <= $nSeg}  {incr iSeg} {
							set eleTag [manageFEData -getElement "$eleCode,$elePos,$iSeg"]
							lappend list $eleTag
						}
					}
				}
			}
		}
		if {$typ == "Hinge" && $list1 != ""} {
			eval "recorder EnvelopeElement -file $inputs(resFolder)/beamDuctils-$typ/sec-1story$j.out $timeStr -ele $list1 material 1 ductility"
			eval "recorder EnvelopeElement -file $inputs(resFolder)/beamDuctils-$typ/sec-2story$j.out $timeStr -ele $list2 material 1 ductility"
			eval "recorder EnvelopeElement -file $inputs(resFolder)/beamRtns-$typ/sec-1story$j.out $timeStr -ele $list1 material 1 strain"
			eval "recorder EnvelopeElement -file $inputs(resFolder)/beamRtns-$typ/sec-2story$j.out $timeStr -ele $list2 material 1 strain"
			eval "recorder ResidElement -file $inputs(resFolder)/beamEnergies-$typ/sec-1story$j.out -ele $list1 material 1 energy"
			eval "recorder ResidElement -file $inputs(resFolder)/beamEnergies-$typ/sec-2story$j.out -ele $list2 material 1 energy"
		} elseif {$list != ""} {
			if {$inputs(numDims) == 3} {
				set forceDOFs "1 5 6 7 11 12"
				set rotDOFs "2 3"			;# basic 1~6: eps, thetaZ_1, thetaZ_2, thetaY_1, thetaY_2, thetaX
			} else {
				set forceDOFs "1 3 6"
				set rotDOFs "2 3"				;# basic 1~3: eps, thetaZ_1, thetaZ_2
			}
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/beamForces/$j.out $timeStr -process maxAbs -ele $list -dof $forceDOFs localForce"
			eval "recorder EnvelopeElement -file $inputs(resFolder)/beamDuctils-$typ/$j.out $timeStr -ele $list  maxDuctility"
			eval "recorder EnvelopeElement -file $inputs(resFolder)/beamRtns-$typ/$j.out $timeStr -ele $list -dof $rotDOFs basicDeformation"
			eval "recorder ResidElement -file $inputs(resFolder)/beamEnergies-$typ/$j.out $timeStr -ele $list energy"
			# for {set secNum 1} {$secNum <= $numIntegPnts} {incr secNum} {
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/beamForces/sec-[set secNum]story[set j].out $timeStr -ele $list section $secNum force"
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/beamDuctils/sec-[set secNum]story[set j].out $timeStr -ele $list2 section $secNum maxDuctility"
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/beamRtns/sec-[set secNum]story[set j].out $timeStr -ele $list2 section $secNum maxStrain"
			# eval "recorder ResidElement -file $inputs(resFolder)/beamEnergies/sec-[set secNum]story[set j].out -ele $list section $secNum energy"
			# }
		}
	}

	#Column recorders
	# file mkdir $inputs(resFolder)/clmnForces-$typ
	file mkdir $inputs(resFolder)/storyShears
	file mkdir $inputs(resFolder)/clmnDuctils-$typ
	file mkdir $inputs(resFolder)/clmnEnergies-$typ
	file mkdir $inputs(resFolder)/clmnRtns-$typ
	set eleCode [eleCodeMap Column]
	for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
		set list ""
		set list2 ""
		set list1 ""
		for {set i 1} {$i <= [expr $inputs(nBaysX)+1]} {incr i} {
			for {set k 1} {$k <= [expr $inputs(nBaysY)+1]} {incr k} {
				set elePos $j,$k,$i
				set sec $eleData(section,$eleCode,$elePos)
				if {$sec == "-"} continue
				set sg $eleData(SG,$eleCode,$elePos)
				if {$inputs($sg,eleType) != "Hinge" && $typ == "Hinge"} {
					continue
				}
				if {$inputs($sg,eleType) == "Hinge" && $typ == "Fiber"} {
					continue
				}
				if {$typ == "Hinge"} {
					set eleTag [manageFEData -getElement $eleCode,$elePos]
					lappend list $eleTag
					lappend list1 [manageFEData -getElement $eleCode,$elePos,h1]
					lappend list2 [manageFEData -getElement $eleCode,$elePos,h2]
					lappend shearList($j) $eleTag
				} else {
					lappend shearList($j) [manageFEData -getElement "$eleCode,$elePos,1"]
					set nSeg $eleData(numSeg,$eleCode,$elePos)
					for {set iSeg 1} {$iSeg <= $nSeg}  {incr iSeg} {
						set eleTag [manageFEData -getElement "$eleCode,$elePos,$iSeg"]
						lappend list $eleTag
					}
					# foreach iSeg $recMemSegs {
					# set eleTag [manageFEData -getElement [expr $elePos*100+$iSeg]]
					# lappend list2 $eleTag
					# }
				}
			}
		}
		if {$typ == "Hinge" && $list1 != ""} {
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnForces/sec-1story$j.out $timeStr -ele $list1 force"
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnForces/sec-2story$j.out $timeStr -ele $list2 force"
			eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnDuctils-$typ/sec-1story$j.out $timeStr -ele $list1 material 1 ductility"
			eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnDuctils-$typ/sec-2story$j.out $timeStr -ele $list2 material 1 ductility"
			eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnRtns-$typ/sec-1story$j.out $timeStr -ele $list1 material 1 strain"
			eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnRtns-$typ/sec-2story$j.out $timeStr -ele $list2 material 1 strain"
			eval "recorder ResidElement -file $inputs(resFolder)/clmnEnergies-$typ/sec-1story$j.out -ele $list1 material 1 energy"
			eval "recorder ResidElement -file $inputs(resFolder)/clmnEnergies-$typ/sec-2story$j.out -ele $list2 material 1 energy"
		} elseif {$list != ""} {
			if {$inputs(numDims) == 3} {
				set forceDOFs "1 5 6 7 11 12"
				set rotDOFs "1 4 2 5 3 6"
			} else {
				set forceDOFs "1 3 6"
				set rotDOFs "2 3"
			}
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnForces/$j.out $timeStr -process maxAbs -ele $list -dof $forceDOFs localForce"
			eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnDuctils-$typ/$j.out $timeStr -ele $list  maxDuctility"
			eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnRtns-$typ/$j.out $timeStr -ele $list -dof $rotDOFs basicDeformation"
			eval "recorder ResidElement -file $inputs(resFolder)/clmnEnergies-$typ/$j.out $timeStr -ele $list energy"
			# for {set secNum 1} {$secNum <= $numIntegPnts} {incr secNum} {
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnForces/sec-[set secNum]story[set j].out $timeStr -ele $list section $secNum force"
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnDuctils/sec-[set secNum]story[set j].out $timeStr -ele $list section $secNum maxDuctility"
			# eval "recorder EnvelopeElement -file $inputs(resFolder)/clmnRtns/sec-[set secNum]story[set j].out $timeStr -ele $list section $secNum maxStrain"
			# eval "recorder ResidElement -file $inputs(resFolder)/clmnEnergies/sec-[set secNum]story[set j].out -ele $list section $secNum energy"
			# }
		}
	}
}
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	if {$inputs(analType) == "push"} {
		set shearRec Element
	} else {
		set shearRec EnvelopeElement
	}
	if [info exists leanClmn] {
		lappend shearList($j) [manageFEData -getElement $leanClmn($j)]
	}
	eval "recorder $shearRec -file $inputs(resFolder)/storyShears/X$j.out $timeStr -process sum -ele $shearList($j) -dof 1 force"
	if {$inputs(numDims) == 3} {
		eval "recorder $shearRec -file $inputs(resFolder)/storyShears/Y$j.out $timeStr -process sum -ele $list $shearList($j) -dof 2 force"
	}
}
