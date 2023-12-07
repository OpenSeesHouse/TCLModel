proc eleCodeMap {args} {
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
    set arg0 [lindex $args 0]
    if {$arg0 == "-getAllTypes"} {
        return [lsort [array names eleTypeCodes]]
    }
    if {$arg0 == "-getAllCodes"} {
        set res ""
        foreach typ [array names eleTypeCodes] {
            lappend res $eleTypeCodes($typ)
        }
        return [lsort -integer $res]
    }
    if {$arg0 == "-getType"} {
        set code [lindex $args 1]
        set res ""
        foreach typ [array names eleTypeCodes] {
            if {$eleTypeCodes($typ) == $code} {
                return $typ
            }
        }
        error ("no type was found for code: $code in the map")
    }
    foreach typ [array names eleTypeCodes] {
        if {$arg0 == $typ} {
            return $eleTypeCodes($typ)
        }
    }
    error "eleType: option: $arg0 is unrecognized"
}