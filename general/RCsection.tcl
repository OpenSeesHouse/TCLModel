proc RCSection {secTag barMat confinedMat unconfinedMat B H cover nBarTop ABarTop nBarBot ABarBot nBarInt ABarInt DBarSh GJ numSubdivL numSubdivT FRPATop FRPABot FRPMatTag FRPALft FRPARgt} {
	set DBarBot [expr sqrt(4.*$ABarBot/3.1415)]
	set DBarTop [expr sqrt(4.*$ABarTop/3.1415)]
	set y1 [expr -$H/2.]
	set y2 [expr $y1 + $cover + $DBarSh + $DBarBot/2.]
	set dy [expr ($H-2.*$cover)/($nBarInt+1.)]
	set y3 [expr $y2+$dy]
	set y5 [expr $H/2.-$cover - $DBarSh - $DBarTop/2.]
	set y4 [expr $y5-$dy]
	set y6 [expr $H/2.]

	set dz [expr ($B-2.*$cover)/($nBarBot-1.)]
	set z1 [expr -$B/2.]
	set z2 [expr -$B/2.+ $cover + $DBarSh + $DBarBot/2.]
	set z3b [expr $z2 + $dz]
	set z5 [expr $B/2.-$cover - $DBarSh - $DBarBot/2.]
	set z4b [expr $z5-$dz]
	set z6 [expr $B/2.]

	set dz [expr ($B-2.*$cover)/($nBarTop-1.)]
	set z3t [expr $z2 + $dz]
	set z4t [expr $z5-$dz]

	section Fiber $secTag -GJ $GJ {
		# patch quad $matTag 	$numSubdivIJ $numSubdivJK $yI $zI $yJ $zJ $yK $zK $yL $zL
		patch quad $unconfinedMat $numSubdivL $numSubdivT $y1 $z6 $y1 $z1 $y2 $z2 $y2 $z5
		patch quad $unconfinedMat $numSubdivT $numSubdivL $y2 $z2 $y1 $z1 $y6 $z1 $y5 $z2
		patch quad $unconfinedMat $numSubdivL $numSubdivT $y5 $z5 $y5 $z2 $y6 $z1 $y6 $z6
		patch quad $unconfinedMat $numSubdivT $numSubdivL $y1 $z6 $y2 $z5 $y5 $z5 $y6 $z6
		patch quad $confinedMat   $numSubdivL $numSubdivL $y2 $z5 $y2 $z2 $y5 $z2 $y5 $z5

		if {$nBarInt != 0} {
			incr nBarBot -2
			incr nBarTop -2
			layer straight $barMat $nBarBot $ABarBot $y2 $z3b $y2 $z4b
			layer straight $barMat $nBarTop $ABarTop $y5 $z3t $y5 $z4t
			layer straight $barMat $nBarInt $ABarInt $y3 $z5 $y4 $z5
			layer straight $barMat $nBarInt $ABarInt $y3 $z2 $y4 $z2
			fiber $y2 $z5 $ABarBot $barMat
			fiber $y2 $z2 $ABarBot $barMat
			fiber $y5 $z5 $ABarTop $barMat
			fiber $y5 $z2 $ABarTop $barMat
		} else {
			layer straight $barMat $nBarBot $ABarBot $y2 $z2 $y2 $z5
			layer straight $barMat $nBarTop $ABarTop $y5 $z2 $y5 $z5
		}
		if {$FRPATop != 0} {
			fiber $y6 0.0 $FRPATop $FRPMatTag
		}
		if {$FRPABot != 0} {
			fiber $y1 0.0 $FRPABot $FRPMatTag
		}
		if {$FRPALft != 0} {
			fiber 0.0 $z6 $FRPALft $FRPMatTag
		}
		if {$FRPARgt != 0} {
			fiber 0.0 $z1 $FRPARgt $FRPMatTag
		}
	}
}