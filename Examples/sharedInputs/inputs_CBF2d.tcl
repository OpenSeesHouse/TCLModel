
#initiation
#_____________________________________________________
#if let to default, program will calculate these
set inputs(hasWall) 0
set inputs(hasBrace) 1

#Geometry
#_____________________________________________________
set inputs(numDims) 2
# set inputs(nFlrs) 12
set inputs(nBaysX) 1
set inputs(nBaysY) 0
set inputs(lBayX) "6.09"
set inputs(lBayY) ""
set inputs(hStory) 4.27
set inputs(hStoryBase) 5.49
set inputs(numDesnStats) 1		;#mainly for RC members
set inputs(eccRatX) 0
set inputs(eccRatY) 0

set inputs(ly) [expr 5*9.14]
set inputs(lx) [expr 5*6.09]
set inputs(planArea) [expr 0.25*$inputs(lx)*$inputs(ly)]
set inputs(planPerim) [expr 0.5*($inputs(lx)+$inputs(ly))]
set inputs(cornerCrdList) "
"
# for recording corner nodes' drifts 
set inputs(cornerGrdList) "
"
#_____________________________________________________

# Mass
#_____________________________________________________
set inputs(deadRoof)  [expr $deadFac*47.88/$g*56.0] 		;#=46 (D) + 10 (superDead)
set inputs(deadFloor) [expr $deadFac*47.88/$g*61.7] 		;#64.7= 46(D)+15(superDead)+3.7(Facade) in kg/m2
set inputs(liveRoof)  [expr 1.*47.88/$g*30]
set inputs(liveFloor) [expr 1.*47.88/$g*50]
set inputs(perimBeamDead) 370.							;#kg/m of perimeter beaam
set inputs(deadMassFac) 1.05
set inputs(liveMassFac) 0.25
set inputs(selfWeightMultiplier) 1
set inputs(leaningAreaFac) 1.0
#_____________________________________________________

# Damping
#_____________________________________________________
set inputs(dampRat) 0.05
set inputs(numModes) 3
set inputs(modeI) 1
set inputs(modeJ) 2
#_____________________________________________________

# Material
#_____________________________________________________
set inputs(matType) "Steel"
# set inputs(matType) "Concrete"
if {$inputs(matType) == "Steel"} {
	#
	# set hardeningRatio 0.001		;#for fiber method
	set inputs(fyBeam) [expr 1*345.e6]
	set inputs(fyClmn) [expr 1*345.e6]
	set inputs(fyBrace) [expr 1*323.e6]
	set inputs(fyGusset) [expr 1*345.e6]
	set inputs(beamRy) 1.1
	set inputs(clmnRy) 1.1
	set inputs(braceRy) 1.4
	set inputs(isColumnA992Gr50) 1
	set inputs(isBeamA992Gr50) 1
	set inputs(nu) 0.15
	set inputs(Es) 2.e11
	set inputs(E) 2.e11
	set inputs(G) [expr $inputs(E)/2/(1.+$inputs(nu))]
	set inputs(steelDens)		7850.			;#kg/m3
	set inputs(density)		7850.			;#kg/m3
	set inputs(useRBSBeams) 1
	set inputs(usePZSpring) 0
} else {
	# concrete
	set inputs(fc0) 30.0e6
	set inputs(Ec)  [expr 4700.*sqrt($inputs(fc0)*1.e-6)*1.e6]
	set inputs(E) $inputs(Ec)
	set inputs(Gc) [expr $inputs(Ec)/2/(1.+$inputs(nu))]
	set inputs(G) $inputs(Gc)
	set inputs(RyConc) 1.
	set inputs(nu) 0.15
	set inputs(concDens)	2500.			;#kg/m3
	set inputs(density)		2500.			;#kg/m3
}
#_____________________________________________________

set inputs(defLeanClmn) 1		;# set to 1 when some gravity columns are excluded from the model
set inputs(leaningArea) [expr $inputs(leaningAreaFac)*$inputs(planArea)]

#Units
#_____________________________________________________
set inputs(cUnitsToN) 1.
set inputs(cUnitsToM) 1.
#_____________________________________________________
# General
set inputs(rigidZoneFac) 0.5
set inputs(clmnBasePlateHeightFac) 1.	;#ratio of the column section height considered as the base plate connection offset
set inputs(clmnGeomtransfType) Linear	;#set to Linear when all story gravity force is applied on leaning column

#_____________________________________________________
# Lumped
# set inputs(SG1,hingeType) Lignos
# set inputs(SG1,hingeType) ASCE
# set inputs(SG1,eleType) Hinge
# set inputs(nFactor) 1.
# set inputs(MyFac) 1.				;#to allow calibrating the model
# set inputs(lbToRy) 100
# #set inputs(clmnCrackOverwrite) 1	;#for RC members
# #set inputs(beamCrackOverwrite) 1	;#for RC members
#_____________________________________________________

#fiber
#_____________________________________________________
set inputs(numSubdivL)	6
set inputs(numSubdivT)	3
### for Hardening:
	set inputs(SG1,eleType) dispBeamColumn	; #  dispBeamColumn
	set inputs(SG1,numSeg) 1
#	#set inputs(SG1,lSeg) 2.0		;#m
	set inputs(SG1,IntegStr) {Lobatto $secTag 5}
### for Softening
# set inputs(SG1,eleType) forceBeamColumn
# set inputs(SG1,numSeg) 1
# set inputs(SG1,IntegStr) {HingeRadau $secTagI $lpI $secTagJ $lpJ $secTagM}
# set inputs(SG1,IntegStr) {HingeRadauTwo $secTagI $lpI $secTagJ $lpJ $secTagM}
# set inputs(SG1,IntegStr) {Lobatto -sections 5 $secTagI $secTagM $secTagM $secTagM $secTagJ}
# #set beamLpFac 0.2

### for Hardening:
	set inputs(SG2,eleType) forceBeamColumn	; #  dispBeamColumn
	set inputs(SG2,numSeg) 1
#	#set inputs(SG1,lSeg) 2.0		;#m
	set inputs(SG2,IntegStr) {Lobatto $secTag 5}
### for Softening
# set inputs(SG1,eleType) forceBeamColumn
# set inputs(SG1,numSeg) 1
# set inputs(SG1,IntegStr) {HingeRadau $secTagI $lpI $secTagJ $lpJ $secTagM}
# set inputs(SG1,IntegStr) {HingeRadauTwo $secTagI $lpI $secTagJ $lpJ $secTagM}
# set inputs(SG1,IntegStr) {Lobatto -sections 5 $secTagI $secTagM $secTagM $secTagM $secTagJ}
# #set beamLpFac 0.2

# #set recMemSegs "1 3 4 6"

#### Braces ####
# set inputs(RG,eleType) forceBeamColumn
set inputs(braceGeomType) Corotational
set inputs(braceSpanRat) [expr 1./2.]
set inputs(imperfectRat) 0.002
set inputs(RG,numSeg) 10				;#must be even
set inputs(braceInteg) {Lobatto $secTag 3}
# set inputs(seeGussetSpring) 1
#_____________________________________________________

set inputs(secFolder) $inputs(generalFolder)/../sections/steel
set inputs(floorMass) [expr ($inputs(deadMassFac)*$inputs(deadFloor)+$inputs(liveMassFac)*$inputs(liveFloor))*$inputs(planArea)+$inputs(deadMassFac)*$inputs(perimBeamDead)*$inputs(planPerim)]
set inputs(roofMass) [expr ($inputs(deadMassFac)*$inputs(deadRoof)+$inputs(liveMassFac)*$inputs(liveRoof))*$inputs(planArea)]
puts "inputs(floorMass)= $inputs(floorMass)"
puts "inputs(roofMass)= $inputs(roofMass)"
puts "totalWeight = [expr 9.81*($inputs(roofMass)+($inputs(nFlrs)-1)*$inputs(floorMass))/1000.] kN"
set diaphMassList	""
for {set j $inputs(nFlrs)} {$j >= 1} {incr j -1} {
	set mass $inputs(floorMass)
	set rotMass 0
	if {$j == $inputs(nFlrs)} {
		set mass $inputs(roofMass)
	}
	lappend diaphMassList $mass
	lappend diaphMassList $rotMass
}

set xBraceLabels "
	R1
"
set xBeamLabels "
	B1
"
set yBeamLabels "
"
for {set i 1} {$i <= $inputs(nFlrs)} {incr i} {
    set xBeamFixityList($i) "
        00
    "
    set yBeamReleaseList($i) "
	"
}
set columnLabels "
	C1 C1
"
for {set i 1} {$i <= $inputs(nFlrs)} {incr i} {
	set columnAngleList($i) "
		0 0
	"
}
set L [expr 0.5*6.1*(1.05*$inputs(deadFloor)+0.25*$inputs(liveFloor))*$g+$inputs(perimBeamDead)*$g]
set L [expr 0.5*6.1*(1.05*$inputs(deadFloor)+0.25*$inputs(liveFloor))*$g+$inputs(perimBeamDead)*$g]
for {set j 1} {$j < $inputs(nFlrs)} {incr j} {
	set beamLoadListX($j) "$L"
}

set L [expr 0.5*6.1*(1.05*$inputs(deadRoof)+0.25*$inputs(liveRoof))*$g]
set j $inputs(nFlrs)
set beamLoadListX($j) "$L"

set settingsGroup(B1) SG1
set settingsGroup(C1) SG2
set settingsGroup(R1) RG
