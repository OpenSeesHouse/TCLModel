if {$Units == "mm"} {
	#conver section props from mm to m
	set t3		[expr $t3     *1.e-3]
	set t2		[expr $t2     *1.e-3]
	set tf		[expr $tf     *1.e-3]
	set tw		[expr $tw     *1.e-3]
	set t2b		[expr $t2b    *1.e-3]
	set tfb		[expr $tfb    *1.e-3]
	set Area	[expr $Area   *1.e-6]
	set AS2 	[expr $AS2    *1.e-6]
	set AS3 	[expr $AS3    *1.e-6]
	set J		[expr $J      *1.e-12]
	set I22		[expr $I22    *1.e-12]
	set I33		[expr $I33    *1.e-12]
	set S22		[expr $S22    *1.e-9]
	set S33		[expr $S33    *1.e-9]
	set Z22		[expr $Z22    *1.e-9]
	set Z33		[expr $Z33    *1.e-9]
	set R22		[expr $R22    *1.e-3]
	set R33		[expr $R33    *1.e-3]
	set Radius	[expr $Radius *1.e-3]
	
	set Units m
} elseif {$Units == "cm"} {
	#conver section props from cm to m
	set t3		[expr $t3     *1.e-2]
	set t2		[expr $t2     *1.e-2]
	set tf		[expr $tf     *1.e-2]
	set tw		[expr $tw     *1.e-2]
	set t2b		[expr $t2b    *1.e-2]
	set tfb		[expr $tfb    *1.e-2]
	set Area	[expr $Area   *1.e-4]
	set AS2 	[expr $AS2    *1.e-4]
	set AS3 	[expr $AS3    *1.e-4]
	set J		[expr $J      *1.e-8]
	set I22		[expr $I22    *1.e-8]
	set I33		[expr $I33    *1.e-8]
	set S22		[expr $S22    *1.e-6]
	set S33		[expr $S33    *1.e-6]
	set Z22		[expr $Z22    *1.e-6]
	set Z33		[expr $Z33    *1.e-6]
	set R22		[expr $R22    *1.e-2]
	set R33		[expr $R33    *1.e-2]
	set Radius	[expr $Radius *1.e-2]

	set Units m
}