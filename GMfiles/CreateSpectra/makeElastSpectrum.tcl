# set TList " 0.100 0.200 0.300 0.400 0.500 0.600 0.700 0.800 0.900 1.000 1.100 1.200 1.300 1.400 1.500 1.600 1.700 1.800 1.900 2.000 2.100 2.200 2.300 2.400 2.500 2.600 2.700 2.800 2.900 3.000 3.100 3.200 3.300 3.400 3.500 3.600 3.700 3.800 3.900 4.000"
# set TList "0.1 0.5 1 2"
# set GMFile 3-chevron/GMFiles/1/1.txt
# set zetaDamp 0.020000
# set dataFile tempFiles/spec_1.txt
# set iRec 1
# set dataDir tempFiles/tmp
# set dtGM 0.01
source ../../general/gmData.tcl
set GMFile "$gmPath/transformed/$iRec.txt"
set inFile "$gmPath/$iRec.AT2"
set list [gmData $inFile]
set dtGM [lindex $list 0]
set Tmax [lindex $list 1]
puts "GMFile= $GMFile"
puts "dtGM= $dtGM"
puts "Tmax= $Tmax"
set pi [expr 4.*atan(1)]
set mass 1.
foreach T $TList {
	puts "T= $T"
	set omega [expr 2.*$pi/$T]
	set k [expr $mass*$omega**2]
	source elasticModel.tcl
	# puts "sMax= $sMax"
	set spec($T) [expr [set $specVar]]
}
set file [open $dataFile w]
foreach T $TList {
	puts $file "$T $spec($T)"
}
close $file