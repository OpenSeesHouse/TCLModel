proc updateVar {option varNam newV} {
	upvar $varNam var
	if ![info exists var] {
		set var 0
	}
	set oldV $var
	if {$option == "-max"} {
		set var [expr max($newV,$oldV)]
	} elseif {$option == "-sum"} {
		set var [expr $oldV+$newV]
	} else {
		error("invalid option: $option")
	}
}

puts "~~~~~~~~~~~~~~~~~~~~~ Computing Joint Sizes ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Computing Joint Sizes ~~~~~~~~~~~~~~~~~~~~~\n"
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	#beam and brace connections
	foreach dir "X Y" nGridX "$inputs(nBaysX) [expr $inputs(nBaysX)+1]" nGridY "[expr $inputs(nBaysY)+1] $inputs(nBaysY)" {
		for {set k 1} {$k <= $nGridY} {incr k} {
			for {set i 1} {$i <= $nGridX} {incr i} {
				set elePos "$j,$k,$i,1"
				#beam end jnts
				set eleCode [eleCodeMap $dir-Beam]
				set sec $eleData(section,$eleCode,$elePos)
				if {$sec != "-"} {
					source $inputs(secFolder)/$sec.tcl
					source $inputs(secFolder)/convertToM.tcl
					if {$inputs(matType) == "Steel"} {
						set H $t3
						#TODO: account for beam's local axis rotation
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
					set dx [expr $X($k1,$i1)-$X($k,$i)]
					set dy [expr $Y($k1,$i1)-$Y($k,$i)]
					set l [expr ($dx*$dx+$dy*$dy)**0.5]
					set H2 [expr $H/2.]
					updateVar -sum jntData($iNode,dim,$dir,pn,v) $H2
					updateVar -sum jntData($iNode,dim,$dir,pp,v) $H2
					updateVar -sum jntData($jNode,dim,$dir,nn,v) $H2
					updateVar -sum jntData($jNode,dim,$dir,np,v) $H2
					source $inputs(secFolder)/unsetSecProps.tcl
				}

				#brace
				set elePos "$j,$k,$i"
				set eleCode [eleCodeMap $dir-Brace]
				if {$eleData(section,$eleCode,$elePos,L) != "-"} {
					#gusset dims.
					#J        J
					# \      /
					#  I    I
					set lhI $eleData(gussetDimI_lh,$eleCode,$elePos)
					set lvI $eleData(gussetDimI_lv,$eleCode,$elePos)
					set lhJ $eleData(gussetDimJ_lh,$eleCode,$elePos)
					set lvJ $eleData(gussetDimJ_lv,$eleCode,$elePos)
					#TODO allow different gusset size for the two members of an X brace
					#TODO consider the EBF config (shear link)

					# identifying the four corner nodes:
					# ^Z
					# |
					# I__M__J
					# |j,k,i|
					# K__N__L___> X/Y

					set iNodePos $j,$k,$i,1
					set kNodePos [expr $j-1],$k,$i,1
					if {$dir == "X"} {
						set jNodePos $j,$k,[expr $i+1],1
						set lNodePos [expr $j-1],$k,[expr $i+1],1
						set mNodePos $j,$k,$i,2
						set nNodePos [expr $j-1],$k,$i,2
					} else {
						set jNodePos $j,[expr $k+1],$i,1
						set lNodePos [expr $j-1],[expr $k+1],$i,1
						set mNodePos $j,$k,$i,3
						set nNodePos [expr $j-1],$k,$i,3
					}

					set conf $eleData(config,$eleCode,$elePos)
					# k
					if {$conf == "/" || $conf == "/\\" || $conf == "X"} {
						updateVar -sum jntData($kNodePos,dim,$dir,pp,h) $lhI
						updateVar -sum jntData($kNodePos,dim,$dir,pp,v) $lvI
					}
					#j
					if {$conf == "/" || $conf == "\\/" || $conf == "X"} {
						updateVar -sum jntData($jNodePos,dim,$dir,nn,h) $lhJ
						updateVar -sum jntData($jNodePos,dim,$dir,nn,v) $lvJ
					}
					# i
					if {$conf == "\\" || $conf == "\\/" || $conf == "X"} {
						#i
						updateVar -sum jntData($iNodePos,dim,$dir,pn,h) $lhJ
						updateVar -sum jntData($iNodePos,dim,$dir,pn,v) $lvJ
					}
					#l
					if {$conf == "\\" || $conf == "/\\" || $conf == "X"} {
						updateVar -sum jntData($lNodePos,dim,$dir,np,h) $lhI
						updateVar -sum jntData($lNodePos,dim,$dir,np,v) $lvI
					}
					# m
					if {$conf == "/\\" || $conf == "|"} {
						set jntData($mNodePos,dim,$dir,nn,h) [expr $lhJ]
						set jntData($mNodePos,dim,$dir,nn,v) [expr $H/2.+$lvJ]
						set jntData($mNodePos,dim,$dir,pn,h) [expr $lhJ]
						set jntData($mNodePos,dim,$dir,pn,v) [expr $H/2.+$lvJ]
					}
					# n
					if {$conf == "\\/" || $conf == "|"} {
						set jntData($nNodePos,dim,$dir,np,h) [expr $lhI]
						set jntData($nNodePos,dim,$dir,np,v) [expr $H/2. + $lvI]
						set jntData($nNodePos,dim,$dir,pp,h) [expr $lhI]
						set jntData($nNodePos,dim,$dir,pp,v) [expr $H/2. + $lvI]
					}

					# #brace internal joints
					# set missConfs(L) "| /"
					# set missConfs(R) "| \\"
					# foreach mem "L R" {
					# 	if {[lsearch $missConfs($mem) $conf] != -1} {
					# 		continue
					# 	}
					# 	for {set m 1} {$m < $inputs(nBraceSeg)} {incr m} {
					# 		set pos $j,$k,$i,R$dir[set mem]_$m
					# 		foreach d "X Y" {
					# 			foreach vrt "pp np nn pn" {
					# 				foreach com "h v" {
					# 					set name $pos,dim,$d,$vrt,$com
					# 					set jntData($name) 0
					# 				}
					# 			}
					# 		}
					# 	}
					# }
				}
			}
		}
	}
	#columns
	for {set k 1} {$k <= [expr $inputs(nBaysY)+1]} {incr k} {
		for {set i 1} {$i <= [expr $inputs(nBaysX)+1]} {incr i} {
			set elePos $j,$k,$i
			set eleCode [eleCodeMap Column]
			set sec $eleData(section,$eleCode,$elePos)
			if {$sec == "-"} {
				continue
			}
			source $inputs(secFolder)/$sec.tcl
			source $inputs(secFolder)/convertToM.tcl
			if {$inputs(matType) == "Steel"} {
				set dy $t3
				set dx $t2
			} else {
				set dy $H
				set dx $B
			}
			set iNodePos [expr $j-1],$k,$i,1
			set jNodePos $j,$k,$i,1
			updateVar -sum jntData($iNodePos,dim,X,pp,h) [expr $dx/2.]
			updateVar -sum jntData($iNodePos,dim,X,np,h) [expr $dx/2.]
			updateVar -sum jntData($iNodePos,dim,Y,pp,h) [expr $dy/2.]
			updateVar -sum jntData($iNodePos,dim,Y,np,h) [expr $dy/2.]

			updateVar -sum jntData($jNodePos,dim,X,pn,h) [expr $dx/2.]
			updateVar -sum jntData($jNodePos,dim,X,nn,h) [expr $dx/2.]
			updateVar -sum jntData($jNodePos,dim,Y,pn,h) [expr $dy/2.]
			updateVar -sum jntData($jNodePos,dim,Y,nn,h) [expr $dy/2.]

			#base plate connection height
			if {$j == 1} {
				updateVar -sum jntData($iNodePos,dim,X,pp,v) [expr $inputs(clmnBasePlateHeightFac)*$dx]
				updateVar -sum jntData($iNodePos,dim,X,np,v) [expr $inputs(clmnBasePlateHeightFac)*$dx]
				updateVar -sum jntData($iNodePos,dim,Y,pp,v) [expr $inputs(clmnBasePlateHeightFac)*$dy]
				updateVar -sum jntData($iNodePos,dim,Y,np,v) [expr $inputs(clmnBasePlateHeightFac)*$dy]
			}
			source $inputs(secFolder)/unsetSecProps.tcl
		}
	}
}

manageGeomData -makeJntList
#set missing jnt dims. based on the computed ones
foreach pos [manageGeomData -getAllJntPos] {
	foreach dir "X Y" {
		foreach vrt "pp np nn pn" {
			foreach com "h v" {
				set name $pos,dim,$dir,$vrt,$com
				if [info exists jntData($name)] continue
				set jntData($name) [manageGeomData -getMatchingJntDim $pos $dir $vrt $com]
			}
		}
	}
}
