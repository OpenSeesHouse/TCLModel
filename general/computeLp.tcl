	proc computeLp {l h db Ag fc p} {
		set p0 [expr $Ag*$fc]
		set lp [expr (0.042+0.072*$p/$p0)*$l+0.298*$h+6.407*$db]
	}
