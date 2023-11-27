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
set e $inputs(Es)
set doCheck Yes
set h [expr $d-2.*$tf]
set B $bf 
set H $d
set Z33 [expr $B*$H**2./4]
set B [expr ($bf-$tw)/2.]
set H $h
set Z33 [expr $Z33-2.*($B*$H**2./4)]
# puts "Z33= $Z33"
set I33 $Iz
set Ny [expr $Area*$fy]
set eta [expr 12.*$e*$I33/($L**2.)/$G/$AS2]
set ke [expr $e*$I33*6./$L/(1.+$eta)]
set Mpe [expr $fy*$Z33]
set NNy [expr $N/$Ny]
if {$NNy < 0.2} {
	set Mce [expr $Mpe*(1.-$NNy/2.)]
} else {
	set Mce [expr $Mpe*9./8.*(1.-$NNy)]
}
set my $Mce
set tetay [expr $my/$ke]

set mc [expr $my*1.11]
if {$eleType == "Beam"} {
	set a [expr 9.*$tetay]
	set b [expr 11.*$tetay]
	set c 0.6
} else {
	if {$N0 <= 0} {
		set a [expr max(0.8*(1.-$NNy)**2.2*(0.1*$L/$R22+0.8*$h/$tw)**(-1)-0.0035,0)]
		set b [expr max(7.4*(1.-$NNy)**2.3*(0.5*$L/$R22+2.9*$h/$tw)**(-1)-0.0060,0)]
		set c [expr 0.9-0.9*$NNy]
	} elseif {$NNy < 0.2} {
		set a [expr 9.*$tetay]
		set b [expr 11.*$tetay]
		set c 0.6
	} else {
		set a [expr max(13.5*(1.-5./3.*$NNy)*$tetay,0)]
		set b [expr max(16.5*(1.-5./3.*$NNy)*$tetay,0)]
		set c [expr max(0.6*(1.-5./3.*$NNy)+0.2,0.2)]
	}
}
set tetap $a
set tetapc [expr $b-$a]

#compute Lambda following Lignos
if {$Shape == "SteelTube"} {
	set Lambda [expr 3800*(($h/$tw)**-2.49)*((1.0-$N/$Ny)**3.5)*(($fy*0.0142/50)**-2.391)]
} else {
	set Lamda [expr 26.36*(($h/$tw)**-.589)*(($bf/(2.0*$tf))**-0.574)*(($fy*$cUnitFy/50)**-1.454)]
}
set alfah [expr ($mc-$my)/($tetap)/$ke]
set alfac [expr -$mc/($tetapc)/$ke]
#check the values
if {$doCheck == "Yes"} {
	puts "\n\n--------------Column--------------"
	foreach var {j NNy L tetay alfah alfac my tetap tetapc ke} {
		set value [set "$var"]
		puts "$var = $value"
	}
}
