#inputs: iRec, SF, inputs(resFolder), specFilePath, resFilePath
#outputs: disp, failureFlag

#set resFilePath test.txt
set inputs(generalFolder) general
# source $inputs(generalFolder)/readDataFile.tcl
setMaxOpenFiles 2048
set inputs(doEigen) 0
set file [open $inputs(modelFolder)/periods.txt r]
set i 1
foreach T [split [read $file] \n] {
	if {$T == ""} continue
	set T$i $T
	puts "T$i= [set T$i]"
	incr i
}
close $file
set inputs(generalFolder) general
logCommands -file $inputs(modelFolder)/cmndsLog.tcl
source $inputs(generalFolder)/initiate.tcl
source $inputs(generalFolder)/lsum.tcl
source $inputs(generalFolder)/computeDrift3d.tcl
# source $inputs(generalFolder)/spectrum.tcl
source $inputs(generalFolder)/gmData.tcl
set resAvailable 0
# source $inputs(generalFolder)/checkResultAvailable.tcl

if {$resAvailable == 0} {
	file mkdir $inputs(resFolder)
	set numX [expr 2*$iRec-1]
	set numY [expr 2*$iRec]
	set inputFileX "$inputs(generalFolder)/GMFiles/$numX.AT2"
	set inputFileY "$inputs(generalFolder)/GMFiles/$numY.AT2"
	set filePathX "$inputs(generalFolder)/GMFiles/transformed/$numX.rec"
	set filePathY "$inputs(generalFolder)/GMFiles/transformed/$numY.rec"
	set outList [gmData $inputFileX "" 0]
	set dt [lindex $outList 0]
	set tAll [lindex $outList 1]
	# set TstrtX [lindex $outList 2]
	# set TendX [lindex $outList 3]
	# set outList [gmData $inputFileY]
	# set TstrtY [lindex $outList 2]
	# set TendY [lindex $outList 3]
	# set Tend [expr max($TendX,$TendY)]
	# set Tmin [expr min($TstrtX,$TstrtY)]
	set Tmin 0
	set Tend $tAll
	set Tmax [expr $Tend-$Tmin]
	set TmaxCheck $Tmax
	puts "Running record: $iRec"
	source $inputs(generalFolder)/buildModel.tcl
	source $inputs(generalFolder)/analyze.gravity.tcl
	set fac [expr $g*$SF]

	set seriesTagX 4
	set seriesTagY 5
	if {$Tmin > 0 || $Tend < $tAll} {
		set minInd [expr int($Tmin/$dt)]
		set maxInd [expr int($Tend/$dt)]
		set tList ""
		set t [expr [getTime] + $dt]
		for {set i $minInd} {$i <= $maxInd} {incr i} {
			lappend tList $t
			set t [expr $t+$dt]
		}
		set vListX [readDataFile $filePathX $minInd $maxInd]
		set vListY [readDataFile $filePathY $minInd $maxInd]
		timeSeries Path $seriesTagX -time $tList -values $vListX -factor $fac 
		timeSeries Path $seriesTagY -time $tList -values $vListY -factor $fac 
	} else {
	puts "Tmax= $Tmax"
		timeSeries Path $seriesTagX -dt $dt -filePath $filePathX -factor $fac  -startTime [getTime]
		timeSeries Path $seriesTagY -dt $dt -filePath $filePathY -factor $fac  -startTime [getTime]
	}
	source $inputs(generalFolder)/defineRecorders.tcl
	puts "recorders defined !"
	source $inputs(generalFolder)/analyze.gm.uniform.tcl
	# set freePeriod [expr 4*$Tperiod]
	# set maxFreeTime [expr 3*$Tmax]
	# set resTol 1.e-4
	#source $inputs(generalFolder)/analyze.gm.free.tcl
}
wipe

# set maxDrift 0.
# for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
# 	set input [open $inputs(resFolder)/envelopeDrifts/CMX$j.out r]
# 	set file [read $input]
# 	close $input 
# 	set lineList [split $file \n]
# 	set line [lindex $lineList 2]
# 	set CMDr_x [lindex $line 1]

# 	set input [open $inputs(resFolder)/envelopeDrifts/CMY$j.out r]
# 	set file [read $input]
# 	close $input 
# 	set lineList [split $file \n]
# 	set line [lindex $lineList 2]
# 	set CMDr_y [lindex $line 1]

# 	set input [open $inputs(resFolder)/envelopeDrifts/CMR$j.out r]
# 	set file [read $input]
# 	close $input 
# 	set lineList [split $file \n]
# 	set line [lindex $lineList 2]
# 	set CMDr_thet [lindex $line 1]
# 	set drift3d [computeDrift3d $CMDr_x $CMDr_y $CMDr_thet $cornerCrdList $inputs(centerMassX) $inputs(centerMassY)]
	
# 	# set drift3d [expr ($CMDr_x**2.+$CMDr_y**2.)**0.5]
# 	if {$drift3d > $maxDrift} {
# 		set maxDrift $drift3d
# 	}
# }
# set disp $maxDrift

#to communicate with MATLAB:
#set file [open $resFilePath w]
#puts $file "$disp $failureFlag"
#close $file
