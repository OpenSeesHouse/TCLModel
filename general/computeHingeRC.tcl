# using Haselton et al. 2016 calibration to find ModifiedMedinaIbarraKrawinkler parameters from peroperties vlues.
# rectangular Column or Beam ---N,mm.
#Assumptions: Ls=L/2
#Ec:Module of elasticity (MPa)  H: height of column cross section,  B: width of column cross section
#P: axial load in column (N)
#asl: indicator variable (0 or 1) to signify possibility of longitudinal reinforcing bar slip past the column end ; asl = 1 if slip is possible ...
#nonSymmetricFac (defined by Fardis and Biskinis [2003]; Panagiotakos [2001])
#SStirrup:tie spacing ,  DBarBot: longitudinal bar diameter at bottom.
#rhosh: Area ratio of transverse reinforcement, in region of close spacing at column end (Ash/sb)
#fpc: compressive strength of unconfined concrete, based on standard cylinder test (MPa)
#fy: reinforcing steel yield strength (MPa)
#EIstf = effective cross-sectional moment of inertia for secant stiffness through 40% yield
#EIy = effective cross-sectional moment of inertia for secant stiffness through yield point

# if fyBot and fpc unit is:
# N/mm2 (MPa) 	>> cUnitToMPa = 1.
# N/m2			>> cUnitToMPa = 1.e-6
# kgf/cm2     	>> cUnitToMPa = 0.0981
# ksi  			>> cUnitToMPa = 6.9

proc ComputeHingeRC {matTag B H L cover P fpc Ec fy MyP MyN nBarBot DBarBot nBarTop DBarTop nBarInt DBarInt nBarSh DBarSh SStirrup inputs(nFactor) cUnitToMPa} {
	
	
	set stiffnessType 1;	# 1: 40%  2: yield
	set asl 1; 				# 1: include bond-slip  0: don't include bond-slip 
	set epsilonCU 0.0035
	
	set A [expr $H*$B];
	set Ig [expr $B*$H**3/12.]
	
	if {$stiffnessType == 1} {
		set EIstfoEIg [expr min(max(0.77*pow((0.1+$P/$fpc/$A), 0.80)*pow(($L/2./$H),0.43),0.35),0.8)]
		# set EIyoEIg [expr min(max(0.75*pow((0.1+$P/$fpc/$A), 0.80),0.2),0.6)];
		set crackFac $EIstfoEIg
	} elseif {$stiffnessType == 2} {
		set EIyoEIg [expr min(max(0.30*pow((0.1+$P/$fpc/$A), 0.80)*pow(($L/2./$H),0.72),0.2),0.6)];
		# set EIstfoEIg [expr min(max(1.33*pow((0.1+$P/$fpc/$A), 0.80),0.35),0.8)]
		set crackFac $EIyoEIg
	}
	
	set pi [expr 2.0*asin(1.0)];	
	set inputs(nu) [expr $P/($fpc*$A)];
	
	# set sn [expr ($SStirrup/$DBarTop)];
	set sn [expr ($SStirrup/$DBarBot)*pow($fy*$cUnitToMPa/100.,0.5)];
	
	set Ash [expr $nBarSh*pow($DBarSh,2.)*$pi/4.];
	
	set AsBot [expr $nBarBot*pow($DBarBot,2.)*$pi/4.];
	set AsTop [expr $nBarTop*pow($DBarTop,2.)*$pi/4.];
	
	set AsInt [expr $nBarInt*pow($DBarInt,2.)*$pi/4.];
	set rhosh [expr $Ash/$SStirrup/$B];
	set d [expr $H-($cover+$DBarSh+($DBarBot/2.))];
	set AsTotal [expr $AsBot+$AsTop+$AsInt];
	
	set rhoTotal [expr $AsTotal/$B/$d];

	set thetaCapPl [expr 0.12*(1+0.55*$asl)*pow(0.16,$inputs(nu))*pow((0.02+40*$rhosh),0.43)*pow(0.54,(0.01*$fpc*$cUnitToMPa))*pow(0.66,(0.1*$sn))*pow(2.27,(10.0*$rhoTotal))];
	
	# set thetaCapPl [expr 0.10*(1+0.55*$asl)*pow(0.16,$inputs(nu))*pow((0.02+40*$rhosh),0.43)*pow(0.54,(0.01*$fpc*$cUnitToMPa))];

	#Fardis and Biskinis 2003 nonSym
	set rhoBot [expr $AsBot/$B/$d];
	set rhoTop [expr $AsTop/$B/$d];
	set compValue [expr max(0.01,$rhoTop*$fy/$fpc)]
	set tensileValue [expr max(0.01,$rhoBot*$fy/$fpc)]
	set nonSymmetricFacP [expr pow($compValue/$tensileValue,0.225)];
	set nonSymmetricFacN [expr pow($nonSymmetricFacP,-1.)];
	set thetaCapPlP [expr $nonSymmetricFacP*$thetaCapPl];
	set thetaCapPlN [expr $nonSymmetricFacN*$thetaCapPl];
	
	set thetaPc [expr min(0.76*pow(0.031,$inputs(nu))*pow((0.02+40.*$rhosh),1.02),0.1)];

	set McoMy 1.13;

	set K0 [expr 6.*$Ec*$Ig*$EIstfoEIg/$L];
	set thetaYP [expr $MyP/$K0];
	set lambdaPrime [expr 170.7*pow(0.27,$inputs(nu))*pow(0.1,($SStirrup/$d))];
	set lambda [expr $lambdaPrime*$thetaYP];
	
	# puts "EIyoEIg=$EIyoEIg";
	# puts "$EIstfoEIg";
	# puts "$thetaCapPl";
	# puts "$thetaCapPlP";
	# puts "$thetaCapPlN";
	# puts "$thetaPc";
	# puts "$lambda";
	# puts "$nonSymmetricFacP";

	
	set thetaYN [expr $MyN/$K0];
	set as [expr ($McoMy-1.)/($thetaCapPlP/$thetaYP)];
	set LambdaS $lambda;
	set LambdaC $lambda;
	set LambdaA $lambda;
	set LambdaK $lambda;
	set cS 1.;
	set cC 1.;
	set cA 1.;
	set cK 1.;
	set thetaPP $thetaCapPlP;
	set thetaPN $thetaCapPlN;
	set thetaPcP $thetaPc;
	set thetaPcN $thetaPc;
	set ResP 0.;
	set ResN 0.;
	set thetaUP [expr $thetaYP+$thetaPP+$thetaPcP];
	set thetaUN [expr $thetaYN+$thetaPN+$thetaPcN];
	set DP 1.;
	set DN 1.;
	uniaxialMaterial ModIMKPeakOriented $matTag $K0 $as $as $MyP $MyN $LambdaS $LambdaC $LambdaA $LambdaK $cS $cC $cA $cK $thetaPP $thetaPN $thetaPcP $thetaPcN $ResP $ResN $thetaUP $thetaUN $DP $DN $inputs(nFactor); 

	# set K0 [expr ($inputs(nFactor)+1) * $K0]
	# set as [expr $as/($inputs(nFactor)+1-$inputs(nFactor)*$as)]
	# set Mc [expr $McoMy*$MyP]
	# set tetap [expr ($Mc-$MyP)/$as/$K0]
	# set alfac [expr -$Mc/$thetaPcP]
	# set ac [expr $alfac/($inputs(nFactor)+1-$inputs(nFactor)*$alfac)]
	# set $thetaPP [expr $thetaPP + $thetaYP]
	# set $thetaPN [expr $thetaPN + $thetaYN]
	# set gama [expr ($inputs(nFactor)+1)*$lambdaPrime]
	# uniaxialMaterial Clough $matTag $K0 $MyP $MyN $as $ResP $ac $thetaPP -$thetaPN $gama $gama $gama $gama 1 1 1 1
	
	return $crackFac
}