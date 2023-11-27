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
#I22,Area, Z22, tw, bf, tf, d
# L, N
# inputs(Es), fy, cUnitFy (Fy unit->Ksi), cUnitL (L unit->inch)
set e $inputs(Es)
set h [expr $d-2.*$tf]
set B $bf 
set H $d
set Hw [expr $d-2.*$tf]
set Z22 [expr (2*$tw*$B**2.+$Hw*$tw**2.)/4]
set I22 $Iy
set ke [expr $inputs(Es)*$I22*6./$L]
set Ny [expr $Area*$fy]
set my [expr $fy*$Z22*(1.0-$N/$Ny)]
# puts "my=  $fy*$I22*(1.0-$N/$Ny)"
set mc [expr $my*1.11]
set tetay [expr $my/$ke]
set tetap [expr 0.07*(($h/$tw)**-0.35)*(($bf/(2.0*$tf))**-0.09)*(($L/$d)**0.31)*(($d*$cUnitL/(21))**-0.281)*(($fy*$cUnitFy/50)**-0.383)]
# set tetap [expr $tetap+$tetay]
set tetapc [expr 4.645*(($h/$tw)**-0.449)*(($bf/(2.0*$tf))**-0.837)*(($d*$cUnitL/(21))**-0.265)*(($fy*$cUnitFy/50)**-1.136)]
# puts "tetapc= 4.645*(($h/$tw)**-0.449)*(($bf/(2.0*$tf))**-0.837)*(($d*$cUnitL/(21))**-0.265)*(($fy*$cUnitFy/50)**-1.136)"
# puts "tetapc= $tetapc"
# set tetapc [expr $tetap + $tetapc]
set Lamda [expr 26.36*(($h/$tw)**-.589)*(($bf/(2.0*$tf))**-0.574)*(($fy*$cUnitFy/50)**-1.454)]
set alfah [expr ($mc-$my)/$tetap/$ke]
set alfac [expr -$mc/$tetapc/$ke]
