set inputs(nFlrs) 4
set inputs(eccRatX) 0.0
set inputs(nBaysY) 4
set inputs(lBayY) "6.09 9.14 9.14 6.09 6.09"
set inputs(deadRoof)  [expr 1.6*47.88/$g*56.0] 		;#=46 (D) + 10 (superDead)
set inputs(deadFloor) [expr 1.6*47.88/$g*64.7] 		;#64.7= 46(D)+15(superDead)+3.7(Facade) in kg/m2
set inputs(liveRoof)  [expr 1.6*47.88/$g*30]
set inputs(liveFloor) [expr 1.6*47.88/$g*50]
set inputs(leaningAreaFac) 0.5
# - : gravity beam
# B2: SMF lateral beam
set xBeamLabels "
	-  B2 B2 B2 - 
	-  -  -  -  -  
	-  -  -  -  -  
	-  -  -  -  -  
	-  B2 B2 B2 - 
"
set yBeamLabels "
	-  B2 -  B2 - 
	-  -  -  -  - 
	-  -  -  -  - 
	-  -  -  -  - 
	-  B2 -  B2 - 
"
# - : gravity column
# C2: external SMF column
# C3: internal SMF column
# C4: external CBF column
# C5: internal CBF column
set columnLabels "
	-   C2 C3 C3 C2 - 
	C4  -  -  -  -  C4
	C5  -  -  -  -  C5
	C4  -  -  -  -  C4
	-   C2 C3 C3 C2 - 
"
for {set i 1} {$i <= $inputs(nFlrs)} {incr i} {
	set columnAngleList($i) "
		0 90 90 90 90  0  
		0  0  0  0  0  0  
		0  0  0  0  0  0  
		0  0  0  0  0  0  
		0 90 90 90 90  0  
	"
}

set L [expr (1.2*$inputs(deadFloor)+1.0*$inputs(liveFloor))*$g]
for {set j 1} {$j < $inputs(nFlrs)} {incr j} {
	set deckLoad($j) "
		$L $L $L $L $L
		$L $L $L $L $L
		$L $L $L $L $L
		$L $L $L $L $L
		$L $L $L $L $L
	"
}
set L [expr (1.2*$inputs(deadRoof)+1.0*$inputs(liveRoof))*$g]
set j  $inputs(nFlrs)
set deckLoad($j) "
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
	"
}
set inputs(defLeanClmn) 1		;# set to 1 when some gravity columns are excluded from the model
