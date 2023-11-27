	set Dext $t3
	set Dint [expr $t3-2.*$tf]
	set I33 [expr ($Dext**4 - $Dint**4)/12.]
	set rJir [expr ($I33/$Area)**0.5]
	set wtrat [expr ($t3-2.*$tf)/$tf]
	set lBrace [expr ($h**2. + $lSpan**2.)**0.5-2.*$lRigid]
	set lambda [expr $lBrace/$rJir]
	set e0 [expr 0.291*pow($lambda,-0.484)*pow($wtrat,-0.613)*pow($EFrat,0.303)]
