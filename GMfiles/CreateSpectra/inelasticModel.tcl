# source gmData.tcl
# set GMFile "GMFiles/transformed/$iRec.txt"
# set inFile "GMFiles/$iRec.AT2"

# gmData $inFile $GMFile dtGM Tmax

model basic -ndm 1 -ndf 1

node 1 0.
node 2 0.

fix 1 1
fix 2 0

# T = 2*pi/omega
# K = m*omega^2
# set pi [expr 4.*atan(1)]
# set omega [expr 2.*$pi/$T]
# set mass 100.;	# Kg
# set k [expr $mass*$omega**2]

mass 2 $mass
set Fy [expr $k*$epsilonY]
uniaxialMaterial Steel01 1 $Fy $k 0.0001
# uniaxialMaterial Elastic 1 $k
element zeroLength 1 1 2 -mat 1 -dir 1

# set omega0 [expr sqrt([eigen -fullGenLapack 1])]
# puts "omega0 = $omega0"
# puts "omega = $omega"

if [info exists dataDir] {
	file mkdir $dataDir
}


# set zetaDamp 0.05
set Cc [expr 2.*$mass*$omega]
set C [expr $zetaDamp*$Cc]
set alphaM [expr $C/$mass]
rayleigh $alphaM 0. 0 0.

set seriesTag 1
timeSeries Path $seriesTag -dt $dtGM -filePath $GMFile -factor 9.81
pattern UniformExcitation 3 1 -accel $seriesTag

# set recTag [recorder EnvelopeNode -file $dataDir/envelopeAccel.txt -time -timeSeries $seriesTag -node 2 -dof 1 accel]
set recTag1 [recorder EnvelopeNode -time -node 2 -dof 1 disp]
set recTag2 [recorder EnvelopeNode -time -timeSeries $seriesTag -node 2 -dof 1 accel]
# recorder Node -file $dataDir/accel.txt -time -node 2 -dof 1 accel 



set dt [expr 0.01*$T]
if {$dt > $dtGM} {
	set dt $dtGM
}
set deltaT $dt
source analyzeGM.tcl

# constraints Plain
# numberer RCM
# system BandGeneral
# test EnergyIncr 1.0e-6 100
# algorithm KrylovNewton
# integrator Newmark 0.5 0.25
# analysis Transient
# set ok [analyze [expr int($Tmax/$dt)] $dt]
# puts "ok= $ok"
set dMax [recorderValue $recTag1 2]
set sMax [recorderValue $recTag2 2]
wipe