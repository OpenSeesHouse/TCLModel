puts "~~~~~~~~~~~~~~~~~~~~~ Defining Isolators ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Isolators ~~~~~~~~~~~~~~~~~~~~~\n"
set j 0
foreach loc "1 2 3" locName "central X-beam-splice Y-beam-splice" {
    logCommands -comment "# $locName nodes ###\n"
    for {set i 1} {$i <= [expr $inputs(nBaysX)+1]} {incr i} {
        for {set k 1} {$k <= [expr $inputs(nBaysY)+1]} {incr k} {
            set pos "$j,$k,$i,$loc"
            if ![manageGeomData -jntExists $pos] {
                continue
            }
            set lab $isoltrLabel($k,$i)
            #bottom isolator node
            set pos2 $k,$i,$loc,i
            foreach "x y z" [manageFEData -getNodeCrds $pos] {}
            set z [expr $z-$inputs($lab,h)]
            eval "addNode $pos2 $x $y $z"
            set W $columnGravLoad(1,$k,$i)
            foreach fm "1 2 3" {
                set fmTag$fm [manageFEData -getFrictionModel $inputs($lab,mu$fm)]
                if {[set fmTag$fm] == 0} {
                    set fmTag$fm [manageFEData -newFrictionModel $inputs($lab,mu$fm)]
                    frictionModel Coulomb [set fmTag$fm] $inputs($lab,mu$fm)
                }
            }
            # Creating material for compression and rotation behaviors
            set vTag [manageFEData -getMaterial isoVertMat]
            if {$vTag == 0} {
                set vTag [manageFEData -newMaterial isoVertMat]
                uniaxialMaterial Elastic $vTag $inputs($lab,kvc);
            }
            set rTag [manageFEData -getMaterial isoRotMat]
            if {$rTag == 0} {
                set rTag [manageFEData -newMaterial isoRotMat]
                uniaxialMaterial Elastic $rTag $inputs($lab,krt);
            }

            addElement TripleFrictionPendulum $pos2 $pos2 $pos "$fmTag1 $fmTag2 $fmTag3 $vTag $rTag $rTag $rTag \
                $inputs($lab,L1) $inputs($lab,L2) $inputs($lab,L3) $inputs($lab,d1) $inputs($lab,d2) \
                $inputs($lab,d3) $W $inputs($lab,uy) $inputs($lab,kvt) $inputs($lab,minFv) $inputs($lab,tol) $inputs($lab,Fry)"
        }
    }
}
