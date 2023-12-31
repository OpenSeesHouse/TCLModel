#comment these to run externally:
#start:
# set modelPath Examples/SMF2d-iso-3
# set sa 3.8
# set iRec 2
# set resFilePath tmp.txt
# set inputs(resFolder) NTH/$iRec/$sa
# set gmPath ../../GMFiles/FarField/AT2
#end
set inputs(doEigen) 1
set inputs(recordCADSees) 0
set inputs(analType) dynamic
set inputs(doRayleigh) 1
set inputs(generalFolder) ../../general
set inputs(doFreeVibrate) 1
set inputs(freeVibTol) 1.e-5
set inputs(colpsDrift) 0.1
set inputs(checkMaxResp) 1
set inputs(checkResultAvailable) 0
cd $modelPath
# source $inputs(generalFolder)/runMirroredTH.tcl
source $inputs(generalFolder)/runSingleTH.tcl
cd $inputs(generalFolder)/../
#to communicate with external caller:
if [info exists resFilePath] {
	set file [open $resFilePath w]
	# puts $file "$maxDrift $failureFlag $maxDriftDir"
	puts $file "$maxDrift $failureFlag"
	close $file
}
