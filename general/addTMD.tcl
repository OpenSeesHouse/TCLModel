set massTotal 0
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set massTotal [expr $massTotal + $diaphMass($j,X)]
}

for \{set i 0} \{ $i < $numTMDs } \{ incr i } \{
    if { $TMDOptimFlag($i) == 1} {
        set Name "Dr.Danhartog"
        set alfaOptim        [expr 1/(1+$muTMD($i))]
        set kesiOptim        [expr pow (3*$muTMD($i)/(8*(1+$muTMD($i))),0.5)] 
    } elseif {$TMDOptimFlag($i) == 2} {
        set Name "Dr.Fojeno"
        set alfaOptim        [expr pow ((1-$muTMD($i))/(2),0.5)/(1+$muTMD($i))]
        set kesiOptim        [expr 0.5* (pow ($muTMD($i)*(1+0.75*$muTMD($i))/((1+$muTMD($i))*(1+0.5*$muTMD($i))),0.5))]
    } elseif {$TMDOptimFlag($i) == 3} {
        set Name Dr.Royangerd
        set alfaOptim      [expr pow ((2+$muTMD($i))/(2*(pow ((1+$muTMD($i)),2))),0.5)]
        set kesiOptim       [expr pow (($muTMD($i)*(4+3*$muTMD($i)))/(4*(pow ((1+$muTMD($i)),3))),0.5)] 
    } elseif {$TMDOptimFlag($i) == 4} {
        set Name ME
        set alfaOptim        [expr 1/(1+$muTMD($i))]; 
        set kesiOptim        [expr pow ((3*$muTMD($i))/(8*(1+$muTMD($i))),0.5)]; 	
    }
    if {$applyModif} {
        set alfaOptim [expr ($alfaOptim-((0.241+1.7*$muTMD($i)-(pow (2.6,$muTMD($i)))*$kesi)-(1-1.9*$muTMD($i)+$muTMD($i)*$muTMD($i))*($kesi*$kesi)))]; #$alfaOptim ;# 
        set kesiOptim [expr ($kesiOptim+(0.13+0.12*$muTMD($i)+0.4**$muTMD($i))*$kesi-(0.01-0.9*$muTMD($i)+3*$muTMD($i)*$muTMD($i))*$kesi*$kesi)];#$kesiOptim  ;# 
    }

    set omegaTMD    [expr $alfaOptim*$omega_1];
    set kesiTMD [expr $kesiOptim*100];
    
    set massTMD [expr $massTotal*$massRat($i)];
    set K_TMD [expr 1*$massTMD*pow($omegaTMD,2)]
    set C_TMD [expr 2*$kesiTMD*$massTMD*$omegaTMD]

    set TMDNodeTag [expr 10000+$i]
    set refNodePos $TMDLoc($i,nFlr),99
    set refNode [manageFEData -getNode $refNodePos]
    eval "node $TMDNodeTag  [manageFEData -getNodeCrds $refNodePos] -mass $massTMD    $massTMD   $massTMD  0.  0.  0."

    equalDOF $refNode TMDNodeTag 3 4 5 6 

    set mat1 [expr 10001*10+$i]
    set mat1 [expr 10002*10+$i]
    uniaxialMaterial Elastic $mat1 $K_TMD
    uniaxialMaterial Viscous $mat2 $C_TMD 1
    # uniaxialMaterial Elastic 300  1.e8
    element zeroLength TMDNodeTag   $refNode  $TMDNodeTag  -mat $mat1  $mat2 $mat1  $mat2 -dir 1 1 2 2
}