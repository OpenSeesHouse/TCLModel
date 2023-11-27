proc interpolateMy {t axi file} {
	set axi [expr $axi*1e-4]
	set fid [open $file r]
	set lines [split [read $fid] \n]
	close $fid
	set col1 [expr int($t/15.)+1]
	set col2 [expr $col1+1]
	set t1 [expr ($col1-1)*15.]
	set t2 [expr $t1+15.]
	set p1 [lindex [lindex $lines 1] [expr ($col1-1)*3+0]]
	set p2 [lindex [lindex $lines 1] [expr ($col2-1)*3+0]]
	set row1 0
	set row2 0
	set row 1
	set line_1 ""
	while {$row1 == 0 || $row2 == 0} {
		set line [lindex $lines $row]
		if {$row1 == 0} {
			set P [lindex $line [expr ($col1-1)*3+0]]
			if {$P <= $axi} {
				set row1 $row
				set My11 [lindex $line_1 [expr ($col1-1)*3+1]]
				set Mz11 [lindex $line_1 [expr ($col1-1)*3+2]]
				set My21 [lindex $line [expr ($col1-1)*3+1]]
				set Mz21 [lindex $line [expr ($col1-1)*3+2]]
				set p11	[lindex $line_1 [expr ($col1-1)*3+0]]
				set p21 $P
			}
		}
		if {$row2 == 0} {
			set P [lindex $line [expr ($col2-1)*3+0]]
			if {$P <= $axi} {
				set row2 $row
				set My12 [lindex $line_1 [expr ($col2-1)*3+1]]
				set Mz12 [lindex $line_1 [expr ($col2-1)*3+2]]
				set My22 [lindex $line [expr ($col2-1)*3+1]]
				set Mz22 [lindex $line [expr ($col2-1)*3+2]]
				set p12	[lindex $line_1 [expr ($col2-1)*3+0]]
				set p22 $P
			}
		}
		set line_1 $line
		incr row
	}
	#interpolate with respct to axi
	#for t1
	set My1 [expr $My11 + ($My21-$My11)/($p21-$p11)*($axi-$p11)]
	set Mz1 [expr $Mz11 + ($Mz21-$Mz11)/($p21-$p11)*($axi-$p11)]
	#for t2
	set My2 [expr $My12 + ($My22-$My12)/($p22-$p12)*($axi-$p12)]
	set Mz2 [expr $Mz12 + ($Mz22-$Mz12)/($p22-$p12)*($axi-$p12)]
	#interpolate with respct to theta
	set My [expr $My1 + ($My2-$My1)/($t2-$t1)*($t-$t1)]
	set Mz [expr $Mz1 + ($Mz2-$Mz1)/($t2-$t1)*($t-$t1)]
	return "[expr $My*1e4] [expr $Mz*1e4]"
}