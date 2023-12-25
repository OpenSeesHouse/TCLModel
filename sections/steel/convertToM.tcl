if {$Units == "mm"} {
	#conver section props from mm to m
	set convFac(t3) 	1.e-3
	set convFac(t2) 	1.e-3
	set convFac(tf) 	1.e-3
	set convFac(tw) 	1.e-3
	set convFac(t2b)	1.e-3
	set convFac(tfb)	1.e-3
	set convFac(Area)	1.e-6
	set convFac(AS2) 	1.e-6
	set convFac(AS3) 	1.e-6
	set convFac(J)		1.e-12
	set convFac(I22)	1.e-12
	set convFac(I33)	1.e-12
	set convFac(S22)	1.e-9
	set convFac(S33)	1.e-9
	set convFac(Z22)	1.e-9
	set convFac(Z33)	1.e-9
	set convFac(R22)	1.e-3
	set convFac(R33)	1.e-3
	set convFac(Radius)	1.e-3
	set Units m
} elseif {$Units == "cm"} {
	#conver section props from cm to m
	set convFac(t3) 	1.e-2
	set convFac(t2) 	1.e-2
	set convFac(tf) 	1.e-2
	set convFac(tw) 	1.e-2
	set convFac(t2b)	1.e-2
	set convFac(tfb)	1.e-2
	set convFac(Area)	1.e-4
	set convFac(AS2) 	1.e-4
	set convFac(AS3) 	1.e-4
	set convFac(J)		1.e-8
	set convFac(I22)	1.e-8
	set convFac(I33)	1.e-8
	set convFac(S22)	1.e-6
	set convFac(S33)	1.e-6
	set convFac(Z22)	1.e-6
	set convFac(Z33)	1.e-6
	set convFac(R22)	1.e-2
	set convFac(R33)	1.e-2
	set convFac(Radius)	1.e-2
	set Units m
}
foreach var [array names convFac] {
	if [info exists $var] {
		set fac $convFac($var)
		set $var [expr [set $var]*$fac]
	}
}