#########################################################################
#     please keep this notification at the beginning of this file       #
#                                                                       #
# Code to perform dynamic analysis by avoidance of numerical divergence #
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

pattern UniformExcitation $seriesTag 1 -accel $seriesTag
source ../general/getMaxResp.tcl
source ../general/doTimeControlAnalysis.tcl
remove loadPattern $seriesTag

