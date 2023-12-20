#inputs: iRec, sa, inputs(resFolder), resFilePath
#outputs: disp, failureFlag

source $inputs(generalFolder)/readDataFile.tcl
setMaxOpenFiles 2048
source $inputs(generalFolder)/initiate.tcl
source $inputs(generalFolder)/spectrum.tcl
source $inputs(generalFolder)/gmData.tcl
if {$inputs(numDims) == 3} {
	set numX [expr 2*$iRec-1]
	set numY [expr 2*$iRec]
	set inputFileX "$inputs(generalFolder)/GMFiles/$numX.AT2"
	set inputFileY "$inputs(generalFolder)/GMFiles/$numY.AT2"
	set filePathX "$inputs(generalFolder)/GMFiles/transformed/$numX.rec"
	set filePathY "$inputs(generalFolder)/GMFiles/transformed/$numY.rec"
	set outList [gmData $inputFileX "" 0]
} else {
	set inputFileX "$inputs(generalFolder)/GMFiles/$iRec.AT2"
	set filePathX "$inputs(generalFolder)/GMFiles/transformed/$iRec.rec"
	set outList [gmData $inputFileX "" 0]
}
set dt [lindex $outList 0]
set Tmax [lindex $outList 1]
set inputs(maxFreeVibrTime) [expr 3*$Tmax]
set TmaxCheck $Tmax
puts "~~~~~~~~~~~~~~~~ Running record: $iRec, Duration= $Tmax ~~~~~~~~~~~~~~~~"
set resAvailable 0
if {$inputs(checkResultAvailable)} {
	source $inputs(generalFolder)/checkResultAvailable.tcl
}
if {$resAvailable == 0} {
	logCommands -file $inputs(resFolder)/CmndsLog.ops
	file mkdir $inputs(resFolder)
	source $inputs(generalFolder)/buildModel.tcl
	source $inputs(generalFolder)/analyze.gravity.tcl
	if {$inputs(numDims) == 3} {
		set saUnscldX [spectrum "$inputs(generalFolder)/GMFiles/spectra/$numX.txt" $T1]
		set saUnscldY [spectrum "$inputs(generalFolder)/GMFiles/spectra/$numY.txt" $T1]
		set saUnscld [expr ($saUnscldX**2. + $saUnscldY**2.)**0.5]
		puts "$saUnscldX $saUnscldY $saUnscld"
		set fac [expr $g*$sa/$saUnscld]
		set seriesTagX 4
		set seriesTagY 5
		timeSeries Path $seriesTagX -dt $dt -filePath $filePathX -factor $fac  -startTime [getTime]
		timeSeries Path $seriesTagY -dt $dt -filePath $filePathY -factor $fac  -startTime [getTime]
	} else {
		set saUnscld [spectrum "$inputs(generalFolder)/GMFiles/spectra/$iRec.txt" $T1]
		set fac [expr $g*$sa/$saUnscld]
		set seriesTagX 4
		set seriesTagY 0
		timeSeries Path $seriesTagX -dt $dt -filePath $filePathX -factor $fac  -startTime [getTime]
	}
	set deltaT 0.02
	source $inputs(generalFolder)/defineRecorders.tcl
	source $inputs(generalFolder)/analyze.gm.uniform.tcl
	if {$inputs(doFreeVibrate)} {
		set freeVibrPeriod [expr 4*$T1]
		set resTol 1.e-4
		source $inputs(generalFolder)/analyze.gm.free.tcl
	}
}
wipe

set maxDrift 0.
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set input [open $inputs(resFolder)/envelopeDrifts/CNX$j.out r]
	set file [read $input]
	close $input
	set lineList [split $file \n]
	set line [lindex $lineList 2]
	set CNDr_x [lrange $line end end]

	set input [open $inputs(resFolder)/envelopeDrifts/CNY$j.out r]
	set file [read $input]
	close $input
	set lineList [split $file \n]
	set line [lindex $lineList 2]
	set CNDr_y [lrange $line end end]

	# set drift3d [expr max($CNDr_x, $CNDr_y)]
	set drift3d [expr ($CNDr_x**2.+$CNDr_y**2.)**0.5]
	if {$drift3d > $maxDrift} {
		set maxDrift $drift3d
	}
}
set disp $maxDrift