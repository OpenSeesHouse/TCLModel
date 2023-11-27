proc readList {listName path} {
	upvar $listName list
	set file [open $path/$listName.txt r]
	gets $file list
	close $file
}