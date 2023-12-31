#inputs: iRec, sa, inputs(resFolder), resFilePath
#outputs: disp, failureFlag

source $inputs(generalFolder)/readDataFile.tcl
setMaxOpenFiles 2048
source $inputs(generalFolder)/initiate.tcl
source $inputs(generalFolder)/interpSpectrum.tcl
source $inputs(generalFolder)/gmData.tcl
if {$inputs(numDims) == 3 && $inputs(nBaysY) > 0} {
	set numX [expr 2*$iRec-1]
	set numY [expr 2*$iRec]
	set inputFileX "$gmPath/$numX.AT2"
	set inputFileY "$gmPath/$numY.AT2"
	set filePathX "$gmPath/transformed/$numX.txt"
	set filePathY "$gmPath/transformed/$numY.txt"
	set outList [gmData $inputFileX "" 0]
} else {
	set inputFileX "$gmPath/$iRec.AT2"
	set filePathX "$gmPath/transformed/$iRec.txt"
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
	if {$inputs(numDims) == 3 && $inputs(nBaysY) > 0} {
		set saUnscldX [interpSpectrum "$gmPath/spectra/$numX.txt" $T1]
		set saUnscldY [interpSpectrum "$gmPath/spectra/$numY.txt" $T1]
		set saUnscld [expr ($saUnscldX**2. + $saUnscldY**2.)**0.5]
		puts "$saUnscldX $saUnscldY $saUnscld"
		set fac [expr $g*$sa/$saUnscld]
		set seriesTagX 4
		set seriesTagY 5
		timeSeries Path $seriesTagX -dt $dt -filePath $filePathX -factor $fac  -startTime [getTime]
		timeSeries Path $seriesTagY -dt $dt -filePath $filePathY -factor $fac  -startTime [getTime]
	} else {
		set saUnscld [interpSpectrum "$gmPath/spectra/$iRec.txt" $T1]
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
	if {$inputs(numDims) == 3 && $inputs(nBaysY) > 0} {
		set input [open $inputs(resFolder)/envelopeDrifts/CNX$j-max.out r]
		set file [read $input]
		close $input
		set lineList [split $file \n]
		set line [lindex $lineList 2]
		set CNDr_x [lrange $line end end]
		set input [open $inputs(resFolder)/envelopeDrifts/CNY$j-max.out r]
		set file [read $input]
		close $input
		set lineList [split $file \n]
		set line [lindex $lineList 2]
		set CNDr_y [lrange $line end end]

		# set drift [expr max($CNDr_x, $CNDr_y)]
		set drift [expr ($CNDr_x**2.+$CNDr_y**2.)**0.5]
	} else {
		set input [open $inputs(resFolder)/envelopeDrifts/CMX$j.out r]
		set file [read $input]
		close $input
		set lineList [split $file \n]
		set line [lindex $lineList 2]
		set drift [lrange $line end end]
	}
	if {$drift > $maxDrift} {
		set maxDrift $drift
	}
}
set disp $maxDrift