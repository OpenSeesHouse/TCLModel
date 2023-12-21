file mkdir sections
set infile [open sections.txt r]
set lineList [split [read $infile] \n]
set units [lindex $lineList 0]
set varNameList [split [lindex $lineList 1] \t]
set nLines [llength $lineList]
for {set iLine 2} {$iLine <= $nLines} {incr iLine} {
	set line [lindex $lineList $iLine]
	if {$line == ""} {continue}
	set wordList [split $line \t]
	set nWords [llength $wordList]
	set fileName [lindex $wordList 0]
	set outFile [open sections/$fileName.tcl w]
	puts $outFile $units
	for {set iWord 0} {$iWord <= $nWords} {incr iWord} {
		set verName [lindex $varNameList $iWord]
		set varVal [lindex $wordList $iWord]
		if {$varVal == ""} {continue}
		puts $outFile "set $verName $varVal"
	}
	close $outFile
}
close $infile