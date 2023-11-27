proc shearSpring {gFrame Fy AS2 e cv} {
	global lastMatTag
	set matTag [incr lastMatTag]
	set K0 [expr 2*$gFrame*$AS2/$e]
	set as_Plus 0.02
	set Fy_Plus [expr $cv*$AS2*0.65*$Fy]

	# set as_Neg 0.05
	# set Fy_Neg -$Fy_Plus
	# set Lamda_S 1000
	# set Lamda_C 1000
	# set Lamda_A 1000
	# set Lamda_K 1000
	# set c_S 1
	# set c_C 1
	# set c_A 1
	# set c_K 1
	# set theta_p_Plus [expr 20*$Fy_Plus/$K0]
	# set theta_p_Neg $theta_p_Plus
	# set theta_pc_Plus $theta_p_Plus
	# set theta_pc_Neg $theta_pc_Plus
	# set Res_Pos 0.4
	# set Res_Neg 0.4
	# set theta_u_Plus 0.2
	# set theta_u_Neg 0.2
	# set D_Plus 1
	# set D_Neg 1
	# uniaxialMaterial Bilin $matTag $K0 $as_Plus $as_Neg $Fy_Plus $Fy_Neg \
		# $Lamda_S $Lamda_C $Lamda_A $Lamda_K $c_S $c_C $c_A $c_K $theta_p_Plus $theta_p_Neg \
		# $theta_pc_Plus $theta_pc_Neg $Res_Pos $Res_Neg $theta_u_Plus $theta_u_Neg $D_Plus $D_Neg
		
	uniaxialMaterial Steel02 $matTag $Fy_Plus $K0 $as_Plus
	return $matTag
}