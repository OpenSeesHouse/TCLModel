puts "~~~~~~~~~~~~~~~~~~~~~ performing response history analysis ~~~~~~~~~~~~~~~~~~~~~"
logCommands -comment "~~~~~~~~~~~~~~~~~~~~~ performing response history analysis ~~~~~~~~~~~~~~~~~~~~~\n"
pattern UniformExcitation $seriesTagX 1 -accel $seriesTagX
if {$inputs(numDims) == 3} {
    pattern UniformExcitation $seriesTagY 2 -accel $seriesTagY
}
source $inputs(generalFolder)/getMaxResp.tcl
source $inputs(generalFolder)/doTimeControlAnalysis.tcl
remove loadPattern $seriesTagX
if {$inputs(numDims) == 3} {
    remove loadPattern $seriesTagY
}
