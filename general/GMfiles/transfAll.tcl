source ../gmData.tcl
set n 44
for {set i 1} {$i <= $n} {incr i} {
	set inF $i.AT2
	set out transformed/$i.txt
	gmData $inF $out 0
}