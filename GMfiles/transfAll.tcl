source gmData.tcl
set path FarField/AT2
file mkdir $path/transformed
set n 44
for {set i 1} {$i <= $n} {incr i} {
	set inF $path/$i.AT2
	set out $path/transformed/$i.txt
	gmData $inF $out 0
}