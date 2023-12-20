#comment these to run externally:
#start:
# set modelPath Examples/NIST-sym-4
# set sa 2.
# set iRec 1
# set resFilePath tmp
# set inputs(resFolder) NTH/$iRec/$sa
#end
set inputs(doEigen) 0
set inputs(recordCADSees) 0
set inputs(analType) dynamic
set inputs(doRayleigh) 1
set inputs(generalFolder) ../../general
set inputs(doFreeVibrate) 1
set inputs(freeVibTol) 1.e-5
set inputs(colpsDrift) 0.1
set inputs(checkMaxResp) 1
set inputs(checkResultAvailable) 1
cd $modelPath
source $inputs(generalFolder)/runMirroredTH.tcl
# source $inputs(generalFolder)/runSingleTH.tcl
# wipe
# source postProcGeneral/summarizeStoryRes.tcl
cd $inputs(generalFolder)/../
#to communicate with external caller:
if [info exists resFilePath] {
	set file [open $resFilePath w]
	puts $file "$maxDrift $failureFlag $maxDriftDir"
	close $file
}
