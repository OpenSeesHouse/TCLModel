proc addDiaphragm {perpDirn masterNode slaveNodeList} {
	eval "rigidDiaphragm $perpDirn $masterNode $slaveNodeList"
	return
	# global inputs
	# set E		$inputs(E)		
	# set G		$inputs(G)		
	# set typA	$inputs(typA)	
	# set typIz	$inputs(typIz)	
	# set typIy	$inputs(typIy)
	# set typJ	$inputs(typJ)	
	# set elasticMatTag $inputs(elasticMatTag)
	# set numSlave [llength $slaveNodeList]
	# if {$perpDirn == 3} {
	# 	set yVec "0 0 1"
	# } else {
	# 	# $perpDirn == 2
	# 	set yVec "0 1 0"
	# }
	# set mastCrds [nodeCoord $masterNode]
	# set i 1
	# set avrgL 0.
	# foreach slave $slaveNodeList {
	# 	set slavCrds [nodeCoord $slave]
	# 	set xVec ""
	# 	foreach mCrd $mastCrds sCrd $slavCrds {
	# 		lappend xVec [expr $sCrd-$mCrd]
	# 	}
	# 	set xNorm [lNorm $xVec]
	# 	set avrgL [expr $avrgL + $xNorm]
	# }
	# set avrgL [expr $avrgL/$numSlave]
	# puts "avrgL= $avrgL"
	# foreach slave $slaveNodeList {
	# 	set slavCrds [nodeCoord $slave]
	# 	set xVec ""
	# 	foreach mCrd $mastCrds sCrd $slavCrds {
	# 		lappend xVec [expr $sCrd-$mCrd]
	# 	}
	# 	set xNorm [lNorm $xVec]
	# 	set list $xVec
	# 	set xVec ""
	# 	foreach crd $list {
	# 		lappend xVec [expr $crd/$xNorm]
	# 	}
	# 	set zVec [crossProduct $xVec $yVec]
	# 	set eleTag [expr $masterNode*100+$i]
	# 	eval "geomTransf Linear $eleTag $zVec"
	# 	set k1 [expr $avrgL/$xNorm]
	# 	element elasticBeamColumn $eleTag $slave $masterNode [expr 1000*$k1*$typA] [expr 1.*$E] [expr 1.*$G] [expr 0.001*$typJ] [expr 1000.*$k1*$typIy] [expr 0.001*$typIz] $eleTag
		
	# 	incr i
	# }
}