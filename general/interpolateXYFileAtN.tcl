#xList: in ascending order

proc interpolateXYFileAtN {inFile xClmn N a} {
	set file [open $inFile r]
	set lines [split [read $file] \n]
	close $file
	set line [lindex $lines 0]
	set numCols [llength $line]
	incr xClmn -1
    set yClmns ""
    for {set i 0} {$i < $numCols} {incr i} {
        if {$i == $xClmn} continue
        lappend yClmns $i
    }
    set i 0
    if {$N >= 1} {
        set lin1 [lindex $lines [expr $N-1]]
        if {[llength $lin1] < $numCols} {
            puts "WARNING! not enough data columns in file: $inFile"
            return ""
        }
    } else {
        set lin1 ""
        for {set i 0} {$i < $numCols} {incr i} {
            lappend lin1 0
        }
    }
    set lin2 [lindex $lines $N]
    if {[llength $lin2] < $numCols} {
        puts "WARNING! not enough data columns in file: $inFile"
        return ""
    }
	set yRes ""
	foreach yClmn $yClmns {
		set y1 [lindex $lin1 $yClmn]
		set y2 [lindex $lin2 $yClmn]
    	set y [expr $y1*(1-$a)+$y2*$a]
		lappend yRes $y
	}
	return	$yRes
}