# parameters:
# ry: radius of gyration in the weak-axis
# Lb: unbraced length
# Ry: ratio of expected yield stress to Fy
# cUnitL: coefficient to convert inch to other units
# cUnitFy: coefficient to convert ksi to other units

# if length unit is:
# inch  >> cUnitL = 1.
# meter >> cUnitL = 0.0254
# cm    >> cUnitL = 2.54
# mm    >> cUnitL = 25.4

# if Fy unit is:
# ksi  			>> cUnitFy = 1.
# N/m2			>> cUnitFy = 6894757.
# N/mm2 (MPa) 	>> cUnitFy = 6.894757
# kgf/cm2     	>> cUnitFy = 70.30696

proc computeHingeWBeam {matTag d tw bf tf ISec ZSec Lmem LbToRy Es Fy Ry nFac MyFac cUnitL cUnitFy isA992Gr50} {
	
	# calculate thetaP, thetaPC and lambda
	set hw		[expr $d-2.*$tf]
	set Fye		[expr $Fy*$Ry];		# expected (effective) yield stress
	set LShear 	[expr $Lmem/2.]
	set L 		$LShear
	
	if {$isA992Gr50} {
		set thetaP	[expr 0.07  *  ($hw/$tw)**-0.3  *  ($bf/$tf/2.)**-0.1  *  ($L/$d)**0.3  *  ($d/21./$cUnitL)**-0.7]
		set thetaPC	[expr 4.6  *  ($hw/$tw)**-0.5  *  ($bf/$tf/2.)**-0.8  *  ($d/21./$cUnitL)**-0.3]
		set lambda 	[expr 85.  *  ($hw/$tw)**-1.26  *  ($bf/$tf/2.)**-0.525  *  ($LbToRy)**-0.130  *  ($Es/$Fye)**0.291]
	
	} else {
		set thetaP	[expr 0.087 * ($hw/$tw)**-0.365  *  ($bf/$tf/2.)**-0.14  *  ($L/$d)**0.34  *  ($d/21./$cUnitL)**-0.721  *  ($Fye/50./$cUnitFy)**-0.23]
		set thetaPC	[expr 5.7  *  ($hw/$tw)**-0.565  *  ($bf/$tf/2.)**-0.8  *  ($d/21./$cUnitL)**-0.28  *  ($Fye/50./$cUnitFy)**-0.43]
		set lambda	[expr 500.  *  ($hw/$tw)**-1.34  *  ($bf/$tf/2.)**-0.595  *  ($Fye/50./$cUnitFy)**-0.36]
	}
	
	# calculate effective yield moment(My)
	set beta 1.2
	set Myp	 [expr $ZSec*$Fye]
	set My	 [expr $MyFac*$beta*$Myp]
	
	# define peak moment (Mu) to effective yield moment (My) ratio
	set MuMyFac		1.1
	
	# define some parameters
	set c			1.
	set DPos		1.
	set DNeg		1.
	set KResidual	0.4;
	set thetaU 		0.2

	# calculate member stiffness and strain hardening coefficient
	set ke [expr 6.*$Es*$ISec/$Lmem]
	set as [expr $My*($MuMyFac-1)/($ke*$thetaP) ];	
	
	# define bilin material
	uniaxialMaterial Bilin $matTag $ke $as $as $My -$My $lambda $lambda 10000. $lambda $c $c $c $c $thetaP $thetaP $thetaPC $thetaPC $KResidual $KResidual $thetaU $thetaU $DPos $DNeg $nFac
}