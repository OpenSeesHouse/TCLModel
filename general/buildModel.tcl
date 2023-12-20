
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
manageFEData -initiate

if {$inputs(matType) == "Concrete"} {
	source $inputs(generalFolder)/beamColumnSectionsRC.tcl
} else {
	source $inputs(generalFolder)/beamColumnSectionsSteel.tcl
}
# if {$inputs(numDims) == 3} {
# 	set zAxis(wallTransfX)	"0 1 0"
# 	set zAxis(wallTransfY)	"-1 0 0"
# }
source $inputs(generalFolder)/computeJntData.tcl
source $inputs(generalFolder)/defineNodes.tcl
source $inputs(generalFolder)/defineBaseSupports.tcl
source $inputs(generalFolder)/defineBeams.tcl
source $inputs(generalFolder)/defineColumns.tcl
source $inputs(generalFolder)/defineBraces.tcl
if {$inputs(defLeanClmn) == 1} {
	source $inputs(generalFolder)/defineLeaningColumns.tcl
}
source $inputs(generalFolder)/defineDiaphragms.tcl
source $inputs(generalFolder)/defineMasses.tcl
source $inputs(generalFolder)/cleanupNodes.tcl
if {$inputs(doEigen) == 1} {
	source $inputs(generalFolder)/doEigenAnalysis.tcl
	set file [open periods.txt w]
	for {set i 1} {$i <= $inputs(numModes)} {incr i} {
		puts $file [set T$i]
	}
	close $file
} else {
	set omega2List ""
	set inputs(numModes) 0
	if [catch {open periods.txt r} file] {
		if {$inputs(analType) == "dynamic"} {
			puts "WARNING! periods and the omega2List could not be set"
		}
	} else {
		set i 0
		foreach T [split [read $file] " \n"] {
			if {$T == ""} continue
			incr i
			set T$i $T
			puts "T$i= $T"
			lappend omega2List [expr (2.*3.1415/$T)**2]
		}
			set inputs(numModes) $i
		close $file
	}
}
if {[info exists omega2List] && $inputs(doRayleigh)} {
	source $inputs(generalFolder)/defineRayleighDamping.tcl
}
if {[info exists numTMDs] && $numTMDs > 0} {
	source $inputs(generalFolder)/addTMD.tcl
}

