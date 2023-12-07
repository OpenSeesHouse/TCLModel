#define braces
set eleCode
if {$inputs(hasBrace) == 0} {
	return
}
#define Braces
#consists of these steps:

# 1 --------------- jntData updating ----------------------------------------------------
# 1.1 collecting gusset dimensions along with the panel zone dimensions
# 1.2 adding new records to the jntData array as jntData(dim,pos,dir,vrtx:(pp|np|nn|pn),h,v)
#     that form two cruciforms in X|Y dirs. each cruciform consists of 4 vertices and each vertex
#     is defined using a couple of h,v coordinates
# 1.3 iterating over brace connectivity and gusset dimension data and updating jntData array

# 2 --------- material and behavior definition ---------------------------------------------
# 2.1 reviewing Karamanci & Lignos (2014) for modelling buckling behavir using meshed
#   imperfect co-rotational geometry and the proposed low-cycle fatigue rule
# 2.2 reviewing Hsiao et al. (2012) for modelling plastic hinging at the gusset
# 2.3 adding uniaxialMaterial objects required for fiber sections and gusset springs

# 3 --------- defining the meshed geometry and the springs ---------------------------------
# 3.1 updating element codes and the related node positions to see variability at each $j,$k,$i:
#     1:panel-zone center
#     2:gusset (rigid link and spring),
#     3:brace mesh,
#     4:beam splice,
#     5:shear link (two external connectors + two springs + one internal connector)
# 3.2 dividing the beams for chevron and EBF configs to create additional nodes
# 3.3 defining end offset at the new internal edges of the divided beams
# 3.4 defining the beam end springs for the shear link in case of EBF
# 3.5 defining the rigid links and the rotational springs representing the gussets
#     defining the out-of-plane (for numDims==3) and in-plane (numDims == 2)
# 3.6 sinusoidal imperfection by defing node geometries
# 3.7 defining the fiber-based beam-column elements in between the defined nodes

puts "~~~~~~~~~~~~~~~~~~~~~ Defining Brace Materials and Sections ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Brace Materials and Sections ~~~~~~~~~~~~~~~~~~~~~\n"
source $inputs(generalFolder)/BraceSections.tcl

puts "~~~~~~~~~~~~~~~~~~~~~ Defining Braces ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Braces ~~~~~~~~~~~~~~~~~~~~~\n"
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	logCommands -comment "### story $j\n"
	set sumStrucWeigh([eleCodeMap X-Brace],$j) 0
	set sumStrucWeigh([eleCodeMap Y-Brace],$j) 0
	foreach dir "X Y" nGridX "$inputs(nBaysX) [expr $inputs(nBaysX)+1]" nGridY "[expr $inputs(nBaysY)+1] $inputs(nBaysY)" {
		logCommands -comment "### $dir-dir Braces\n"
		set offsi(X) 0
		set offsi(Y) 0
		set offsi(Z) 0
		set offsj(X) 0
		set offsj(Y) 0
		set offsj(Z) 0
		for {set k 1} {$k <= $nGridY} {incr k} {
			for {set i 1} {$i <= $nGridX} {incr i} {
				set elePos "$j,$k,$i"
				set eleCode [eleCodeMap $dir-Brace]
				if {$eleData(section,$eleCode,$elePos,L) == "-"} {
					continue
				}
				set conf $eleData(config,$eleCode,$elePos)
				set i1 $i
				set k1 $k
				set j1 [expr $j-1]
				if {$dir == "X"} {
					set i1 [expr $i+1]
					set mc 2
				} else {
					set k1 [expr $k+1]
					set mc 3
				}
				set missConfs(L) "| \\"
				set missConfs(R) "| /"
				foreach mem "L R" {
					if {[lsearch $missConfs($mem) $conf] != -1} {
						continue
					}
					if {$mem == "L"} {
						set iNode $j1,$k,$i,1
						set jNode $j,$k1,$i1,1
						if {$conf == "\\/"} {
							set iNode $j1,$k,$i,$mc
							set jNode $j,$k1,$i1,1
						} elseif {$conf == "/\\"} {
							set jNode $j,$k,$i,$mc
						}
					} else {
						set iNode $j1,$k1,$i1,1
						set jNode $j,$k,$i,1
						if {$conf == "\\/"} {
							set iNode $j1,$k,$i,$mc
							set jNode $j,$k,$i,1
						} elseif {$conf == "/\\"} {
							set jNode $j,$k,$i,$mc
						}
					}
					foreach d "dx dy dz" x [manageFEData -getNodeCrds $iNode] y [manageFEData -getNodeCrds $jNode] {
						set $d [expr $y-$x]
					}
					set xV "$dx $dy $dz"
					set zAxis $inputs(def[set dir]BraceZAxis)
					set yV [Vector crossProduct $zAxis $xV]
					set l [manageGeomData -getBraceLength $mem $eleCode $elePos]
					set rigMat [manageFEData -getMaterial rigid]

					if {$inputs(numDims) == 2} {
						set args "-mat $rigMat $rigMat $rigMat -dir 1 2 3"
					} else {
						set args "-mat $rigMat $rigMat $rigMat $rigMat $rigMat $rigMat -dir 1 2 3 4 5 6"
					}

					#gusset 1
					set nd1 $eleCode,$elePos,$mem,g1
					set nd2 $eleCode,$elePos,$mem,g2
					addElement zeroLength [manageFEData -newElement $eleCode,$elePos,$mem,g1] $nd1 $nd2 $args

					#gusset 2
					set nd3 $eleCode,$elePos,$mem,g3
					set nd4 $eleCode,$elePos,$mem,g4
					addElement zeroLength [manageFEData -newElement $eleCode,$elePos,$mem,g2] $nd3 $nd4 $args


					if {$inputs(numDims) == 2} {
						set args "-mat $rigMat $rigMat $rigMat -dir 1 2 3 -orient $yV"
					} else {
						set args "-mat $rigMat $rigMat $rigMat $rigMat $rigMat $rigMat -dir 1 2 3 4 5 6 -orient $yV"
					}
					#rigid links
					addElement twoNodeLink $eleCode,$elePos,$mem,r1 $iNode $nd1 $args
					addElement twoNodeLink $eleCode,$elePos,$mem,r2 $nd4 $jNode $args

					set iNode $nd2
					set jNode $nd3
					addFiberMember $inputs(braceType) $elePos,$mem $eleCode $iNode $jNode 1 rho 0 $inputs(braceInteg) $inputs(braceGeomType) $zAxis 0
					#imperfect sinusoidal meshing
					set eleData(unitSelfWeight,$eleCode,$pos,$mem) $rho
					set sumStrucWeigh($eleCode,$j) [expr $sumStrucWeigh($eleCode,$j)+$l*$rho]
				}
			}
		}
	}
}