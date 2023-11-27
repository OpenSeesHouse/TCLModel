proc computeDrift3d {CMDr_x CMDr_y CMDr_thet cornerCrdList CMx CMy} {
	set Vmax 0
	foreach "x y" $cornerCrdList {
		set Rx [expr $x-$CMx]
		set Ry [expr $y-$CMy]
		set Vx [expr $CMDr_x-$CMDr_thet*$Ry]
		set Vy [expr $CMDr_y+$CMDr_thet*$Rx]
		set V [expr sqrt($Vx**2.+$Vy**2.)]
		set Vmax [expr max($Vmax,$V)]
	}	
	return $Vmax
}