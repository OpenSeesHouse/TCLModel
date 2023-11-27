set inputs(nFlrs) 8
set inputs(nBaysY) 5
set inputs(lBayY) "6.09 6.09 6.09 6.09 6.09"
set inputs(eccRatX) 0.0
set inputs(deadRoof)  [expr 1.5*47.88/$g*56.0] 		;#=46 (D) + 10 (superDead)
set inputs(deadFloor) [expr 1.5*47.88/$g*64.7] 		;#64.7= 46(D)+15(superDead)+3.7(Facade) in kg/m2
set inputs(liveRoof)  [expr 1.5*47.88/$g*30]
set inputs(liveFloor) [expr 1.5*47.88/$g*50]
# B1: gravity beam
# B2: SMF lateral beam
set xBeamLabels "
	B1 B2 B2 B2 B1
	B1 B1 B1 B1 B1 
	B1 B1 B1 B1 B1 
	B1 B1 B1 B1 B1 
	B1 B1 B1 B1 B1 
	B1 B2 B2 B2 B1
"
set yBeamLabels "
	B1 B2 B1 B2 B1
	B1 B1 B1 B1 B1
	B1 B1 B1 B1 B1
	B1 B1 B1 B1 B1
	B1 B2 B1 B2 B1
"
# C1: gravity column
# C2: external SMF column
# C3: internal SMF column
# C4: external CBF column
set columnLabels "
	C1  C2 C3 C3 C2 C1
	C4  C1 C1 C1 C1 C4
	C4  C1 C1 C1 C1 C4
	C4  C1 C1 C1 C1 C4
	C4  C1 C1 C1 C1 C4
	C1  C2 C3 C3 C2 C1
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
for {set i 1} {$i <= $inputs(nFlrs)} {incr i} {
    set xBeamReleaseList($j) "
        FF RR RR RR FF
        FF FF FF FF FF
        FF FF FF FF FF
        FF FF FF FF FF
        FF FF FF FF FF
        FF RR RR RR FF
    "
    set yBeamReleaseList($j) "
        FF FF FF FF FF
        FF FF FF FF FF
        FF FF FF FF FF
        FF FF FF FF FF
        FF FF FF FF FF
        FF FF FF FF FF
    "
}