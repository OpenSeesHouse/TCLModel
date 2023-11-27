# parameters:
# ry: radius of gyration in the weak-axis
# Lb: unbraced length
# Ry: ratio of expected yield stress to Fy
# cUnitToKsi: coefficient to convert Fy units to ksi

proc computeHingeWColumn {matTag d tw bf tf ISec ZSec Lmem LbToRy Es Fy Ry nFac MyFac cUnitToKsi isA992Gr50 ASec Pg} {
	
	# calculate thetaP, thetaPC and lambda
	set hw		[expr $d-2*$tf]
	set Fye		[expr $Fy*$Ry];		# expected (effective) yield stress
	set LShear 	[expr $Lmem/2.]
	set L 		$LShear
	set Pg		[expr 1.*abs($Pg)]
	set Pye		[expr 1.*$Fye*$ASec];
	set thetaP	[expr (294. * ($hw/$tw)**-1.7 * ($LbToRy)**-0.7 * (1-$Pg/$Pye)**1.6)]
	if {$thetaP > 0.2} {set thetaP 0.2}
	set thetaPC	[expr (90. * ($hw/$tw)**-0.8 * ($LbToRy)**-0.8 * (1-$Pg/$Pye)**2.5)]
	if {$thetaPC > 0.3} {set thetaPC 0.3}
	
	if {$isA992Gr50} {
		set lambda [expr 85.  *  ($hw/$tw)**-1.26  *  ($bf/$tf/2. )**-0.525  *  ($LbToRy)**-0.130  *  ($Es/$Fye)**0.291]
	
	} else {
		set lambda	[expr 500.  *  ($hw/$tw)**(-1.34)  *  ($bf/$tf/2.)**(-0.595)  *  ($Fye/50.*$cUnitToKsi)**(-0.36)]
	}
	
	# check if column must be treated as force-controlled elements
	if {$Pg/$Pye > 0.6} {
		puts "Warning: Pg/Pye > 0.6: current hinge model for columns may not be suitable"
		puts "columns need to be treated as force-controlled elements"
		puts "see computeHingeWColumn.tcl file and ASCE/SEI 41-17"
	}
	
	# calculate effective yield moment reduced by the applied load (My)
	# it is showed by My* in the references
	if {$Pg/$Pye <= 0.2} {
		set My [expr 1.15*$ZSec*$Fye*(1-$Pg/$Pye)]
	
	} elseif {$Pg/$Pye > 0.2} {
		set My [expr 1.15*$ZSec*$Fye*(9./8.*(1-$Pg/$Pye))]
	}
	set My [expr $MyFac*$My]
	
	# calculate peak moment (Mu) to effective yield moment (My) ratio
	set alpha		[expr 12.5 * ($hw/$tw)**-0.2 * ($LbToRy)**-0.4 * (1-$Pg/$Pye)**0.4]
	
	if {$alpha < 1} {
		set alpha 1.
	
	} elseif {$alpha > 1.3} {
		set alpha 1.3
	}
	
	set MuMyFac		$alpha
	
	# define some parameters
	set c			1.
	set DPos		1.
	set DNeg		1.
	set KResidual	[expr 0.5-0.4*$Pg/$Pye]
	set thetaU 		0.15
	
	# member stiffness and strain hardening coefficient
	set ke [expr 6.*$Es*$ISec/$Lmem]
	set as [expr $My*($MuMyFac-1)/($ke*$thetaP) ];	
	
	# define bilin material
	uniaxialMaterial Bilin $matTag $ke $as $as $My -$My $lambda $lambda 10000. $lambda $c $c $c $c $thetaP $thetaP $thetaPC $thetaPC $KResidual $KResidual $thetaU $thetaU $DPos $DNeg $nFac
}