proc computeHingeRBS {ID d tw bf tf I33 Z33 L lbToRy Es fy Ry nFactor cUnitToIn cUnitToKsi} {

	#RBS section proprties following Lignos

	set h [expr $d-2.*$tf]
	set ke [expr $Es*$I33*6./$L]
	# set Ny [expr $area*$fy]
	set my [expr $Ry*$fy*$Z33]
	set mc [expr $my*1.09]
	set tetay [expr $my/$ke]
	set tetap [expr 0.19*(($h/$tw)**-0.3145)*(($bf/(2.0*$tf))**-0.1)*($lbToRy**-0.1185)*(($L/$d)**0.113)*(($d*$cUnitToIn/(21))**-0.76)*(($fy*$cUnitToKsi/50)**-0.07)]
	# set tetap [expr $tetap+$tetay]
	set tetapc [expr 9.62*(($h/$tw)**-0.513)*(($bf/(2.0*$tf))**-0.863)*($lbToRy**-0.108)*(($fy*$cUnitToKsi/50)**-0.36)]
	# puts "tetapc= 4.645*(($h/$tw)**-0.449)*(($bf/(2.0*$tf))**-0.837)*(($d*$cUnitToIn/(21))**-0.265)*(($fy*$cUnitToKsi/50)**-1.136)"
	# puts "tetapc= $tetapc"
	# set tetapc [expr $tetap + $tetapc]
	set Lamda [expr 592*(($h/$tw)**-1.138)*(($bf/(2.0*$tf))**-0.632)*($lbToRy**-0.205)*(($fy*$cUnitToKsi/50)**-0.391)]
	set alfah [expr ($mc-$my)/$tetap/$ke]
	set alfac [expr -$mc/$tetapc/$ke]

	set tetau 0.2
	uniaxialMaterial Bilin $ID $ke $alfah $alfah $my -$my $Lamda 0\
		0 0 1 0 0 0 $tetap $tetap $tetapc $tetapc 0.4 0.4 $tetau $tetau 1 1 $nFactor
}
