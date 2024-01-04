set inputs(doEigen) 1
set inputs(recordCADSees) 0
set inputs(analType) push
set inputs(targetDriftList) "0.03"
set inputs(pushDir) X
set inputs(kPush) 1.
set inputs(doRayleigh) 0
set inputs(generalFolder) ../../general
set inputs(numPushSteps) 100
#read models list 
# set models(1) Examples/SMF2d-4
# set models(1) Examples/SMF2d-4-fiber
# set models(1) Examples/BRBF2D-4
# set models(1) Examples/NIST-sym-4
set models(1) Examples/CBF2D-4
set inputs(checkResultAvailable) 0
set isAdaptive 0
foreach iModel "1" {
	set inputs(modelFolder) $models($iModel)
	cd $inputs(modelFolder)
	set inputs(resFolder) push-$inputs(pushDir)
	source $inputs(generalFolder)/runSinglePush.tcl
	cd ..
}

