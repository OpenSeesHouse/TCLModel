set braceMatTag [manageFEData -newMaterial braceSteel]
set fy [expr $inputs(braceRy)*$inputs(fyBrace)]
uniaxialMaterial Steel02 $braceMatTag $fy $inputs(Es) 0.01 18.5 .925 .15
# uniaxialMaterial Elastic $braceMatTag $e
if [info exists inputs(BRBMat,b)] {
    set BRBMatTag [manageFEData -newMaterial BRB]
    uniaxialMaterial Steel05 $BRBMatTag [expr $inputs(RyBRB)*$inputs(fyBRB)] $inputs(Es) [expr 0.75*$inputs(BRBMat,b)] [expr $inputs(BRBMat,epsMax)*$inputs(Es)/$inputs(fyBRB)] -0.02	100000  1. 0.00001 15 0.925 0.15
}
set m -0.3
set EFrat [expr $inputs(Es)/$inputs(fyBrace)]
set missConfs(L) "| \\"
set missConfs(R) "| /"
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
    foreach dir "X Y" nGridX "$inputs(nBaysX) [expr $inputs(nBaysX)+1]" nGridY "[expr $inputs(nBaysY)+1] $inputs(nBaysY)" {
        set code [eleCodeMap $dir-Brace]
        for {set k 1} {$k <= $nGridY} {incr k} {
            for {set i 1} {$i <= $nGridX} {incr i} {
                set pos "$j,$k,$i"
                set conf $eleData(config,$code,$pos)
                foreach mem "L R" {
                    set sec $eleData(section,$code,$pos,$mem)
                    if {$sec == "-"} continue
                    set skip 0
                    foreach c $missConfs($mem) {
                        if {$conf == $c} {
                            set skip 1
                            break
                        }
                    }
                    if {$skip} continue
                    source $inputs(secFolder)/$sec.tcl
                    source $inputs(secFolder)/convertToM.tcl
                    if {$Shape != "BRB"} {
                        set ID [manageFEData -newSection brace,$j,$k,$i,$mem]
                        set lBrace [manageGeomData -getBraceLength $mem $code $pos]
                        set matID [manageFEData -newMaterial brace,$dir,$j,$k,$i,$mem]
                        if {$Shape == "SteelTube"} {
                            source $inputs(generalFolder)/ComputeFatigueTube.tcl
                            uniaxialMaterial Fatigue $matID $braceMatTag -E0 $e0 -m $m
                            Box-section $matID $ID $t3 $t2 $tf $tw $inputs(numSubdivL) $inputs(numSubdivT) [expr $G*$J]
                        } else {
                            error("brace section shape: $Shape not currently supported")
                        }
                    }
                    if {$inputs(seeGussetSpring)} {
                        set w $eleData(gussetDimI_lh,$code,$pos)
                        set l $eleData(gussetDimI_lr,$code,$pos)
                        set tp $eleData(gussetDimI_tp,$code,$pos)
                        set Lav [expr 0.67*$l]
                        set Kcal [expr 0.5*$inputs(Es)*$w*$tp**3/12./$Lav]
                        set MyGuss [expr $inputs(fyGusset)*$w*$tp**2/6.]
                        set matID [manageFEData -newMaterial gusset,$dir,$j,$k,$i,$mem]
                        uniaxialMaterial Steel02 $matID $MyGuss $Kcal 0.01
                        # uniaxialMaterial Elastic $matID [expr 0.01*$inputs(E)*$inputs(typIz)/$lBrace]
                        source $inputs(secFolder)/unsetSecProps.tcl
                    }
                }
            }
        }
    }
}
