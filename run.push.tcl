set inputs(doEigen) 1
set inputs(recordCADSees) 0
set inputs(targetDriftList) "0.08"
set inputs(pushDir) X
set inputs(kPush) 1.
set inputs(doRayleigh) 0
set inputs(generalFolder) ../general
set inputs(numPushSteps) 100
# set sharedInputsName $inputs(generalFolder)/sharedInputs.tcl
#set inputs(pushDir) Y
#read models list 
# set models(1) MC-4-RSA
set models(1) SMF2D-4-RSA
set numModels 1
set checkResultAvailable 0
foreach iModel "1" {
	set inputs(modelFolder) $models($iModel)
	cd $inputs(modelFolder)
	set inputs(modelFolder) ""
	set inputs(resFolder) push
	source $inputs(generalFolder)/runSinglePush.tcl
	# wipe
	# source postProcGeneral/summarizeStoryRes.tcl
	cd ..
}


