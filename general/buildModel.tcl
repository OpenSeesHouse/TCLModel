
source $inputs(generalFolder)/checkInputs.tcl
source $inputs(generalFolder)/readInputs.tcl
puts "~~~~~~~~~~~~~~~~~~~~~ Defining Materials and Sections ~~~~~~~~~~~~~~~~~~~~~"
# logCommands -comment "#~~~~~~~~~~~~~~~~~~~~~ Defining Materials and Sections ~~~~~~~~~~~~~~~~~~~~~\n"
set typSec ""
set found 0
set code [eleCodeMap Column]
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	for {set i 1} {$i <= [expr $inputs(nBaysX)+1]} {incr i} {
		for {set k 1} {$k <= [expr $inputs(nBaysY)+1]} {incr k} {
			set typSec $eleData(section,$code,$j,$k,$i)
			if {$typSec != "-"} {
				set found 1
				break
			}
		}
		if {$found} break
	}
	if {$found} break
}

if {$inputs(matType) == "Concrete"} {
	source $inputs(generalFolder)/beamColumnSectionsRC.tcl
} else {
	source $inputs(generalFolder)/beamColumnSectionsSteel.tcl
}
# if {$inputs(numDims) == 3} {
# 	set zAxis(wallTransfX)	"0 1 0"
# 	set zAxis(wallTransfY)	"-1 0 0"
# }
manageFEData -initiate
source $inputs(generalFolder)/computeJntData.tcl
source $inputs(generalFolder)/defineNodes.tcl
source $inputs(generalFolder)/defineBaseSupports.tcl
source $inputs(generalFolder)/defineBeams.tcl
source $inputs(generalFolder)/defineColumns.tcl
source $inputs(generalFolder)/defineBraces.tcl
source $inputs(generalFolder)/cleanupNodes.tcl
if {$inputs(defLeanClmn) == 1} {
	source $inputs(generalFolder)/defineLeaningColumns.tcl
}
source $inputs(generalFolder)/defineDiaphragms.tcl
source $inputs(generalFolder)/defineMasses.tcl
if {$inputs(doEigen) == 1} {
	source $inputs(generalFolder)/doEigenAnalysis.tcl
} elseif [info exists T1] {
	set Tperiod $T1
	set omega_1 [expr (2.*3.1415/$T1)]
	set omega2List [expr $omega_1**2]
	if [info exists T2] {
		lappend omega2List [expr (2.*3.1415/$T2)**2]
	}
}
if {[info exists omega2List] && $inputs(doRayleigh)} {
	source $inputs(generalFolder)/defineRayleighDamping.tcl
}
if {[info exists numTMDs] && $numTMDs > 0} {
	source $inputs(generalFolder)/addTMD.tcl
}

