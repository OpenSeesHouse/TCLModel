#input: inputs(modelFolder), inputs(resFolder), inputs(pushDir)
set inputs(checkResultAvailable) 0
if {$inputs(checkResultAvailable)} {
	set file [open $inputs(resFolder)/globalDriftX.out r]
	set lines [split [read $file] \n]
	close $file
	set nL [llength $lines]
	set lL [lindex $lines [expr $nL-2]]
	set iv 0
	set maxd 0
	foreach v $lL {
		incr iv
		if {$iv == 1} continue
		set maxd [expr max($v,$maxd)]
	}
	if {$maxd > [expr 0.8*$inputs(targetDriftList)]} {
		puts "------------ maxd= $maxd, push result available! -----------"
		return
	}
}
setMaxOpenFiles 2048
puts "running: $inputs(resFolder)"
file mkdir $inputs(resFolder)
if {$inputs(recordCADSees)} {
	logCommands -file commands.ops
} else {
	logCommands -file $inputs(resFolder)/commands.ops
}
source $inputs(generalFolder)/initiate.tcl
if {$isAdaptive} {
	set inputs(numModes) $inputs(nFlrs)
}
source $inputs(generalFolder)/buildModel.tcl
source $inputs(generalFolder)/analyze.gravity.tcl
source $inputs(generalFolder)/defineRecorders.tcl
if {$isAdaptive} {
	source $inputs(generalFolder)/analyze.push.adaptive.tcl
} else {
	source $inputs(generalFolder)/analyze.push.tcl
}