proc saveList {listName path} {
	upvar $listName list
	set file [open $path/$listName.txt w]
	puts $file $list
	close $file
}