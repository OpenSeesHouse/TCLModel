
## location codes
# 1: central node
# 2: x beam splice
# 3: y beam splice
# j,99: center of mass
puts "~~~~~~~~~~~~~~~~~~~~~ Defining Nodes ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Nodes ~~~~~~~~~~~~~~~~~~~~~\n"

set pi 3.1415
set allkiList ""
for {set i 1} {$i <= [expr $inputs(nBaysX)+1]} {incr i} {
	for {set k 1} {$k <= [expr $inputs(nBaysY)+1]} {incr k} {
		lappend allkiList "$k $i"
	}
}
for {set j 0} {$j <= $inputs(nFlrs)} {incr j} {
	logCommands -comment "### story $j ###\n"
	set masterNode($j) 0
	set slaveNodeList($j) ""
	set locCodes "1 2 3 BX BY C RX RY"
	set locDescs "central
	X-beam-splice
	Y-beam-splice
	X-beam-meshing
	Y-beam-meshing
	X-left-brace-meshing
	X-right-brace-meshing
	Y-left-brace-meshing
	Y-right-brace-meshing
	"
	foreach loc $locCodes locDesc $locDescs  {
		logCommands -comment "# $locDesc nodes ###\n"
		foreach ki $allkiList {
			foreach "k i" $ki {}
			set i1 [expr $i+1]
			set k1 [expr $k+1]
			set pos "$j,$k,$i,$loc"
			if ![manageGeomData -jntExists $pos] {
				if {$loc == 1 || $loc == 2 || $loc == 3} {
					continue
				}
			}
			foreach "x y z" "$X($k,$i)	$Y($k,$i)	$Z($j)" {}
			if {$loc == 1} {
				addNode $pos $x $y $z -addToDamping
				lappend slaveNodeList($j) $pos
				if {$masterNode($j) == 0} {
					set masterNode($j) $pos		;#used in numDim == 2 for leaning column
				}
			} elseif {$loc == 2} {
				set eleCode [eleCodeMap X-Beam]
				set elePos "$j,$k,$i"
				set x [expr $x*(1-$inputs(braceSpanRat))+$X($k,$i1)*$inputs(braceSpanRat)]
				addNode $pos $x $y $z -setAligned $eleCode $elePos
				lappend slaveNodeList($j) $pos
			} elseif {$loc == 3} {
				set eleCode [eleCodeMap Y-Beam]
				set elePos "$j,$k,$i"
				set y [expr $y*(1-$inputs(braceSpanRat))+$Y($k1,$i)*$inputs(braceSpanRat)]
				addNode $pos $x $y $z -setAligned $eleCode $elePos
				lappend slaveNodeList($j) $pos
			} elseif {$loc == "BX" || $loc == "BY"} {
				if {$j == 0} {
					continue
				}
				set dir [string index $loc 1]
				if {($dir == "X" && $i > $inputs(nBaysX)) || ($dir == "Y" && $k > $inputs(nBaysY))} {
					continue
				}
				set eleCode [eleCodeMap $dir-Beam]
				set elePos $j,$k,$i
				set sec $eleData(section,$eleCode,$elePos,1)
				if {$sec == "-"} {
					continue
				}
				set sg $eleData(SG,$eleCode,$elePos)
				if [info exists inputs($sg,numSeg)] {
					set nSeg $inputs($sg,numSeg)
					set lSeg 0
				} elseif [info exists inputs($sg,lSeg)] {
					set nSeg 0
					set lSeg $inputs($sg,lSeg)
				} else {
					set nSeg 1
					set lSeg 0
				}
				if {$nSeg <= 1 && $lSeg == 0} {
					continue
				}
				set i1 $i
				set k1 $k
				if {$dir == "X"} {
					set i1 [expr $i+1]
				} else {
					set k1 [expr $k+1]
				}
				set iNode $j,$k,$i,1
				set jNode $j,$k1,$i1,1
				set x2 $X($k1,$i1)
				set y2 $Y($k1,$i1)
				set dx [expr $x2-$x]
				set dy [expr $y2-$y]
				set l [expr ($dx*$dx+$dy*$dy)**0.5]
				set d1 [expr 0.5*($jntData($iNode,dim,$dir,pp,h)+$jntData($iNode,dim,$dir,pp,h))*$inputs(rigidZoneFac)]
				set d2 [expr 0.5*($jntData($jNode,dim,$dir,np,h)+$jntData($jNode,dim,$dir,nn,h))*$inputs(rigidZoneFac)]
				set dx [expr $dx/$l]
				set dy [expr $dy/$l]
				set l [expr $l-$d1-$d2]
				set dx [expr $dx*$l]
				set dy [expr $dy*$l]
				if {$nSeg == 0} {
					set nSeg [expr int($l/$lSeg)]
				}
				set dx [expr $dx/$nSeg]
				set dy [expr $dy/$nSeg]
				for {set m 1} {$m < $nSeg} {incr m} {
					set pos $j,$k,$i,B[set dir]_$m
					set x [expr $x+$dx]
					set y [expr $y+$dy]
					addNode $pos $x $y $z -setAligned $eleCode $elePos
				}
			} elseif {$loc == "C"} {
				if {$j == 0} {
					continue
				}
				set eleCode [eleCodeMap Column]
				set elePos $j,$k,$i
				set sec $eleData(section,$eleCode,$elePos)
				if {$sec == "-"} {
					continue
				}
				set sg $eleData(SG,$eleCode,$elePos)
				if {$inputs($sg,eleType) == "Hinge"} {
					continue
				}
				if [info exists inputs($sg,numSeg)] {
					set nSeg $inputs($sg,numSeg)
					set lSeg 0
				} elseif [info exists inputs($sg,lSeg)] {
					set nSeg 0
					set lSeg $inputs($sg,lSeg)
				} else {
					set nSeg 1
					set lSeg 0
				}
				if {$nSeg <= 1 && $lSeg == 0} {
					continue
				}
				set j1 [expr $j-1]
				set iNode $j1,$k,$i,1
				set jNode $j,$k,$i,1
				foreach "x y z" [manageFEData -getNodeCrds $iNode] {}
				set l [expr $Z($j)-$Z($j1)]
				set d1 [expr ($jntData($iNode,dim,X,pp,v) + \
					$jntData($iNode,dim,X,np,v) +	\
					$jntData($iNode,dim,Y,pp,v) + \
					$jntData($iNode,dim,Y,np,v))*0.25*$inputs(rigidZoneFac)]
				set d2 [expr -($jntData($jNode,dim,X,pn,v) + \
					$jntData($jNode,dim,X,nn,v) +	\
					$jntData($jNode,dim,Y,pn,v) + \
					$jntData($jNode,dim,Y,nn,v))*0.25*$inputs(rigidZoneFac)]
				set l [expr $l-$d1-$d2]
				if {$nSeg == 0} {
					set nSeg [expr int($l/$lSeg)]
				}
				set dz [expr $l/$nSeg]
				for {set m 1} {$m < $nSeg} {incr m} {
					set pos $j,$k,$i,C_$m
					set z [expr $z+$dz]
					addNode $pos $x $y $z -setAligned $eleCode $elePos
				}
			} elseif {$loc == "RX" || $loc == "RY"} {
				if {$j == 0} {
					continue
				}
				set elePos "$j,$k,$i"
				set dir [string index $loc 1]
				if {($dir == "X" && $i > $inputs(nBaysX)) || ($dir == "Y" && $k > $inputs(nBaysY))} {
					continue
				}
				set eleCode [eleCodeMap $dir-Brace]
				if {$eleData(section,$eleCode,$elePos,L) == "-"} {
					continue
				}
				set i1 $i
				set k1 $k
				if {$dir == "X"} {
					set i1 [expr $i+1]
					set mc 2
					set dn "0 1 0"
				} else {
					set k1 [expr $k+1]
					set mc 3
					set dn "1 0 0"
				}
				set conf $eleData(config,$eleCode,$elePos)
				set j1 [expr $j-1]
				set z1 $Z($j1)
				#conf	L	R
				#X		/	\\
				#/		/
				#\\			\\
				#\\/	/	\\
				#/\\	/	\\
				set missConfs(L) "| \\"
				set missConfs(R) "| /"
				foreach mem "L R" {
					set skip 0
					foreach c $missConfs($mem) {
						if {$conf == $c} {
							set skip 1
							break
						}
					}
					if {$skip} continue
					set sg $eleData(SG,$eleCode,$elePos,$mem)
					if {$mem == "L"} {
						set iNode $j1,$k,$i,1
						set jNode $j,$k1,$i1,1
						if {$conf == "\\/"} {
							set iNode $j1,$k,$i,$mc
							set jNode $j,$k1,$i1,1
						} elseif {$conf == "/\\"} {
							set jNode $j,$k,$i,$mc
						}
						set h $jntData($iNode,dim,$dir,pp,h)
						set v $jntData($iNode,dim,$dir,pp,v)
						set dgi [expr ($h**2+$v**2)*$inputs(rigidZoneFac)]
						set h $jntData($jNode,dim,$dir,nn,h)
						set v $jntData($jNode,dim,$dir,nn,v)
						set dgj [expr ($h**2+$v**2)*$inputs(rigidZoneFac)]
					} else {
						set iNode $j1,$k1,$i1,1
						set jNode $j,$k,$i,1
						if {$conf == "\\/"} {
							set iNode $j1,$k,$i,$mc
							set jNode $j,$k,$i,1
						} elseif {$conf == "/\\"} {
							set jNode $j,$k,$i,$mc
						}
						set h $jntData($iNode,dim,$dir,np,h)
						set v $jntData($iNode,dim,$dir,np,v)
						set dgi [expr ($h**2+$v**2)*$inputs(rigidZoneFac)]
						#TODO use digonal gusset dimension for computing dg
						set h $jntData($jNode,dim,$dir,pn,h)
						set v $jntData($jNode,dim,$dir,pn,v)
						set dgj [expr ($h**2+$v**2)*$inputs(rigidZoneFac)]
					}
					foreach "xi yi zi" [manageFEData -getNodeCrds $iNode] {}
					foreach "xj yj zj" [manageFEData -getNodeCrds $jNode] {}
					set l 0
					foreach d "dx dy dz" d1 "xi yi zi" d2 "xj yj zj" {
						set $d [expr [set $d2] - [set $d1]]
						set l [expr $l + [set $d]**2.]
					}
					set l [expr $l**0.5]
					#cosine (unit) vector:
					foreach d "dx dy dz" {
						set $d [expr [set $d]/$l]
					}
					#chord length
					set l [expr $l-$dgi-$dgj]
					manageGeomData -setBraceLength $mem $eleCode $elePos $l
					#gusset nodes
					foreach d "xi yi zi" dd "dx dy dz" {
						set $d [expr [set $d]+[set $dd]*$dgi]
					}
					set pos $eleCode,$elePos,$mem,g1
					addNode $pos $xi $yi $zi
					if {$inputs(seeGussetSpring)} {
						set pos $eleCode,$elePos,$mem,g2
						addNode $pos $xi $yi $zi
					}
					foreach d "xj yj zj" dd "dx dy dz" {
						set $d [expr [set $d]-[set $dd]*$dgj]
					}
					if {$inputs(seeGussetSpring)} {
						set pos $eleCode,$elePos,$mem,g3
						addNode $pos $xj $yj $zj
					}
					set pos $eleCode,$elePos,$mem,g4
					addNode $pos $xj $yj $zj

					source $inputs(secFolder)/$eleData(section,$eleCode,$elePos,L).tcl
					if {$Shape != "BRB"} {
						#imperfect sinusoidal meshing
						if {$inputs(numDims) == 2} {
							set dny 0.
							if {$mem == "L"} {
								set dnx -$dz
								set dnz $dx
							} else {
								set dnx $dz
								set dnz -$dx
							}
						} else {
							foreach "dnx dny dnz" $dn {}
							# if {$dir == "X"} {
							# 	if {$mem == "L"} {
							# 		set dnx -$dz
							# 		set dnz $dx
							# 	} else {
							# 		set dnx $dz
							# 		set dnz -$dx
							# 	}
							# 	set dny 0
							# } else {
							# 	if {$mem == "L"} {
							# 		set dny -$dz
							# 		set dnz $dy
							# 	} else {
							# 		set dny $dz
							# 		set dnz -$dy
							# 	}
							# 	set dnx 0
							# }
						}
						set dl [expr $l/$inputs($sg,numSeg)]
						set dr [expr ($dx**2.+$dy**2.)**0.5]
						for {set m 1} {$m < $inputs($sg,numSeg)} {incr m} {
							set pos $eleCode,$elePos,$mem,$m
							set xl [expr $m*$dl]
							set yl [expr $inputs(imperfectRat)*$l*sin($pi*$xl/$l)]

							set x [expr $xi+$xl*$dx+$yl*$dnx]
							set y [expr $yi+$xl*$dy+$yl*$dny]
							set z [expr $zi+$xl*$dz+$yl*$dnz]
							addNode $pos $x $y $z -setAligned $eleCode $elePos,$mem
						}
					}
				}
			}
		}
	}
}
