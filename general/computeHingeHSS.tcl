#########################################################################
#     please keep this notification at the beginning of this file       #
#                                                                       #
#                  Developed by Seyed Alireza Jalali                    #
#        as part of the OpenSees course in civil808 institute           #
#  for more information and any questions about this code,              #
#               Join  "OpenSees SAJ" telegram group:                    #
#            (https://t.me/joinchat/CJlXoECQvxiJXal0PkLfwg)             #
#                     or visit: www.civil808.com                        #
#                                                                       #
#      DISTRIBUTION OF THIS CODE WITHOUT WRITTEN PERMISSION FROM        #
#                THE DEVELOPER IS HEREBY RESTRICTED                     #
#########################################################################
#HSS section proprties following Lignos
proc computeHingeHSS {ID d tf bf tw Z I L N Area fy cUnitToKsi MyFac} {
	global inputs
	set e $inputs(Es)
	set doCheck No
	set h [expr $d-2.*$tf]
	set I $Iz
	set Ny [expr $Area*$fy]
	set ke [expr $e*$I*6./$L]
	set my [expr $MyFac*$fy*$Z*(1.0-$N/$Ny)]
	set mc [expr $my*1.11]
	set tetay [expr $my/$ke]
	set tetap [expr 0.572*(($h/$tw)**-1.)*((1.0-$N/$Ny)**1.21)*(($fy*$cUnitToKsi/50)**-0.838)]
	# set tetac [expr $tetac+$tetay]
	set tetapc [expr 14.51*(($h/$tw)**-1.21)*((1.0-$N/$Ny)**3.035)*(($fy*$cUnitToKsi/50)**-0.498)]
	# set tetapc [expr $tetac+$tetapc]
	set Lambda [expr 3800*(($h/$tw)**-2.49)*((1.0-$N/$Ny)**3.5)*(($fy*$cUnitToKsi/50)**-2.391)]
	set alfah [expr ($mc-$my)/($tetap)/$ke]
	set alfac [expr -$mc/($tetapc)/$ke]
	#check the values
	if {$doCheck == "Yes"} {
		puts "\n\n--------------Column--------------"
		foreach var {sec N L tetay alfah alfac my tetap tetapc ke} {
			set value [set "$var"]
			puts "$var = $value"
		}
	}
	uniaxialMaterial Bilin $ID $ke $alfah $alfah $my -$my $Lamda 0\
		0 0 1 0 0 0 $tetap $tetap $tetapc $tetapc 0 0 $tetau $tetau 1 1 $inputs(nFactor)
}