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

#W section proprties following Lignos

#inputs:
#I33,Area, Z33, tw, t2, tf, t3
# L, N
# inputs(Es), fy, cUnitFy (Fy unit->Ksi), cUnitL (L unit->inch)
set lbToRy 20.
set h [expr $d-2.*$tf]
set ke [expr $inputs(Es)*$I33*6./$L]
# set Ny [expr $Area*$fy]
set my [expr 1.06*$fy*$Z33]
set mc [expr $my*1.09]
set tetay [expr $my/$ke]
set tetap [expr 0.19*(($h/$tw)**-0.3145)*(($bf/(2.0*$tf))**-0.1)*($lbToRy**-0.1185)*(($L/$d)**0.113)*(($d*$cUnitL/(21))**-0.76)*(($fy*$cUnitFy/50)**-0.07)]
# set tetap [expr $tetap+$tetay]
set tetapc [expr 9.62*(($h/$tw)**-0.513)*(($bf/(2.0*$tf))**-0.863)*($lbToRy**-0.108)*(($fy*$cUnitFy/50)**-0.36)]
# puts "tetapc= 4.645*(($h/$tw)**-0.449)*(($bf/(2.0*$tf))**-0.837)*(($d*$cUnitL/(21))**-0.265)*(($fy*$cUnitFy/50)**-1.136)"
# puts "tetapc= $tetapc"
# set tetapc [expr $tetap + $tetapc]
set Lamda [expr 592*(($h/$tw)**-1.138)*(($bf/(2.0*$tf))**-0.632)*($lbToRy**-0.205)*(($fy*$cUnitFy/50)**-0.391)]
set alfah [expr ($mc-$my)/$tetap/$ke]
set alfac [expr -$mc/$tetapc/$ke]
