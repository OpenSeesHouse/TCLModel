set braceMatTag [manageFEData -newMaterial braceSteel]
uniaxialMaterial Steel02 $braceMatTag [expr $inputs(fyBrace)] $inputs(Es) 0.01 18.5 .925 .15 0.03 1.0 0.02 1.0
# uniaxialMaterial Elastic $braceMatTag $e

set m -0.3
set EFrat [expr $inputs(Es)/$inputs(fyBrace)]
set fy $inputs(fyBrace)
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
    foreach dir "X Y" nGridX "$inputs(nBaysX) [expr $inputs(nBaysX)+1]" nGridY "[expr $inputs(nBaysY)+1] $inputs(nBaysY)" {
        set code [eleCodeMap $dir-Brace]
        for {set k 1} {$k <= $nGridY} {incr k} {
            for {set i 1} {$i <= $nGridX} {incr i} {
                set pos "$j,$k,$i"
                set sec $eleData(section,$code,$pos,L)
                if {$sec == "-"} continue
                foreach mem "L R" {
                    set ID [manageFEData -newSection brace,$j,$k,$i,$mem]
                    set lBrace [manageGeomData -getBraceLength $mem $code $pos]
                    source $inputs(secFolder)/$sec.tcl
                    source ../general/ComputeFatigueTube.tcl
                    set matID [manageFEData -newMaterial brace,$j,$k,$i,$mem]
                    uniaxialMaterial Fatigue $matID $braceMatTag -E0 $e0 -m $m
					Box-section $matID $ID $t3 $t2 $tf $tw $inputs(numSubdivL) $inputs(numSubdivT) [expr $G*$J]
                    # Tube-Section $ID $matID $t3 $tf $nfd $nft
                    # Tube-Section $ID 41 $t3 $tf $nfd $nft

                    # set Lav [expr 0.67*($Lgpx**2+$Lgpy**2)**0.5]
                    # set Kcal [expr 0.5*$inputs(Es)*$Ww($j)*$Tp($j)**3/12./$Lav]
                    # set MyGuss [expr $FyGusset*$Ww($j)*$Tp($j)**2/6.]
                    # uniaxialMaterial Steel02 [expr $j*100+2*$i] $MyGuss $Kcal 0.01
                    # uniaxialMaterial Elastic [expr $j*100+2*$i] 1.e6
                }
            }
        }
    }
}
