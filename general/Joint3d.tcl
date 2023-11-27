proc Joint3D {eleTag Nd1 Nd2 Nd3 Nd4 Nd5 Nd6 NdC args} {
	set option [lindex $args 0]	;# 1: rigid beams without shear springs
								;# 2: Altoontash element with shear springs
	if {$option == 1} {
		set beamXProps [lrange $args 1 4]
		set beamYProps [lrange $args 5 8]
		set clmnProps [lrange $args 9 12]
	# puts "beamXProps= $beamXProps"
		set xA [lindex $beamXProps 0]
		set yA [lindex $beamYProps 0]
		set cA [lindex $clmnProps  0]
		set xIy [lindex $beamXProps 1]
		set yIy [lindex $beamYProps 1]
		set cIy [lindex $clmnProps  1]
		set xIz [lindex $beamXProps 2]
		set yIz [lindex $beamYProps 2]
		set cIz [lindex $clmnProps  2]
		set xJ  [lindex $beamXProps 3]
		set yJ  [lindex $beamYProps 3]
		set cJ  [lindex $clmnProps  3]
		global XBeams
		global YBeams
		global Clmns
		global setting
		set E $inputs(E)
		set G $inputs(G)
		set crds1 [nodeCoord $Nd1]
		set x1 [lindex $crds1 0]
		set y [lindex $crds1 1]
		set z [lindex $crds1 2]
		set crds2 [nodeCoord $Nd2] 
		set x2 [lindex $crds2 0]
		set x [expr ($x1+$x2)/2.]
		node $NdC $x $y $z
		
		set fac1 1.
		set fac2 100.
		element elasticBeamColumn [expr $eleTag*100+1] $Nd1 $NdC  $xA [expr $fac1*$E] [expr 1.*$G] $xJ $xIy $xIz $XBeams
		element elasticBeamColumn [expr $eleTag*100+2] $NdC $Nd2  $xA [expr $fac1*$E] [expr 1.*$G] $xJ $xIy $xIz $XBeams
		element elasticBeamColumn [expr $eleTag*100+3] $Nd3 $NdC  $yA [expr $fac1*$E] [expr 1.*$G] $yJ $yIy $yIz $YBeams
		element elasticBeamColumn [expr $eleTag*100+4] $NdC $Nd4  $yA [expr $fac1*$E] [expr 1.*$G] $yJ $yIy $yIz $YBeams
		element elasticBeamColumn [expr $eleTag*100+5] $Nd5 $NdC  $cA [expr $fac2*$E] [expr 1.*$G] $cJ $cIy $cIz $Clmns
		element elasticBeamColumn [expr $eleTag*100+6] $NdC $Nd6  $cA [expr $fac2*$E] [expr 1.*$G] $cJ $cIy $cIz $Clmns
	} else {
		set matTag1 [lindex $args 1]
		set matTag2 [lindex $args 2]
		set matTag3 [lindex $args 3]
		set largDispFlag 0
		element Joint3D $eleTag $Nd1 $Nd2 $Nd3 $Nd4 $Nd5 $Nd6 $NdC $matTag1 $matTag2 $matTag3 $largDispFlag
	}
}
