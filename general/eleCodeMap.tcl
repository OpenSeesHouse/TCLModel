proc eleCodeMap {inputStr} {
    global eleTypeCodes
    if ![info exists eleTypeCodes] {
        set eleTypeCodes(X-Beam) 1
        set eleTypeCodes(Y-Beam) 2
        set eleTypeCodes(Column) 3
        set eleTypeCodes(X-Brace) 4
        set eleTypeCodes(Y-Brace) 5
        set eleTypeCodes(X-Wall) 6
        set eleTypeCodes(Y-Wall) 7
    }
    if {$inputStr == "-getAllTypes"} {
        return [lsort [array names eleTypeCodes]]
    }
    if {$inputStr == "-getAllCodes"} {
        set res ""
        foreach typ [array names eleTypeCodes] {
            lappend res $eleTypeCodes($typ)
        }
        return [lsort -integer $res]
    }
    foreach typ [array names eleTypeCodes] {
        if {$inputStr == $typ} {
            return $eleTypeCodes($typ)
        }
    }
    error "eleType: option: $inputStr is unrecognized"
}