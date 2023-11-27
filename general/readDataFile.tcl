proc readDataFile {filePath minInd maxInd} {
    # inputs:
    # filePath          path to a line/space delimited text file
    # minInd            1-based index of the first value in the file
    # maxInd            1-based index of the last value in the file
    set file [open $filePath r]
    set lines [split [read $file] \n]
    close $file
    set i 0
    set res ""
    foreach line $lines {
        if {$line == ""} continue
        foreach word $line {
            if {$word == ""} continue
            incr i
            if {$i < $minInd} continue
            if {$i > $maxInd} break
            lappend res $word
        }
    }
    return $res
}