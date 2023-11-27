
#       matID   - tag for the defined material
#       E       - modulus of elasticity
#       Fy      - yield strength
#       dc      - column depth
#       bf_c    - column flange width
#       tf_c    - column flange thickness
#       tp      - panel zone thickness
#       db      - beam depth
#       Ry      - expected value for yield strength --> Typical value is 1.2
#       as      - assumed strain hardening

proc computePanelZone {matID E Fy dc bf_c tf_c tp db Ry as} {

# Trilinear Spring
# Yield Shear
	set Vy [expr 0.55 * $Fy * $dc * $tp];
# Shear Modulus
	set G [expr $E/(2.0 * (1.0 + 0.30))]
# Elastic Stiffness
	set Ke [expr 0.95 * $G * $tp * $dc];
# Plastic Stiffness
	set Kp [expr 0.95 * $G * $bf_c * ($tf_c * $tf_c) / $db];

# Define Trilinear Equivalent Rotational Spring
# Yield point for Trilinear Spring at gamma1_y
	set gamma1_y [expr $Vy/$Ke]; set M1y [expr $gamma1_y * ($Ke * $db)];
# Second Point for Trilinear Spring at 4 * gamma1_y
	set gamma2_y [expr 4.0 * $gamma1_y]; set M2y [expr $M1y + ($Kp * $db) * ($gamma2_y - $gamma1_y)];
# Third Point for Trilinear Spring at 100 * gamma1_y
	set gamma3_y [expr 100.0 * $gamma1_y]; set M3y [expr $M2y + ($as * $Ke * $db) * ($gamma3_y - $gamma2_y)];
  
  
# Hysteretic Material without pinching and damage (same mat ID as Ele ID)
    uniaxialMaterial Hysteretic $matID $M1y $gamma1_y  $M2y $gamma2_y $M3y $gamma3_y [expr -$M1y] [expr -$gamma1_y] [expr -$M2y] [expr -$gamma2_y] [expr -$M3y] [expr -$gamma3_y] 1 1 0.0 0.0 0.0

}