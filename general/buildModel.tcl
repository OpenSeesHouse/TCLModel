
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
source $inputs(generalFolder)/computeJntData.tcl
source $inputs(generalFolder)/defineNodes.tcl
if [info exists isoltrLabel] {
	source $inputs(generalFolder)/defineIsolators.tcl
}
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
	puts "~~~~~~~~~~~~~~~~~~~~~ Performing Eigen Analysis ~~~~~~~~~~~~~~~~~~~~~"
	set omega2List [doEigen]
} else {
	set omega2List ""
	set inputs(numModes) 0
	if [catch {open periods.out r} file] {
		if {$inputs(analType) == "dynamic"} {
			puts "WARNING! periods and the omega2List could not be set"
		}
	} else {
		set i 0
		foreach line [split [read $file] " \n"] {
			foreach "i T" $line {}
			if {$T == ""} continue
			if [info exists T$i] break
			set T$i $T
			puts "T$i= $T"
			lappend omega2List [expr (2.*3.1415/$T)**2]
			set inputs(numModes) $i
		}
		close $file
	}
}
if {[info exists omega2List] && $inputs(doRayleigh)} {
	source $inputs(generalFolder)/defineRayleighDamping.tcl
}
if {[info exists numTMDs] && $numTMDs > 0} {
	source $inputs(generalFolder)/addTMD.tcl
}

