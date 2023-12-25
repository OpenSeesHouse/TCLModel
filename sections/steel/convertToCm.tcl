if {$Units == "mm"} {
	#conver section props from mm to cm
	set convFac(t3) 	1.e-1
	set convFac(t2) 	1.e-1
	set convFac(tf) 	1.e-1
	set convFac(tw) 	1.e-1
	set convFac(t2b)	1.e-1
	set convFac(tfb)	1.e-1
	set convFac(Area)	1.e-2
	set convFac(AS2) 	1.e-2
	set convFac(AS3) 	1.e-2
	set convFac(J)		1.e-4
	set convFac(I22)	1.e-4
	set convFac(I33)	1.e-4
	set convFac(S22)	1.e-3
	set convFac(S33)	1.e-3
	set convFac(Z22)	1.e-3
	set convFac(Z33)	1.e-3
	set convFac(R22)	1.e-1
	set convFac(R33)	1.e-1
	set convFac(Radius)	1.e-1
	set Units cm
}
foreach var [array names convFac] {
	if [info exists $var] {
		set fac $convFac($var)
		set $var [expr [set $var]*$fac]
	}
}
