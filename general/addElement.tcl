proc addElement {eleType elePos node1pos node2pos eleArgs {switchList ""}} {
    set eleTag [manageFEData -newElement $elePos $switchList]
    set nd1Tag [manageFEData -getNode $node1pos]
    set nd2Tag [manageFEData -getNode $node2pos]
	logCommands -comment "#$elePos:  $node1pos  ->  $node2pos\n"
    eval "element $eleType $eleTag $nd1Tag $nd2Tag $eleArgs"
    return $eleTag
}