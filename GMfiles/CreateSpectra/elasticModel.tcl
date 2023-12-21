
model basic -ndm 1 -ndf 1

node 1 0.
node 2 0. -mass $mass

fix 1 1
fix 2 0

uniaxialMaterial Elastic 1 $k
element zeroLength 1 1 2 -mat 1 -dir 1

# set Cc [expr 2.*$mass*$omega]
# set C [expr $zetaDamp*$Cc]
# set alphaM [expr $C/$mass]
# rayleigh $alphaM 0. 0 0.
rayleigh [expr 2*$omega*$zetaDamp] 0. 0 0.

set seriesTag 1
timeSeries Path $seriesTag -dt $dtGM -filePath $GMFile -factor $SF
pattern UniformExcitation 3 1 -accel $seriesTag

# recorder Element -file $dataDir/[set iRec]_[set targMu]_[set T]_2.txt -time -ele 1 material 1 stressStrain
set recTag1 [recorder EnvelopeNode -time -node 2 -dof 1 disp]
set recTag2 [recorder EnvelopeNode -time -timeSeries $seriesTag -node 2 -dof 1 accel]
# set recTag [recorder EnvelopeNode -file $dataDir/envelopeDisp.txt -time -node 2 -dof 1 disp]
# recorder EnvelopeNode -file $dataDir/envelopeAccel.txt -time -timeSeries $seriesTag -node 2 -dof 1 accel 
# recorder Node -file $dataDir/accel.txt -time -node 2 -dof 1 accel 
# recorder ResidNode -file $dataDir/dampEnergy.txt -node 2 dampingEnergy
# set recTag [recorder Node -file $dataDir/energyHist.txt -node 2 dampingEnergy ]
# recorder Element -file $dataDir/ss.txt -time -ele 1 material 1 stressStrain



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
# set energy [recorderValue $recTag 2]
# puts "energy = $energy"
set dMax [recorderValue $recTag1 2]
set sMax [recorderValue $recTag2 2]
wipe
