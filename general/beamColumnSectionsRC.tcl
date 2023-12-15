set fc0 $inputs(fc0)
set Ec $inputs(Ec)
set Gc $inputs(Gc)
# set elasticMatTag 1
#uniaxialMaterial Elastic 1 $Ec

set inputs(rigidMatTag) 2

if {$inputs(hasWall)} {
	source $inputs(generalFolder)/RCWallSection.tcl
}
if {$inputs(eleType) == "Hinge" || $inputs(eleType) == "Hinge"} {
	source $inputs(generalFolder)/computeHingeRC.tcl
	source $inputs(generalFolder)/calculateMy.tcl
}
set ID 2
if {$inputs(eleType) != "Hinge" || $inputs(eleType) != "Hinge"} {

	# Steel
	set R0 18;			# control the transition from elastic to plastic branches
	set cR1 0.925;			# control the transition from elastic to plastic branches
	set cR2 0.15;			# control the transition from elastic to plastic branches
	set muSteel 100.
	
	logCommands -comment "#uniaxialMaterial Steel05 tag Fy E  hardeningRat  ductilCapa postCapERat gama c  resFac <R0 cR1 cR2> <a1 a2 a3 a4> <sigInit> (only available in CSS customized OpenSees)\n"
	logCommands -comment "#~~~~ Beams' Reinforcements' material ~~~~\n"
	set beamBarsMatTag 3
	# uniaxialMaterial Steel02 $beamBarsMatTag  $inputs(fyBeam) $inputs(Es) $hardeningRatio $R0 $cR1 $cR2
	uniaxialMaterial Steel05 $beamBarsMatTag $inputs(fyBeam) $inputs(Es) $hardeningRatio $muSteel -0.001	100000  1. 0.00001 $R0 $cR1 $cR2
	
	logCommands -comment "#~~~~ Columns' Reinforcements' material ~~~~\n"
	set clmnBarsMatTag 4
	# uniaxialMaterial Steel02 $clmnBarsMatTag  $inputs(fyClmn) $inputs(Es) $hardeningRatio $R0 $cR1 $cR2
	uniaxialMaterial Steel05 $clmnBarsMatTag $inputs(fyClmn) $inputs(Es) $hardeningRatio $muSteel -0.001	100000  1. 0.00001 $R0 $cR1 $cR2

	logCommands -comment "#~~~~ Unconfined concrete material ~~~~\n"
	logCommands -comment "#uniaxialMaterial Concrete02 matTag fpc epsc0 fpcu epsU lambda ft Ets\n"
	set unconfConc 5
	# set ec0 [expr 2.*$fc0/$Ec]
	set ec0 0.002 ;#FEMA508 and Mander
	## set ecu 0.01
	set ecu [expr (9./8.)*0.008]  ;#saatcioglu and Razi
	# uniaxialMaterial Concrete01 $unconfConc -$fc0 -$ec0 [expr -0.2*$fc0] -$ecu
	set lambda 0.1
	set ftU [expr 0.33*sqrt($fc0*$cUnitToMPa)/$cUnitToMPa]  ;#Wong and vecchio
	set ftU 0
	set Ets [expr $ftU/0.01]
	uniaxialMaterial Concrete01 $unconfConc -$fc0 -$ec0 [expr -0.1*$fc0] -$ecu ;#$lambda $ftU $Ets; #ASCE41

	logCommands -comment "#~~~~ Confined concrete material For Beams ~~~~\n"
	logCommands -comment "#~~~~ uniaxialMaterial ConfinedConcrete02 tag fc0 epsc0 fcu Lambda ft Ets \n"
	logCommands -comment "#	    	<-beam StressUnitToGPa]>\n"
	logCommands -comment "#			<-column B H cover fyh nBarTop dBarTop nBarBot dBarBot nBarInt dBarInt nBarTransH nBarTransB dBarTrans sStirrup>\n"
	set confConcBeam 7
	set cUnitToGPa [expr $cUnitToMPa*1e-3]
	# uniaxialMaterial ConfinedConcrete $confConcBeam -$fc0 -$ec0 [expr -0.1*$fc0] $lambda $ftU $Ets -beam $cUnitToGPa
	uniaxialMaterial ConfinedConcrete $confConcBeam -$fc0 -$ec0 [expr -0.1*$fc0] $lambda $ftU $Ets -beam $cUnitToGPa

	set FRPMatTag 0
	if [info exists FRPAttach] {
		set FRPMatTag 8
		uniaxialMaterial ElasticPPGap $FRPMatTag $FRP_E [expr $FRP_E*$FRP_epsu] 0. -0.1 "damage"
	}

	# ------- walls --------
	# logCommands -comment "#~~~~ Shear wall reinforcements' material ~~~~\n"
	#set wallBarsMatTag 6
	#uniaxialMaterial Steel05 $wallBarsMatTag $wallFy $inputs(Es) $hardeningRatio  10. -0.2	500  1. 0.00001   15. 0 0

	# logCommands -comment "#~~~~ Shear wall unconfined concrete material ~~~~\n"
	# Unconfined concrete
	#set wallEc  [expr 5000.*sqrt($wallFc0*1.e-6)*1.e6]
	#set wallUnconfConc 7
	#set ec0 [expr 2.*$wallFc0/$wallEc]
	#set ecu $wall_ecu
	#set Ets [expr 0.1*$wallEc]
	#set ftFac 0.1
	# uniaxialMaterial Concrete01 $wallUnconfConc -$wallFc0 -$ec0 [expr -0.2*$wallFc0] -$ecu
	#uniaxialMaterial Concrete02 $wallUnconfConc -$wallFc0 -$ec0 [expr -0.2*$wallFc0] -$ecu  0.1 [expr $ftFac*$wallFc0] $Ets

	# logCommands -comment "#~~~~ Shear wall confined concrete material ~~~~\n"
	# Confined concrete
	#set wallConfConc 8
	#set wallFcc [expr 1.4*$wallFc0]
	#set wallEcc  [expr 5000.*sqrt($wallFcc*1.e-6)*1.e6]
	#set ecc [expr 2.*$wallFcc/$wallEcc]
	#set ecu [expr 2*$wall_ecu]
	#set Ets [expr 0.1*$wallEcc]
	#set ftFac 0.1
	# uniaxialMaterial Concrete01 $wallConfConc -$wallFcc -$ecc [expr -0.2*$wallFcc] -$ecu
	#uniaxialMaterial Concrete02 $wallConfConc -$wallFcc -$ecc [expr -0.2*$wallFcc] -$ecu  0.1 [expr $ftFac*$wallFcc] $Ets

	source $inputs(generalFolder)/RCsection.tcl
	set ID 10
}

set wallRigidMatTagAxi 9
set wallRigidMatTagFlx 10
set wallTypicA 0
set inputs(typA) 0


logCommands -comment "#~~~~ beam sections ~~~~\n"
#beam sections/M-Theta's

set beamList ""
set hingList ""
set hingTagList ""
set kRatList ""
set dirList "X Y"
set secArrList "beamSecX beamSecY"
set nGridXList "$inputs(nBaysX) [expr $inputs(nBaysX)+1]"
set nGridYList "[expr $inputs(nBaysY)+1] $inputs(nBaysY)"
if {$inputs(numDims) == 2} {
	set dirList "X"
	set secArrList "beamSecX"
	set nGridXList "$inputs(nBaysX)"
	set nGridYList "1"
}
set cUnitToMPa $inputs(cUnitToMPa)
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	foreach dir $dirList secArr $secArrList nGridX $nGridXList nGridY $nGridYList {
		for {set k 1} {$k <= $nGridY} {incr k} {
			for {set i 1} {$i <= $nGridX} {incr i} {
				for {set iStat 1} {$iStat <= $inputs(numDesnStats)} {incr iStat} {
					if {$dir == "X"} {
						set L $LBayArrX($i)
					} else {
						set L $LBayArrY($k)
					}
					eval "set sec $[set secArr]($j,$k,$i,$iStat)"
					# puts "$sec ($j,$k,$i)"
					if {$sec == "-"} continue
					source "$inputs(secFolder)/$sec.tcl"
					source "$inputs(secFolder)/convertToM.tcl"
					set GJ [expr $Gc*$J]
					if {$inputs(eleType) == "Hinge"} {
						set hingChar $sec-$L
						set ind [lsearch $hingList $hingChar]
						if {$ind != -1} {
							set secIDBeams($j,$k,$i,$dir) [lindex $hingTagList $ind]
							set kRatBeams($j,$k,$i,$dir) [lindex $kRatList $ind]
							continue
						}
						logCommands -comment "#section: $sec, Length= $L\n"
						set secIDBeams($j,$k,$i,$dir) [incr ID]
						lappend hingList $hingChar
						lappend hingTagList $ID
						
						set fpc [expr $inputs(RyConc)*$fc0]
						set fy [expr $inputs(RySteel)*$inputs(fyBeam)]
						set P 0.
						
						# calculate My
						set MyList [CalculateMy $B $H $cover $P $fpc $fy $inputs(Es) $nBarBot $DBarBot $nBarTop $DBarTop $nBarInt $DBarInt $DBarSh $inputs(cUnitTomm) $cUnitToMPa]
						set MyP [expr $inputs(MyFac)*[lindex $MyList 0]]
						set MyN [expr $inputs(MyFac)*[lindex $MyList 1]]
						
						# Define peak oriented material
						set kRatBeams($j,$k,$i,$dir) [ComputeHingeRC $ID $B $H $L $cover $P $fpc $Ec $fy $MyP $MyN $nBarBot $DBarBot $nBarTop $DBarTop $nBarInt $DBarInt $nBarSh $DBarSh $SStirrup $inputs(nFactor) $cUnitToMPa]
						lappend kRatList $kRatBeams($j,$k,$i,$dir)
					} else {
						set srchStr $sec
						set FRPAreaTop 0
						set FRPAreaBot 0
						if {[info exists FRPAttach]} {
							set srchStr $sec-$j
							foreach "FRPStringTop FRPStringBot" [split $FRPAttach($j,beam) "-"] {}
							if {[info exists FRPStringTop] && $FRPStringTop != ""} {
								foreach "b t" [split $FRPStringTop "x"] {}
								set FRPAreaTop [expr $b*$t*1.e-6]
								unset b
								unset t
							}
							if {[info exists FRPStringBot] && $FRPStringBot != ""} {
								foreach "b t" [split $FRPStringBot "x"] {}
								set FRPAreaBot [expr $b*$t*1.e-6]
								unset b
								unset t
							}
						}
						if {[lsearch $beamList $srchStr] == -1} {
							logCommands -comment "#section: $srchStr\n"
							lappend beamList $srchStr
							set secIDBeams($srchStr) [incr ID]
							RCSection $ID $beamBarsMatTag $confConcBeam $unconfConc $B $H $cover $nBarTop $ABarTop $nBarBot $ABarBot $nBarInt $ABarInt $DBarSh $GJ  $inputs(numSubdivL) $inputs(numSubdivT) $FRPAreaTop $FRPAreaBot $FRPMatTag 0 0
						}
					}
					source $inputs(secFolder)/unsetSecProps.tcl
				}
			}
		}
	}
}	

logCommands -comment "#~~~~ column sections ~~~~\n"
set clmnSecList ""
set hingList ""
set hingTagList ""
set kRatList0 ""
set kRatList90 ""
set code [eleCodeMap Column]
#column sections/M-Theta's
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set L [expr $Z($j)-$Z([expr $j-1])]
	for {set k 1} {$k <= [expr $inputs(nBaysY)+1]} {incr k} {
		for {set i 1} {$i <= [expr $inputs(nBaysX)+1]} {incr i} {
			set sec $eleData(section,$code,$j,$k,$i)
			if {$sec == "-"} continue
			source "$inputs(secFolder)/$sec.tcl"
			source "$inputs(secFolder)/convertToM.tcl"
			if {$inputs(typA) == 0} {
				set inputs(typA) $Area
				set typIz $I33
				set typIy $I22
				set typJ $J
			}
			set GJ [expr $Gc*$J]
			if {$inputs(eleType) == "Hinge"} {
				set P $columnGravLoad($j,$k,$i)
				# set P 0
				set hingChar $sec-$L-[expr int($P)]
				set ind [lsearch $hingList $hingChar]
				if {$ind != -1} {
					set secIDClmns($j,$k,$i,0) [lindex $hingTagList $ind]
					set secIDClmns($j,$k,$i,90) [expr $secIDClmns($j,$k,$i,0)*1000]
					set kRatClmns($j,$k,$i,0) [lindex $kRatList0 $ind]
					set kRatClmns($j,$k,$i,90) [lindex $kRatList90 $ind]
					continue
				}
				logCommands -comment "#section: $sec, Length= $L, P= $P\n"
				set secIDClmns($j,$k,$i,0) [incr ID]
				set secIDClmns($j,$k,$i,90) [expr $ID*1000]
				lappend hingList $hingChar
				lappend hingTagList $ID
				set fpc [expr $inputs(RyConc)*$fc0]
				set fy [expr $inputs(RySteel)*$inputs(fyClmn)]
				
				#around the 3 axis
				# calculate My
				set MyList [CalculateMy $B $H $cover $P $fpc $fy $inputs(Es) $nBarBot $DBarBot $nBarTop $DBarTop $nBarInt $DBarInt $DBarSh $inputs(cUnitTomm) $cUnitToMPa]
				set MyP [expr $inputs(MyFac)*[lindex $MyList 0]]
				set MyN [expr $inputs(MyFac)*[lindex $MyList 1]]
				
				# Define peak oriented material
				set kRatClmns($j,$k,$i,0) [ComputeHingeRC $ID $B $H $L $cover $P $fpc $Ec $fy $MyP $MyN $nBarBot $DBarBot $nBarTop $DBarTop $nBarInt $DBarInt $nBarSh $DBarSh $SStirrup $inputs(nFactor) $cUnitToMPa]
				lappend kRatList0 $kRatClmns($j,$k,$i,0)
				#around the 2 axis
				set _H $B
				set _B $H
				set _nBarBot [expr $nBarInt+2]
				set _ABarBot [expr ($nBarInt*$ABarInt+$ABarTop+$ABarBot)/$_nBarBot]
				set _DBarBot [expr sqrt(4.*$_ABarBot/3.1415)]
				set _nBarTop $_nBarBot
				set _ABarTop $_ABarBot
				set _DBarTop $_DBarBot
				set _nBarInt [expr $nBarTop - 2]
				set _ABarInt $ABarTop
				set _DBarInt $DBarTop
				
				# calculate My
				set MyList [CalculateMy $_B $_H $cover $P $fpc $fy $inputs(Es) $_nBarBot $_DBarBot $_nBarTop $_DBarTop $_nBarInt $_DBarInt $DBarSh $inputs(cUnitTomm) $cUnitToMPa]
				set MyP [expr $inputs(MyFac)*[lindex $MyList 0]]
				set MyN [expr $inputs(MyFac)*[lindex $MyList 1]]
				
				# Define peak oriented material
				set kRatClmns($j,$k,$i,90) [ComputeHingeRC [expr $ID*1000] $_B $_H $L $cover $P $fpc $Ec $fy $MyP $MyN $_nBarBot $_DBarBot $_nBarTop $_DBarTop $_nBarInt $_DBarInt $nBarSh $DBarSh $SStirrup $inputs(nFactor) $cUnitToMPa]
				lappend kRatList90 $kRatClmns($j,$k,$i,0)
			} else {
				set srchStr $sec
				# set FRPAreaTop 0
				# set FRPAreaBot 0
				# set FRPAreaLft 0
				# set FRPAreaRgt 0
				set FRPArea 0
				set FRPWrapA 0
				set FRPWrapS 0
				set FRP_Fy 0
				if {[info exists FRPAttach] && $FRPAttach($j,clmn) != ""} {
					set FRP_Fy [expr $FRP_E*$FRP_epsu]
					set srchStr $sec-$j
					foreach "b t" [split $FRPAttach($j,clmn) "x"] {}
					set FRPArea [expr $b*$t*1.e-6]
					# foreach "FRPStringTop FRPStringBot FRPStringLeft FRPStringRgt" [split $FRPAttach($j,clmn) "-"] {}
					# if {$FRPStringTop != ""} {
					# 	foreach "b t" [split $FRPStringTop "x"] {}
					# 	set FRPAreaTop [expr $b*$t*1.e-6]
					# 	unset b
					# 	unset t
					# }
					# if {$FRPStringBot != ""} {
					# 	foreach "b t" [split $FRPStringBot "x"] {}
					# 	set FRPAreaBot [expr $b*$t*1.e-6]
					# 	unset b
					# 	unset t
					# }
					# if {$FRPStringLeft != ""} {
					# 	foreach "b t" [split $FRPStringLeft "x"] {}
					# 	set FRPAreaLft [expr $b*$t*1.e-6]
					# 	unset b
					# 	unset t
					# }
					# if {$FRPStringRgt != ""} {
					# 	foreach "b t" [split $FRPStringRgt "x"] {}
					# 	set FRPAreaRgt [expr $b*$t*1.e-6]
					# 	unset b
					# 	unset t
					# }
					if {$FRPWrap($j,clmn) != ""} {
						foreach "b t s" [split $FRPWrap($j,clmn) "x"] {}
						set FRPWrapA [expr $b*$t*1.e-6]
						set FRPWrapS [expr $s*1.e-3]
					}
				}
				if {[lsearch $clmnSecList $srchStr] == -1} {
					logCommands -comment "#section: $srchStr\n"
					lappend clmnSecList $srchStr
					set fyh $inputs(fyClmn)
					set stat 0
					foreach shFac $clmnShearReinfSFacs {
						incr stat
						set wrpA 0
						set wrpS 0
						if {$stat == 1 || $stat == [llength $clmnShearReinfSFacs]} {
							set wrpA $FRPWrapA
							set wrpS $FRPWrapS
						}
						set secIDClmns($srchStr,$shFac) [incr ID]
						set shS [expr $SStirrup*$shFac]
						uniaxialMaterial ConfinedConcrete $ID -$fc0 -$ec0 [expr -0.1*$fc0] $lambda $ftU $Ets \
							-column $B $H $cover $fyh $nBarTop $DBarTop $nBarBot $DBarBot $nBarInt $DBarInt $nBarSh $nBarSh $DBarSh $shS $wrpA $FRP_Fy $wrpS
						RCSection $ID $clmnBarsMatTag $ID $unconfConc $B $H $cover $nBarTop $ABarTop $nBarBot $ABarBot $nBarInt $ABarInt $DBarSh $GJ $inputs(numSubdivL) $inputs(numSubdivT)  $FRPArea $FRPArea $FRPMatTag $FRPArea $FRPArea
					}
				}
			}
			source $inputs(secFolder)/unsetSecProps.tcl
		}
	}
}
uniaxialMaterial Elastic $inputs(rigidMatTag) [expr 100*$inputs(typA)*$Ec/$inputs(hStory)]
