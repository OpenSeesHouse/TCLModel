#read lists and store them in array
set j $inputs(nFlrs)
foreach "val1 val2" $diaphMassList {
	set diaphMass($j,X) $val1
	set diaphMass($j,R) $val2
	incr j -1
}

for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	for {set k 1} {$k <= $inputs(nBaysY)+1} {incr k} {
		set kk [expr $inputs(nBaysY)+1-$k+1]
		for {set i 1} {$i <= $inputs(nBaysX)+1} {incr i} {
			set pos "$j,$k,$i"
			if {$i <= $inputs(nBaysX)} {
				set code [eleCodeMap "X-Brace"]
				if [info exists xBraceLabels] {
					set lab [lindex $xBraceLabels [expr ($kk-1)*$inputs(nBaysX) + $i - 1]]
					if {$lab == "-"} {
						set eleData(section,$code,$pos,L) "-"
					} else {
						set eleData(section,$code,$pos,L)  $braceSec($lab,$j)
						set eleData(section,$code,$pos,R)  $braceSec($lab,$j)
						set eleData(config,$code,$pos)  $braceConfig($lab,$j)
						if [info exists settingsGroup($lab)] {
							set eleData(SG,$code,$pos,L)  $settingsGroup($lab)
							set eleData(SG,$code,$pos,R)  $settingsGroup($lab)
						} else {
							set eleData(SG,$code,$pos,L)  SG1
							set eleData(SG,$code,$pos,R)  SG1
						}
						set eleData(gussetDimI_lh,$code,$pos)  $gussetDimI($lab,lh,$j)
						set eleData(gussetDimI_lv,$code,$pos)  $gussetDimI($lab,lv,$j)
						set eleData(gussetDimI_lr,$code,$pos)  $gussetDimI($lab,lr,$j)
						set eleData(gussetDimJ_lh,$code,$pos)  $gussetDimJ($lab,lh,$j)
						set eleData(gussetDimJ_lv,$code,$pos)  $gussetDimJ($lab,lv,$j)
						set eleData(gussetDimJ_lr,$code,$pos)  $gussetDimJ($lab,lr,$j)
						if [info exists gussetDimI($lab,tp,$j)] {
							#not exist for BRB
							set eleData(gussetDimI_tp,$code,$pos)  $gussetDimI($lab,tp,$j)
							set eleData(gussetDimJ_tp,$code,$pos)  $gussetDimJ($lab,tp,$j)
						}
						set inputs(hasBrace) 1
					}
				} else {
					set eleData(section,$code,$pos,L) "-"
				}
				set code [eleCodeMap "X-Beam"]
				if [info exists xBeamLabels] {
					set lab [lindex $xBeamLabels [expr ($kk-1)*$inputs(nBaysX) + $i - 1]]
					if {$lab != "-"} {
						if [info exists settingsGroup($lab)] {
							set eleData(SG,$code,$pos)  $settingsGroup($lab)
						} else {
							set eleData(SG,$code,$pos)  SG1
						}
					}
				}
				if [info exists beamLoadListX] {
					set eleData(load,$code,$pos) [lindex $beamLoadListX($j) [expr ($kk-1)*$inputs(nBaysX) + $i - 1]]
					if {$eleData(load,$code,$pos) == "-"} {
						set eleData(load,$code,$pos) 0
					}
				} else {
					set eleData(load,$code,$pos) 0
				}
				if [info exists xBeamFixityList] {
					set lab [lindex $xBeamFixityList($j) [expr ($kk-1)*$inputs(nBaysX) + $i - 1]]
					set eleData(fixity,$code,$pos) $lab
				} else {
					set eleData(fixity,$code,$pos)  "11"
				}
				set code [eleCodeMap "X-Wall"]
				if [info exists xWallSecList] {
					set eleData(section,$code,$pos)  [lindex $xWallSecList($j) [expr ($kk-1)*$inputs(nBaysX) + $i - 1]]
				} else {
					set eleData(section,$code,$pos)  "-"
				}
				if {$eleData(section,$code,$pos) != "-"} {
					set inputs(hasWall) 1
				}
			}
			if {$k <= $inputs(nBaysY)} {
				set code [eleCodeMap "Y-Brace"]
				if [info exists yBraceLabels] {
					set lab [lindex $yBraceLabels [expr ($i-1)*$inputs(nBaysY) + $k - 1]]
					if {$lab == "-"} {
						set eleData(section,$code,$pos,L) "-"
					} else {
						set eleData(section,$code,$pos,L)  $braceSec($lab,$j)
						set eleData(section,$code,$pos,R)  $braceSec($lab,$j)
						set eleData(config,$code,$pos)  $braceConfig($lab,$j)
						set eleData(gussetDimI_lh,$code,$pos)  $gussetDimI($lab,lh,$j)
						set eleData(gussetDimI_lv,$code,$pos)  $gussetDimI($lab,lv,$j)
						set eleData(gussetDimI_lr,$code,$pos)  $gussetDimI($lab,lr,$j)
						set eleData(gussetDimI_tp,$code,$pos)  $gussetDimI($lab,tp,$j)
						set eleData(gussetDimJ_lh,$code,$pos)  $gussetDimJ($lab,lh,$j)
						set eleData(gussetDimJ_lv,$code,$pos)  $gussetDimJ($lab,lv,$j)
						set eleData(gussetDimJ_lr,$code,$pos)  $gussetDimJ($lab,lr,$j)
						set eleData(gussetDimJ_tp,$code,$pos)  $gussetDimJ($lab,tp,$j)
						set inputs(hasBrace) 1
					}
				} else {
					set eleData(section,$code,$pos,L) "-"
				}
				set code [eleCodeMap "Y-Beam"]
				if [info exists yBeamLabels] {
					set lab [lindex $yBeamLabels [expr ($i-1)*$inputs(nBaysY) + $k - 1]]
					if {$lab != "-"} {
						if [info exists settingsGroup($lab)] {
							set eleData(SG,$code,$pos)  $settingsGroup($lab)
						} else {
							set eleData(SG,$code,$pos)  SG1
						}
					}
				}
				if [info exists beamLoadListY] {
					set eleData(load,$code,$pos) [lindex $beamLoadListY($j) [expr ($i-1)*$inputs(nBaysY) + $k - 1]]
					if {$eleData(load,$code,$pos) == "-"} {
						set eleData(load,$code,$pos) 0
					}
				} else {
					set eleData(load,$code,$pos) 0
				}
				if [info exists yBeamReleaseList] {
					set lab [lindex $yBeamReleaseList($j) [expr ($i-1)*$inputs(nBaysY) + $k - 1]]
					set eleData(fixity,$code,$pos) $lab
				} else {
					set eleData(fixity,$code,$pos)  "11"
				}
				set code [eleCodeMap "Y-Wall"]
				if [info exists yWallSecList] {
					set eleData(section,$code,$pos) [lindex $yWallSecList($j) [expr ($i-1)*$inputs(nBaysY) + $k - 1]]
				} else {
					set eleData(section,$code,$pos) "-"
				}
				if {$eleData(section,$code,$pos) != "-"} {
					set inputs(hasWall) 1
				}
			}
			for {set iStat 1} {$iStat <= $inputs(numDesnStats)} {incr iStat} {
				if {$i <= $inputs(nBaysX)} {
					set code [eleCodeMap "X-Beam"]
					if [info exists xBeamLabels] {
						set lab [lindex $xBeamLabels [expr ($kk-1)*$inputs(nBaysX) + $i - 1]]
						if {$lab == "-"} {
							set eleData(section,$code,$pos,$iStat) "-"
						} else {
							if [info exists beamSec($lab,$j,$iStat)] {
								set sec $beamSec($lab,$j,$iStat)
							} else {
								set sec $beamSec($lab,$j,1)
							}
							set eleData(section,$code,$pos,$iStat)  $sec
						}
					} else {
						set eleData(section,$code,$pos,$iStat)  [lindex $xBeamSecList($j) [expr ($kk-1)*$inputs(nBaysX) + $i - 1]]
					}
				}
				if {$k <= $inputs(nBaysY)} {
					set code [eleCodeMap "Y-Beam"]
					if [info exists yBeamLabels] {
						set lab [lindex $yBeamLabels [expr ($i-1)*$inputs(nBaysY) + $k - 1]]
						if {$lab == "-"} {
							set eleData(section,$code,$pos,$iStat)  "-"
						} else {
							if [info exists beamSec($lab,$j,$iStat)] {
								set sec $beamSec($lab,$j,$iStat)
							} else {
								set sec $beamSec($lab,$j,1)
							}
							set eleData(section,$code,$pos,$iStat)  $sec
						}
					} else {
						set eleData(section,$code,$pos,$iStat) [lindex $yBeamSecList($j) [expr ($i-1)*$inputs(nBaysY) + $k - 1]]
					}
				}
			}
			set code [eleCodeMap "Column"]
			if [info exists columnLabels] {
				set lab [lindex $columnLabels [expr ($kk-1)*($inputs(nBaysX)+1) + $i - 1]]
				if {$lab == "-"} {
					set sec  "-"
				} else {
					set sec $columnSec($lab,$j)
					if [info exists settingsGroup($lab)] {
						set eleData(SG,$code,$pos)  $settingsGroup($lab)
					} else {
						set eleData(SG,$code,$pos)  SG1
					}
				}
			} else {
				set sec [lindex $columnSecList($j) [expr ($kk-1)*($inputs(nBaysX)+1) + $i - 1]]
			}
			set eleData(section,$code,$pos) $sec
			set eleData(angle,$code,$pos) [lindex $columnAngleList($j) [expr ($kk-1)*($inputs(nBaysX)+1) + $i - 1]]

			if [info exists pntLoadList] {
				set pointData(load,$pos) [lindex $pntLoadList($j) [expr ($kk-1)*$inputs(nBaysX) + $i - 1]]
				if {$pointData(load,$pos) == ""} {
					set pointData(load,$pos) 0.
				}
			} else {
				set pointData(load,$pos) 0.
			}
		}
	}
}
for {set k 1} {$k <= $inputs(nBaysY)+1} {incr k} {
	set kk [expr $inputs(nBaysY)+1-$k+1]
	for {set i 1} {$i <= $inputs(nBaysX)+1} {incr i} {
		if [info exists gridOffsetListX] {
			set off [lindex $gridOffsetListX [expr ($kk-1)*($inputs(nBaysX)+1) + $i - 1]]
			set gridOffset(X,$k,$i) $off
		} else {
			set gridOffset(X,$k,$i) 0
		}
		if [info exists gridOffsetListY] {
			set off [lindex $gridOffsetListY [expr ($kk-1)*($inputs(nBaysX)+1) + $i - 1]]
			set gridOffset(Y,$k,$i) $off
		} else {
			set gridOffset(Y,$k,$i) 0
		}
		if [info exists baseFixityFlags] {
			set xy [lindex $baseFixityFlags [expr ($kk-1)*($inputs(nBaysX)+1) + $i - 1]]
			set fixityFlag($k,$i) $xy
		} else {
			set fixityFlag($k,$i) 11
		}
	}
}

if [info exists slabLoad] {
	set code1 [eleCodeMap "X-Beam"]
	set code2 [eleCodeMap "Y-Beam"]
	for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
		set lines [split $slabLoad($j) \n]
		set k $inputs(nBaysY)
		foreach line $lines {
			if {$line == ""} continue
			set _ly [lindex $inputs(lBayY) [expr $k-1]]
			set i 1
			foreach w $line {
				set _lx [lindex $inputs(lBayX) [expr $i-1]]
				set rat [expr $_lx/$_ly]
				if {$rat >= 2} {
					set qx [expr $w*$_ly/2.]
					set qy 0
				} elseif {$rat >= 1} {
					set a [expr $_ly/$_lx/2.]
					set qx [expr (1-2.*$a**2.+$a**3.)*$w*$_ly/2]
					set qy [expr 5./8.*$w*$_ly/2]
				} elseif {$rat > 0.5} {
					set qx [expr 5./8.*$w*$_lx/2]
					set a [expr $_lx/$_ly/2.]
					set qy [expr (1-2.*$a**2.+$a**3.)*$w*$_lx/2]
				} elseif {$rat > 0} {
					set qx 0
					set qy [expr $w*$_lx/2.]
				}
				set k1 [expr $k+1]
				set i1 [expr $i+1]
				set pos1 "$j,$k,$i"
				set pos2 "$j,$k1,$i"
				set pos3 "$j,$k,$i1"
				set eleData(load,$code1,$pos1) [expr $eleData(load,$code1,$pos1)+$qx]
				set eleData(load,$code1,$pos2) [expr $eleData(load,$code1,$pos2)+$qx]
				set eleData(load,$code2,$pos1) [expr $eleData(load,$code2,$pos1)+$qy]
				set eleData(load,$code2,$pos3) [expr $eleData(load,$code2,$pos3)+$qy]
				incr i
			}
			incr k -1
		}
	}
}
if [info exists deckLoad] {
	set code1 [eleCodeMap "X-Beam"]
	set code2 [eleCodeMap "Y-Beam"]
	for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
		set lines [split $deckLoad($j) \n]
		set dirLines [split $deckLoadDir($j) \n]
		set k $inputs(nBaysY)
		foreach line $lines dirLine $dirLines {
			if {$line == ""} continue
			set _ly [lindex $inputs(lBayY) [expr $k-1]]
			set i 1
			foreach w $line dir $dirLine {
				set _lx [lindex $inputs(lBayX) [expr $i-1]]
				if {$dir == "X"} {
					set qy [expr $w*$_lx/2.]
					set qx 0
				} elseif {$dir == "Y"}  {
					set qx [expr $w*$_ly/2.]
					set qy 0
				} else {
					error "unacceptable loadDir: $dir should be either X or Y"
				}
				set k1 [expr $k+1]
				set i1 [expr $i+1]
				set pos1 "$j,$k,$i"
				set pos2 "$j,$k1,$i"
				set pos3 "$j,$k,$i1"
				set eleData(load,$code1,$pos1) [expr $eleData(load,$code1,$pos1)+$qx]
				set eleData(load,$code1,$pos2) [expr $eleData(load,$code1,$pos2)+$qx]
				set eleData(load,$code2,$pos1) [expr $eleData(load,$code2,$pos1)+$qy]
				set eleData(load,$code2,$pos3) [expr $eleData(load,$code2,$pos3)+$qy]
				incr i
			}
			incr k -1
		}
	}
}
# calculate coordinates
for {set i 1} {$i <= $inputs(nBaysX)+1} {incr i} {
	if {$i == 1} {
		set X($i) 0
	} else {
		set LBayArrX([expr $i-1]) [lindex $inputs(lBayX) [expr $i-2]]
		set X($i) [expr $X([expr $i-1]) + $LBayArrX([expr $i-1])]
	}
}
for {set k 1} {$k <= $inputs(nBaysY)+1} {incr k} {
	if {$k == 1} {
		set Y($k) 0
	} else {
		set LBayArrY([expr $k-1]) [lindex $inputs(lBayY) [expr $k-2]]
		set Y($k) [expr $Y([expr $k-1]) + $LBayArrY([expr $k-1])]
	}
}

for {set k 1} {$k <= $inputs(nBaysY)+1} {incr k} {
	for {set i 1} {$i <= $inputs(nBaysX)+1} {incr i} {
		set X($k,$i) [expr $X($i) + $gridOffset(X,$k,$i)]
	}
}
for {set i 1} {$i <= $inputs(nBaysX)+1} {incr i} {
	for {set k 1} {$k <= $inputs(nBaysY)+1} {incr k} {
		set Y($k,$i) [expr $Y($k) + $gridOffset(Y,$k,$i)]
	}
}
set Z(0) 0.
set Z(1) $inputs(hStoryBase)
for {set j 2} {$j <= $inputs(nFlrs)} {incr j} {
	set Z($j) [expr $Z([expr $j-1])+$inputs(hStory)]
}
# set Z(0) 0.
# for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
# set Z($j) [expr $Z([expr $j-1])+[lindex $inputs(hStory) [expr $j-1]]]
# }

# calculate gravity loads on columns
#the recorded elemental force has been replaced for more flexibility
if {1} {
	for {set j $inputs(nFlrs)} {$j >= 1} {incr j -1} {
		for {set k 1} {$k <= $inputs(nBaysY)+1} {incr k} {
			set ly [lindex $inputs(lBayY) [expr $k-1]]
			if {$k > 1} {
				set ly1 [lindex $inputs(lBayY) [expr $k-2]]
			}
			for {set i 1} {$i <= $inputs(nBaysX)+1} {incr i} {
				set lx [lindex $inputs(lBayX) [expr $i-1]]
				if {$i > 1} {
					set lx1 [lindex $inputs(lBayX) [expr $i-2]]
				}
				set code [eleCodeMap X-Beam]
				if {$i == 1} {
					set loadX	[expr $eleData(load,$code,$j,$k,$i)*$lx/2.]
				} elseif {$i == $inputs(nBaysX)+1} {
					set loadX	[expr $eleData(load,$code,$j,$k,[expr $i-1])*$lx1/2.]
				} else {
					set loadX1	[expr $eleData(load,$code,$j,$k,$i)*$lx/2.]
					set loadX2	[expr $eleData(load,$code,$j,$k,[expr $i-1])*$lx1/2.]
					set loadX	[expr $loadX1 + $loadX2]
				}
				set code [eleCodeMap Y-Beam]
				set loadY 0.
				if {$inputs(numDims) == 3} {
					if {$k == 1} {
						set loadY	[expr $eleData(load,$code,$j,$k,$i)*$ly/2.]
					} elseif {$k == $inputs(nBaysY)+1} {
						set loadY	[expr $eleData(load,$code,$j,[expr $k-1],$i)*$ly1/2.]
					} else {
						set loadY1	[expr $eleData(load,$code,$j,$k,$i)*$ly/2.]
						set loadY2	[expr $eleData(load,$code,$j,[expr $k-1],$i)*$ly1/2.]
						set loadY	[expr $loadY1 + $loadY2]
					}
				}
				set tributaryLoad [expr $loadX + $loadY]
				if {$j == $inputs(nFlrs)} {
					set columnGravLoad($j,$k,$i) [expr $tributaryLoad]
				} else {
					set columnGravLoad($j,$k,$i) [expr $columnGravLoad([expr $j+1],$k,$i) +  $tributaryLoad]
				}
			}
		}
	}
}

if {0} {
	if [info exists inputs(initAxiForceFiles)] {
		set i 0
		foreach file $inputs(initAxiForceFiles) fac $inputs(initAxiForceFacts) {
			if [catch {open $file r} input] {
				continue
			}
			incr i
			set lines [split [read $input] \n]
			close $input
			foreach l $lines {
				if {$l == ""} break
				set line($i) $l
			}
			if {$line($i) == ""} {
				incr i -1
				continue
			}
			set f($i) $fac
		}
		if {$i > 0} {
			set n [llength $line(1)]
			for {set j 0} {$j < $n} {incr j} {
				set v 0
				for {set k 1} {$k <= $i} {incr k} {
					set v [expr $v+$f($k)*[lindex $line($k) $j]]
				}
				set initAxiForce([expr $j+1]) $v
			}
		}
	}
}