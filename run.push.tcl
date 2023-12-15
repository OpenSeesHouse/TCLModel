set inputs(doEigen) 0
set inputs(recordCADSees) 0
set inputs(analType) push
set inputs(targetDriftList) "0.02"
set inputs(pushDir) X
set inputs(kPush) 1.
set inputs(doRayleigh) 0
set inputs(generalFolder) ../general
set inputs(generalFolder) ../general
set inputs(numPushSteps) 200
#read models list 
# set models(1) SMF2d-4-hinge
# set models(1) SMF2d-4-fiber
set models(1) MC-4
# set models(1) CBF2D-4
set checkResultAvailable 0
foreach iModel "1" {
	set inputs(modelFolder) $models($iModel)
	cd $inputs(modelFolder)
	set inputs(modelFolder) ""
	set inputs(resFolder) push-$inputs(pushDir)
	source $inputs(generalFolder)/runSinglePush.tcl
	# wipe
	# source postProcGeneral/summarizeStoryRes.tcl
	cd ..
}

