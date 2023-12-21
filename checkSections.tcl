set secFolder general/sections/steel
set allFiles [glob -directory $secFolder -type f  pattern *.tcl]
set n [llength $allFiles]
set out [open tmp.txt w]
puts $out "n= $n"
#check to see if Units is set in all section files
foreach f $allFiles {
	if [string match *convert* $f] continue
	source $f
	if ![info exists Units] {
		puts $out $f
		continue
	}
	unset Units
}
close $out