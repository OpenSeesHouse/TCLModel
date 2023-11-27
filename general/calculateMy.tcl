#using this file u can calculate My through Fardis & Panagiotakos 2001 relationships.
#inputs(Es): Steel stiffness (Module of elasticity) (MPa),  epsilonCU: Concrete ultimate strain
#fpc: compressive strength of unconfined concrete, based on standard cylinder test (MPa)
#P: axial load in column (N), H: height of column cross section,  B: width of column cross section.
#DBarTop: Top rebar diameter (mm),DBarBot: Bottom rebar diameter (mm), DBarInt: interm rebar diameter (mm),
# fy: reinforcing steel yield strength (MPa), DBarSh: stirrup bar diameter (mm);
# nBarTop: Number of Top bars; nBarBot: Number of Bottom bars; # nBarInt: Number of intermidiate bars Layers


# if fy and fpc unit is:
# N/mm2 (MPa) 	>> cUnitToMPa = 1.
# N/m2			>> cUnitToMPa = 1.e-6
# kgf/cm2     	>> cUnitToMPa = 0.0981
# ksi  			>> cUnitToMPa = 6.9


proc CalculateMy {B H cover P fpc fy inputs(Es) nBarBot DBarBot nBarTop DBarTop nBarInt DBarInt DBarSh cUnitTomm cUnitToMPa} {
	
	# assumptions:
	set epsilonCU 0.0035
	
	# all units are converted to N and mm. 
	# after calculating My the units are converted to the model unit
	# set cUnitTomm 1000.;
	# set cUnitToMPa 1e-6;
	set cUnitToN [expr $cUnitToMPa * $cUnitTomm**2.]
	
	set DBarTop [expr $DBarTop*$cUnitTomm]
	set DBarBot [expr $DBarBot*$cUnitTomm]
	set DBarInt [expr $DBarInt*$cUnitTomm]
	set DBarSh [expr $DBarSh*$cUnitTomm]
	set B [expr $B*$cUnitTomm]
	set H [expr $H*$cUnitTomm]
	set cover [expr $cover*$cUnitTomm]
	
	set inputs(Es) [expr $inputs(Es)*$cUnitToMPa]
	set fpc [expr $fpc*$cUnitToMPa]
	set fy [expr $fy*$cUnitToMPa]
	set P [expr $P*$cUnitToN]
	
	
	set pi [expr 2.0*asin(1.0)];
	set d [expr ($H-$cover-$DBarSh-$DBarBot/2.)];
	set dp [expr ($cover+$DBarSh+$DBarTop/2.)];
	
	
	
	#epsilinSy: steel yield strain.
	set epsilonSy [expr $fy/$inputs(Es)];
	# Cb: depth of compression block at balanced (mm);
	set Cb [expr $epsilonCU*$d/($epsilonCU+$epsilonSy)];
	#Ast: tension steel, without intermeddiate bars for now (mm^2);
	set Ast [expr $nBarBot*pow($DBarBot,2.)*$pi/4.];
	set Asc [expr $nBarTop*pow($DBarTop,2.)*$pi/4.];
	#rhost: tension steel ratio, without intermeddiate bars for now
	set rhost [expr $Ast/$B/$d];
	set rhosc [expr $Asc/$B/$d];
	#Asw: intermediate steel (mm^2)
	#rhosw: intermediate steel ratio. 
	set Asw [expr 2*$nBarInt*$pi/4.*pow($DBarInt,2.)];
	set rhosw [expr $Asw/$B/$d];
	set rho [expr $rhosw+$rhost+$rhosc];
	#beta1: depth of presure block factor.
	
	if {$fpc <= 30.} {
		set beta1 0.85
	} else {
		set beta1 [expr max(0.85-0.05/7.*($fpc-30.),0.65)];
	}
	
	#C: depth of compression block at balanced (mm); 
	set C [expr ($Ast*$fy-$Asc*$fy+$P)/(0.85*$B*$beta1*$fpc)];
	#isTensControlled - indicator if the section is tension reinf. (if c < cb);

	# Compute terms in Fardis Equation:
	set Ec [expr 4700.*pow($fpc,0.5)];
	set n [expr $inputs(Es)/$Ec];

	#Ac: AcomprCntrl - from Fardis - see paper; At: AtensCntrl - from Fardis - see paper;
	if {$C <= $Cb} {
		# puts "Tension Controlled";
		set AF [expr $rhosw+$rhosc+$rhost+($P/($d*$B*$fy))];
		set BF [expr $rhost+$rhosc*($dp/$d)+0.5*$rhosw*(1.+$dp/$d)+$P/($d*$fy*$B)];
	
	} else {
		# puts "Compresion Controlled";
		set AF [expr $rhosw+$rhosc+$rhost-($P/(1.8*$n*$d*$B*$fpc))];
		set BF [expr $rhost+$rhosc*($dp/$d)+0.5*$rhosw*(1.+$dp/$d)];
	}
	
	#ky: Fardis - compression zone depth (norm. by d) at yield (mm);
	set ky [expr pow((pow(($n*$AF),2.)+2.*$n*$BF),0.5)-$n*$AF];

	if {$C <= $Cb} {
		set phiy [expr $fy/($inputs(Es)*(1.-$ky)*$d)];
	} else {
		set phiy [expr 1.8*$fpc/($Ec*$ky*$d)];
	}
	set Term1 [expr $Ec*(pow($ky,2.)/2.)*(0.5*(1.+($dp/$d))-$ky/3.)];
	set Term2 [expr $inputs(Es)/2.*((1.-$ky)*$rhost+($ky-($dp/$d))*$rhosc+($rhosw/6.*(1.-($dp/$d))))*(1.-($dp/$d))];
	set MyP [expr $B*pow($d,3.)*$phiy*($Term1+$Term2)];
	# convert from N.mm to our units
	set MyP [expr 1.*$MyP/$cUnitToN/$cUnitTomm]
	

	#....calculate MyN:
	set d [expr ($H-$cover-$DBarSh-$DBarTop/2.)];
	set dp [expr ($cover+$DBarSh+$DBarBot/2.)];

	# Cb: depth of compression block at balanced (mm);
	set Cb [expr $epsilonCU*$d/($epsilonCU+$epsilonSy)];
	#Ast: tension steel, without intermeddiate bars for now (mm^2);
	set Ast [expr $nBarTop*pow($DBarTop,2.)*$pi/4.];
	set Asc [expr $nBarBot*pow($DBarBot,2.)*$pi/4.];
	#rhost: tension steel ratio, without intermeddiate bars for now
	set rhost [expr $Ast/$B/$d];
	set rhosc [expr $Asc/$B/$d];
	#Asw: intermediate steel (mm^2)
	#rhosw: intermediate steel ratio. 
	#set Asw [expr $nBarInt*$pi/4*pow($DBarInt,2)];
	#set rhosw [expr $Asw/($B)/$d];
	set rho [expr $rhosw+$rhost+$rhosc];
	#beta1: depth of presure block factor.
	# if { $fpc<=30 } {
	# set beta1 0.85
	# } else {
	# set beta1 [expr max(0.85-0.05/7*($fpc-30),0.65)];
	# }
	#C: depth of compression block at balanced (mm); 
	set C [expr ($Ast*$fy-$Asc*$fy+$P)/(0.85*$B*$beta1*$fpc)];
	#isTensControlled - indicator if the section is tension reinf. (if c < cb);

	# Compute terms in Fardis Equation:
	#set Ec [expr 4700*pow($fpc,0.5)];
	#set n [expr $inputs(Es)/$Ec];

	#Ac: AcomprCntrl - from Fardis - see paper; At: AtensCntrl - from Fardis - see paper;
	if { $C<=$Cb } {
		# puts "Tension Controlled";
		set AF [expr $rhosw+$rhosc+$rhost+($P/($d*$B*$fy))];
		set BF [expr $rhost+$rhosc*($dp/$d)+0.5*$rhosw*(1.+$dp/$d)+$P/($d*$fy*$B)];
	} else {
		# puts "Compresion Controlled";
		set AF [expr $rhosw+$rhosc+$rhost-($P/(1.8*$n*$d*$B*$fpc))];
		set BF [expr $rhost+$rhosc*($dp/$d)+0.5*$rhosw*(1.+$dp/$d)];
	}
	#ky: Fardis - compression zone depth (norm. by d) at yield (mm);
	set ky [expr pow((pow(($n*$AF),2.)+2.*$n*$BF),0.5)-$n*$AF];

	if { $C<=$Cb } {
	set phiy [expr $fy/($inputs(Es)*(1.-$ky)*$d)];
	} else {
	set phiy [expr 1.8*$fpc/($Ec*$ky*$d)];
	}
	set Term1 [expr $Ec*(pow($ky,2.)/2.)*(0.5*(1.+($dp/$d))-$ky/3.)];
	set Term2 [expr $inputs(Es)/2.*((1.-$ky)*$rhost+($ky-($dp/$d))*$rhosc+($rhosw/6.*(1.-($dp/$d))))*(1.-($dp/$d))];
	set MyN [expr $B*pow($d,3.)*$phiy*($Term1+$Term2)];
	# convert from N.mm to our units
	set MyN [expr 1.*$MyN/$cUnitToN/$cUnitTomm]

	# puts "$MyP";
	# puts "$MyN";
	
	return [list $MyP -$MyN]
}

# set inputs(Es)         2.e11
# set epsilonCU  0.003
# set fpc        30.e6
# set P          1100935.
# set B          0.4
# set H          0.762
# set DBarTop    0.030
# set DBarBot    0.03
# set DBarInt    0.03
# set nBarInt    2.05
# set nBarTop    3.02
# set nBarBot    7.02
# set cover      0.05
# set DBarSh     0.014
# set fy         400.e6

# set cUnitTomm 1000.
# set cUnitToMPa 1.e-6

# puts [CalculateMy $B $H $cover $P $fpc $fy $inputs(Es) $nBarBot $DBarBot $nBarTop $DBarTop $nBarInt $DBarInt $DBarSh $cUnitTomm $cUnitToMPa];
