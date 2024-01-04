set inputs(doEigen) 1
set inputs(recordCADSees) 0
set inputs(analType) push
set inputs(targetDriftList) "0.08"
set inputs(pushDir) X
set inputs(doRayleigh) 0
set inputs(generalFolder) ../../general
set inputs(numPushSteps) 100
set recordShapes 1
set patternType "force"			;#force/disp
set updateMethod "incremental"	;#incremental/absolute
set seeSpectrum 0
# set specFacs 0.5
set numStepDivs 10
set combinMethod SRSS; # SRSS/CQC
set inputs(resFolder) push-$inputs(pushDir)-adaptive-$patternType-$combinMethod-seeSpec-$seeSpectrum
set inputSpec ""		;# empty:exclude spectral weight factor
if {$seeSpectrum} {
	if {$patternType == "force"} {
		set inputSpec "avrgScaledAccelSpecs.txt"		;# Acceleration spectrum for patternType == "force"
	} else {
		set inputSpec "avrgScaledDispSpecs.txt"		;# displacement, otherwise.
		# set inputSpec "../general/GMfiles/spectra/rec-1-mu-1.00-displacement.txt"		;# displacement, otherwise.
	}
}
# set models(1) Examples/SMF2d-4
# set models(1) Examples/SMF2d-4-fiber
# set models(1) Examples/BRBF2D-4
# set models(1) Examples/NIST-sym-4
set models(1) Examples/BRBF2D-4
set inputs(checkResultAvailable) 0
set isAdaptive 1
foreach iModel "1" {
	set inputs(modelFolder) $models($iModel)
	cd $inputs(modelFolder)
	source $inputs(generalFolder)/runSinglePush.tcl
	cd $inputs(generalFolder)/../
}

