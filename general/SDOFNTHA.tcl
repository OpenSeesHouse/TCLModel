proc SDOFNTHA {modelType modelParams omega zetaDamp dtGM GMFile SF Tmax {outFile ""} {logFile ""}} {
if {$logFile != ""} {
	logCommands -file $logFile
}
model basic -ndm 1 -ndf 1

node 1 0.
node 2 0. -mass 1.

fix 1 1
fix 2 0

eval "uniaxialMaterial $modelType 1 $modelParams"
element zeroLength 1 1 2 -mat 1 -dir 1

# set Cc [expr 2.*$mass*$omega]
# set C [expr $zetaDamp*$Cc]
# set alphaM [expr $C/$mass]
# rayleigh $alphaM 0. 0 0.
rayleigh [expr 2*$omega*$zetaDamp] 0. 0 0.
set T [expr 2.*3.1415/$omega]
set seriesTag 100
timeSeries Path $seriesTag -dt $dtGM -filePath $GMFile -factor $SF
pattern UniformExcitation 3 1 -accel $seriesTag

set recTag [recorder EnvelopeNode -time -node 2 -dof 1 disp]
if {$outFile != ""} {
	recorder Node -file $outFile -time -node 2 -dof 1 disp
}
set deltaT [expr 0.01*$T]
if {$deltaT > 0.02} {
	set deltaT 0.02
}

constraints Plain
numberer Plain
system BandGeneral
test EnergyIncr 1.0e-7 100
algorithm Newton
integrator Newmark 0.5 0.25
analysis Transient
analyze [expr int($Tmax/$deltaT)] $deltaT
set resp [recorderValue $recTag 2]
wipe
logCommands -stop
return $resp
}