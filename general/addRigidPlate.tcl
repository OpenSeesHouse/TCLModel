proc addRigidPlate {masterNode slaveNodeList} {
	set mnTag [manageFEData -getNode $masterNode]
	foreach sn $slaveNodeList {
        set snTag [manageFEData -getNode $sn]
        rigidLink beam $mnTag $snTag
	}
}