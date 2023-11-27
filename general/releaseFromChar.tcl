proc releaseFromChar {rlsChar} {
	set release 0
	if {$rlsChar != "RR"} {
		if {$rlsChar != "FR"} {
			set release 1
		} elseif {$rlsChar != "RF"} {
			set release 2
		} elseif {$rlsChar != "FF"} {
			set release 3
		} else {
			error ("Unacceptable release code: $rlsChar at ($j,$k,$i)")
		}
	}

}
