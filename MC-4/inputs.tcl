set inputs(sharedInputsFile) $inputs(generalFolder)/sharedInputs/inputs_NIST3d-hinge.tcl
set inputs(nFlrs) 4
set inputs(nBaysY) 5
set inputs(lBayY) "6.09 6.09 6.09 6.09 6.09"
set inputs(eccRatX) 0.0
set inputs(deadRoof)  [expr 1.1*47.88/$g*56.0] 		;#=46 (D) + 10 (superDead)
set inputs(deadFloor) [expr 1.1*47.88/$g*61.7] 		;#64.7= 46(D)+15(superDead)+3.7(Facade) in kg/m2
set inputs(liveRoof)  [expr 1.*47.88/$g*30]
set inputs(liveFloor) [expr 1.*47.88/$g*50]
set inputs(perimBeamDead) 370.							;#kg/m of perimeter beaam
set inputs(deadMassFac) 1.05
set inputs(liveMassFac) 0.25

set xBraceLabels "
	-  -  -  -  - 
	-  -  -  -  -  
	-  -  -  -  -  
	-  -  -  -  -  
	-  -  -  -  -  
	-  -  -  -  - 
"
set yBraceLabels "
	-  R1 -  R1 - 
	-  -  -  -  - 
	-  -  -  -  - 
	-  -  -  -  - 
	-  -  -  -  - 
	-  R1 -  R1 - 
"
# - : gravity beam
# B2: SMF lateral beam
set xBeamLabels "
	-  B2 B2 B2 - 
	-  -  -  -  -  
	-  -  -  -  -  
	-  -  -  -  -  
	-  -  -  -  -  
	-  B2 B2 B2 - 
"
set yBeamLabels "
	-  B3 -  B3 - 
	-  -  -  -  - 
	-  -  -  -  - 
	-  -  -  -  - 
	-  -  -  -  - 
	-  B3 -  B3 - 
"
# - : gravity column
# C2: external SMF column
# C3: internal SMF column
# C4: external CBF column
set columnLabels "
	-   C2 C3 C3 C2 - 
	C4  -  -  -  -  C4
	C4  -  -  -  -  C4
	C4  -  -  -  -  C4
	C4  -  -  -  -  C4
	-   C2 C3 C3 C2 - 
"
for {set i 1} {$i <= $inputs(nFlrs)} {incr i} {
	set columnAngleList($i) "
		0 90 90 90 90  0  
		0  0  0  0  0  0  
		0  0  0  0  0  0  
		0  0  0  0  0  0  
		0  0  0  0  0  0  
		0 90 90 90 90  0  
	"
}

set L [expr (1.05*$inputs(deadFloor)+0.25*$inputs(liveFloor))*$g]
for {set j 1} {$j < $inputs(nFlrs)} {incr j} {
	set deckLoad($j) "
		$L $L $L $L $L
		$L $L $L $L $L
		$L $L $L $L $L
		$L $L $L $L $L
		$L $L $L $L $L
	"
}
set L [expr (1.05*$inputs(deadRoof)+0.25*$inputs(liveRoof))*$g]
set j  $inputs(nFlrs)
set deckLoad($j) "
	$L $L $L $L $L
	$L $L $L $L $L
	$L $L $L $L $L
	$L $L $L $L $L
	$L $L $L $L $L
"
##deckLoadDir == X|Y
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set deckLoadDir($j) "
		X X X X X
		X X X X X
		X X X X X
		X X X X X
		X X X X X
	"
}

## beam end releases about local z axis
## R:retained	F:free
# for {set i 1} {$i <= $inputs(nFlrs)} {incr i} {
#     set xBeamReleaseList($i) "
#         FF RR RR RR FF
#         FF FF FF FF FF
#         FF FF FF FF FF
#         FF FF FF FF FF
#         FF FF FF FF FF
#         FF RR RR RR FF
#     "
#     set yBeamReleaseList($i) "
#         FF FF FF FF FF
#         FF FF FF FF FF
#         FF FF FF FF FF
#         FF FF FF FF FF
#         FF FF FF FF FF
#         FF FF FF FF FF
#     "
# }
