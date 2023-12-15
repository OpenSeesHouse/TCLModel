source $inputs(generalFolder)/Box-section.tcl
source $inputs(generalFolder)/I-section.tcl
source $inputs(generalFolder)/computePanelZone.tcl
source $inputs(generalFolder)/computeHingeHSS.tcl
source $inputs(generalFolder)/computeHingeRBS.tcl
source $inputs(generalFolder)/computeHingeWBeam.tcl
source $inputs(generalFolder)/computeHingeWColumn.tcl

set tag [manageFEData -newMaterial elastic]
set E $inputs(Es)
set G [expr $E/2.6]
uniaxialMaterial Elastic $tag $inputs(Es)

set tag [manageFEData -newMaterial rigid]
source "$inputs(secFolder)/$typSec.tcl"
source "$inputs(secFolder)/convertToM.tcl"
set inputs(typA) $Area
set inputs(typIz) $I33
set inputs(typIy) $I22
set inputs(typJ) $J

uniaxialMaterial Elastic $tag [expr 100*$inputs(typA)*$inputs(Es)/$inputs(hStory)]

	set tag [manageFEData -newMaterial fiberBeams]
	uniaxialMaterial Steel02 $tag $inputs(fyBeam) $E 0.01
	# uniaxialMaterial Elastic 1 $E

	set tag [manageFEData -newMaterial fiberClmns]
	uniaxialMaterial Steel02 $tag $inputs(fyClmn) $E 0.01
	# uniaxialMaterial Elastic 2 $E

set matTag [manageFEData -getMaterial fiberBeams]
set cUnitsToKsi [expr $inputs(cUnitsToN)/($inputs(cUnitsToM)**2.)*1.45038e-7]
set cUnitToIn [expr $inputs(cUnitsToM)/0.0254]
set N 0.
set N0 0.
set ID 5
set beamList ""
logCommands -comment "#~~~~ beam sections ~~~~\n"
#beam sections/M-Theta's
set fy $inputs(fyBeam)
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	foreach dir "X Y" nGridX "$inputs(nBaysX) [expr $inputs(nBaysX)+1]" nGridY "[expr $inputs(nBaysY)+1] $inputs(nBaysY)" {
		for {set k 1} {$k <= $nGridY} {incr k} {
			for {set i 1} {$i <= $nGridX} {incr i} {
				set code [eleCodeMap $dir-Beam]
				set pos "$j,$k,$i"
				if {$dir == "X"} {
					set L $LBayArrX($i)
				} else {
					set L $LBayArrY($k)
				}
				# set Ls [expr $L/2]
				set Ls [expr $L]
				set sec $eleData(section,$code,$pos,1)
				if {$sec == "-"} continue
				source "$inputs(secFolder)/$sec.tcl"
				source "$inputs(secFolder)/convertToM.tcl"
				# puts $beamPropFile "$sec $dir $tetay $tetau $my"
				set sg $eleData(SG,$code,$pos)
				if {$inputs($sg,eleType) == "Hinge"} {
					logCommands -comment "#section: $sec j,k,i,dir: $j,$k,$i,$dir\n"
					set ID [manageFEData -newMaterial beamHinge,$j,$k,$i,$dir]
					if {$inputs(hingeType) == "Lignos"} {
						if {$Shape == "SteelTube"} {
							computeHingeHSS $ID $t3 $tf $t2 $tw $Z33 $I33 $Ls $N $Area $fy $cUnitsToKsi $inputs(MyFac)
						} elseif {$Shape == "I"} {
							if {$inputs(useRBSBeams)} {
								computeHingeRBS		$ID $t3 $tw $t2 $tf $I33 $Z33 $Ls $inputs(lbToRy) $inputs(Es) $fy $inputs(beamRy) $inputs(nFactor) $cUnitToIn $cUnitsToKsi
							} else {
								computeHingeWBeam	$ID $t3 $tw $t2 $tf $I33 $Z33 $Ls $inputs(lbToRy) $inputs(Es) $fy $inputs(beamRy) $inputs(nFactor) $inputs(MyFac) $cUnitToIn $cUnitsToKsi $inputs(isBeamA992Gr50)
							}
						}
					} else {
						source $inputs(generalFolder)/computeHingeASCEStrong.tcl
						set tetau [expr $tetay+$b]
						set resFac $c
						uniaxialMaterial Bilin $ID $ke $alfah $alfah $my -$my $Lamda 0\
							0 0 1 0 0 0 $tetap $tetap $tetapc $tetapc $resFac $resFac $tetau $tetau 1 1 $inputs(nFactor)
					}
				} else {
					if {[lsearch $beamList $sec] == -1} {
						logCommands -comment "#section: $sec\n"
						lappend beamList $sec
						set ID [manageFEData -newSection beam,$sec]
						if {$Shape == "SteelTube"} {
							# section Elastic $secTag $E $A $I33 <$I22 $G $J>
							Box-section $matTag $ID $t3 $t2 $tf $tw $inputs(numSubdivL) $inputs(numSubdivT) [expr $G*$J]
						} elseif {$Shape == "I"} {
							I-section $ID $matTag $t3 $t2 $tf $tw $inputs(numSubdivL) $inputs(numSubdivT) $inputs(numSubdivL) $inputs(numSubdivT) [expr $G*$J]
						} else {
							error "~~~~~~Error! Unknown section type: $shape for section: $sec ~~~~~~"
						}
					}
				}
				source $inputs(secFolder)/unsetSecProps.tcl
			}
		}
	}
}
#column sections/M-Theta's
set clmnSecList ""
logCommands -comment "#~~~~ column sections/Panel zone spring material ~~~~\n"
set fy $inputs(fyClmn)
set code [eleCodeMap Column]
set matTag [manageFEData -getMaterial fiberClmns]
set cnt 0
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set L [expr $Z($j)-$Z([expr $j-1])]
	# set Ls [expr $L/2]
	set Ls [expr $L]
	for {set k 1} {$k <= [expr $inputs(nBaysY)+1]} {incr k} {
		for {set i 1} {$i <= [expr $inputs(nBaysX)+1]} {incr i} {
			incr cnt
			set pos "$j,$k,$i"
			set sec $eleData(section,$code,$j,$k,$i)
			if {$sec == "-"} continue
			source "$inputs(secFolder)/$sec.tcl"
			source "$inputs(secFolder)/convertToM.tcl"					
				set sg $eleData(SG,$code,$pos)
			if {$inputs($sg,eleType) == "Hinge"} {
				logCommands -comment "#section: $sec j,k,i: $j,$k,$i\n"
				set ID3 [manageFEData -newMaterial clmnHinge,$j,$k,$i,3]
				set N 0
				if [info exists initAxiForce] {
					set N $initAxiForce($cnt)
				} elseif [info exists columnGravLoad] {
					set N $columnGravLoad($j,$k,$i)
				}
				if {$inputs(hingeType) == "Lignos"} {
					if {$Shape == "SteelTube"} {
						computeHingeHSS $ID3 t3 $tf $t2 $tw $Z33 $I33 $Ls $N $Area $fy $cUnitsToKsi $inputs(MyFac)
						# uniaxialMaterial Elastic $ID [expr ($inputs(nFactor)+1)*$ke]
						manageFEData -setMaterial clmnHinge,$j,$k,$i,2 $ID3
					} elseif {$Shape == "I"} {
						set ID2 [manageFEData -newMaterial clmnHinge,$j,$k,$i,2]
						computeHingeWColumn $ID3 $t3 $tw $t2 $tf $I33 $Z33 $Ls $inputs(lbToRy) $inputs(Es) $fy $inputs(clmnRy) $inputs(nFactor) $inputs(MyFac) $cUnitsToKsi $inputs(isColumnA992Gr50) $Area $N
						computeHingeWColumn $ID2 $t3 $tw $t2 $tf $I22 $Z22 $Ls $inputs(lbToRy) $inputs(Es) $fy $inputs(clmnRy) $inputs(nFactor) $inputs(MyFac) $cUnitsToKsi $inputs(isColumnA992Gr50) $Area $N
					}
				} else {
					source $inputs(generalFolder)/computeHingeASCEStrong.tcl
					set tetau [expr $tetay+$tetap+$tetapc]
					uniaxialMaterial Bilin $ID3 $ke $alfah $alfah $my -$my $Lamda 0\
						0 0 1 0 0 0 $tetap $tetap $tetapc $tetapc 0 0 $tetau $tetau 1 1 $inputs(nFactor)
					# uniaxialMaterial Elastic $ID [expr ($inputs(nFactor)+1)*$ke]
						
					set ID2 [manageFEData -newMaterial clmnHinge,$j,$k,$i,2]
					source $inputs(generalFolder)/computeHingeASCEWeak.tcl
					set tetau [expr $tetay+$tetap+$tetapc]
					uniaxialMaterial Bilin $ID2 $ke $alfah $alfah $my -$my $Lamda 0\
						0 0 1 0 0 0 $tetap $tetap $tetapc $tetapc 0 0 $tetau $tetau 1 1 $inputs(nFactor)
					# uniaxialMaterial Elastic [expr $ID*1000] [expr ($inputs(nFactor)+1)*$ke]
				}
				# uniaxialMaterial Elastic $ID [expr ($inputs(nFactor)+1)*$ke]
			} else {
				if {[lsearch $clmnSecList $sec] == -1} {
					logCommands -comment "#section: $sec\n"
					lappend clmnSecList $sec
					set ID [manageFEData -newSection clmn,$sec]
					if {$Shape == "SteelTube"} {
						Box-section $matTag $ID $t3 $t2 $tf $tw [expr $G*$J]
					} elseif {$Shape == "I"} {
						I-section $ID $matTag $t3 $t2 $tf $tw $inputs(numSubdivL) $inputs(numSubdivT) $inputs(numSubdivL) $inputs(numSubdivT) [expr $G*$J]
					} else {
						error "~~~~~~Error! Unknown section type: $shape for section: $sec ~~~~~~"
					}
				}
			}

			#panel zone springs for X and Y directions
			if {$inputs(usePZSpring) == 0} continue
	error ("this part of code needs revision")
			logCommands -comment "#panel zone material:\n"
			set dc $t3
			#Strong dir.:
			set bf_s $t2
			set tf_s $tf
			set tp_s $tw
			if {$Shape == "SteelTube"} {
				set tp_s [expr 2*$tw]
			}
			#weak dir.:
			set bf_w [expr $t3-$tf*2]
			set tf_w $tw
			set tp_w [expr 2*$tf]
			source $inputs(secFolder)/unsetSecProps.tcl
			set angle $eleData(angle,$code,$j,$k,$i)
			foreach dir "X Y" {
				set pzIDs($j,$k,$i,$dir) $inputs(rigidMatTag)
				# continue
				set i1 $i
				if {$i1 > $inputs(nBaysX)} {
					set i1 $inputs(nBaysX)
				}
				set k1 $k
				if {$k1 > $inputs(nBaysY)} {
					set k1 $inputs(nBaysY)
				}
				if {$dir == "X"} {
					set sec $eleData(section,$code,$j,$k1,$i1,1)
					if {$sec == "-" && $i1 > 1} {
						set sec $eleData(section,$code,$j,$k1,[expr $i1-1],1)
					}
					if {$sec == "-" && $i1 < $inputs(nBaysX)} {
						set sec $eleData(section,$code,$j,$k1,[expr $i1+1],1)
					}
				} else {
					set sec $eleData(section,$code,$j,$k1,$i1,1)
					if {$sec == "-" && $k1 > 1} {
						set sec $eleData(section,$code,$j,[expr $k1-1],$i1,1)
					}
					if {$sec == "-" && $k1 < $inputs(nBaysY)} {
						set sec $eleData(section,$code,$j,[expr $k1+1],$i1)
					}
				}
				if {$sec == "-"} continue
				
				incr ID
				logCommands -comment "#Panel Zone material: sec,j,k,i,dir= $sec,$j,$k,$i,$dir\n"
				source "$inputs(secFolder)/$sec.tcl"
				source "$inputs(secFolder)/convertToM.tcl"
				set db $t3
				source $inputs(secFolder)/unsetSecProps.tcl
				
				if {($dir == "X" && $angle == 0) || ($dir == "Y" && $angle == 90)} {
					set bf	$bf_s
					set tf	$tf_s
					set tp	$tp_s
				} else {
					set bf	$bf_w
					set tf	$tf_w
					set tp	$tp_w
				}
				computePanelZone $ID $E $fy $dc $bf $tf $tp $db $inputs(clmnRy) $hardeningRatio
				set pzIDs($j,$k,$i,$dir) $ID
			}
		}
	}
}