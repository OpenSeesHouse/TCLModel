set inputs(doEigen) 1
set inputs(analType) eigen
set inputs(doRayleigh) 0
set inputs(generalFolder) ../../general
#read models list 
set i 0
# set models([incr i])    "Examples/NIST-sym-4"
# set models([incr i])    "Examples/NIST-sym-4-MEF-10%"
# set models([incr i])    "Examples/NIST-sym-4-MEF-20%"
# set models([incr i])    "Examples/NIST-sym-8"
set models([incr i])    "Examples/NIST-sym-8-MEF-10%"
set models([incr i])    "Examples/NIST-sym-8-MEF-20%"
# set models([incr i])    "Examples/NIST-sym-16"
set models([incr i])    "Examples/NIST-sym-16-MEF-10%"
set models([incr i])    "Examples/NIST-sym-16-MEF-20%"
set numModels $i
for {set iModel 1} {$iModel <= $numModels} {incr iModel} {
	set inputs(modelFolder) $models($iModel)
	cd $inputs(modelFolder)
	set inputs(modelFolder) ""
	source $inputs(generalFolder)/initiate.tcl
	source $inputs(generalFolder)/buildModel.tcl
	wipe
	cd $inputs(generalFolder)/../
}

