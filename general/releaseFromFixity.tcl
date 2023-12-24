proc releaseFromFixity {fxtyChar} {
	set release 0
	if {$fxtyChar != "11"} {
		if {$fxtyChar == "01"} {
			set release 1
		} elseif {$fxtyChar == "10"} {
			set release 2
		} elseif {$fxtyChar == "00"} {
			set release 3
		} else {
			error ("Unacceptable fixity code: $fxtyChar")
		}
	}
	return $release
}
