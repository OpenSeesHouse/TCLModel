
#History of global drifts:
file mkdir $inputs(resFolder)
set outfile [open $inputs(resFolder)/globalDrift3d.out w]

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

set tmax 0
set maxDrift 0
foreach lineX $lineListX lineY $lineListY lineR $lineListR {
	if {$lineX == "" || $lineY == "" || $lineR == ""} continue
	set t [lindex $lineX 0]
	set CMDr_x [lindex $lineX 1]
	set CMDr_y [lindex $lineY 1]
	set CMDr_thet [lindex $lineR 1]	
	set drift3d [computeDrift3d $CMDr_x $CMDr_y $CMDr_thet [lsum $inputs(lBayX)] [lsum $inputs(lBayY)] $inputs(centerMassX) $inputs(centerMassY)]
	puts $outfile "$t $drift3d"
	if {$drift3d > $maxDrift} {
		set tmax $t
		set maxDrift $drift3d
	}
}
close $outfile
set outfile [open $inputs(resFolder)/maxGlobalDrift3d.out w]
puts $outfile "$tmax $maxDrift"
close $outfile

#Envelope story drifts
set maxDrift 0.
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set input [open $inputs(resFolder)/envelopeDrifts/X$j.out r]
	set file [read $input]
	close $input 
	set lineList [split $file \n]
	set line [lindex $lineList 2]
	set CMDr_x [lindex $line 1]

	set input [open $inputs(resFolder)/envelopeDrifts/Y$j.out r]
	set file [read $input]
	close $input 
	set lineList [split $file \n]
	set line [lindex $lineList 2]
	set CMDr_y [lindex $line 1]

	set input [open $inputs(resFolder)/envelopeDrifts/R$j.out r]
	set file [read $input]
	close $input 
	set lineList [split $file \n]
	set line [lindex $lineList 2]
	set CMDr_thet [lindex $line 1]
	
	# puts "computeDrift3d $CMDr_x $CMDr_y $CMDr_thet [lsum $inputs(lBayX)] [lsum $inputs(lBayY)] $inputs(centerMassX) $inputs(centerMassY)"
	set drift3d [computeDrift3d $CMDr_x $CMDr_y $CMDr_thet [lsum $inputs(lBayX)] [lsum $inputs(lBayY)] $inputs(centerMassX) $inputs(centerMassY)]
	set output [open $inputs(resFolder)/envelopeDrifts/3d$j.out w]
	puts $output "$drift3d"
	close $output
	
	if {$drift3d > $maxDrift} {
		set maxDrift $drift3d
	}
}
set output [open $inputs(resFolder)/envelopeDrifts/3dmax.out w]
puts $output "$maxDrift"
close $output

