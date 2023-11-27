source $inputs(generalFolder)/lsum.tcl
source $inputs(generalFolder)/computeDrift3d.tcl
set input [open $inputs(resFolder)/globalDriftX.out r]
set file [read $input]
close $input 
set lineListX [split $file \n]

set input [open $inputs(resFolder)/globalDriftY.out r]
set file [read $input]
close $input 
set lineListY [split $file \n]

set input [open $inputs(resFolder)/globalDriftR.out r]
set file [read $input]
close $input 
set lineListR [split $file \n]

set file [open $inputs(resFolder)/globalDrift3d.out w]
set file2 [open $inputs(resFolder)/envelopeDrift3d.out w]
set max 0
set tMax 0
foreach lineX $lineListX lineY $lineListY lineR $lineListR {
	set time   [lindex $lineX 0]
	if {$time == ""} {continue}
	set CMDr_x [lindex $lineX 1]
	set CMDr_y [lindex $lineY 1]
	set CMDr_thet [lindex $lineR 1]
	# puts "$CMDr_x $CMDr_y $CMDr_thet"
	set drift3d [computeDrift3d $CMDr_x $CMDr_y $CMDr_thet $cornerCrdList $inputs(centerMassX) $inputs(centerMassY)]
	if {$drift3d > $max} {
		set max $drift3d
		set tMax $time
	}
	puts $file "$time $drift3d"
}
puts $file2 "$tMax $max"

close $file
close $file2