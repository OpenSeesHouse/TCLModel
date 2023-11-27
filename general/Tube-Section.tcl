proc Tube-Section { secID matID d t nfd nft} {
	# ###################################################################
	# Tube-Section  
	# ###################################################################
	# create a tube section given the nominal section properties
	# input parameters
	# secID - section ID number
	# matID - material ID number 
	# d  = outside depth (identical in both directions)
	# t = thickness
	# 
	# 
	# nfd = number of fibers along web depth 
	# nft = number of fibers along web thickness

	set y1 [expr -$d/2.]
	set y2 [expr -$d/2.+$t]
	set y3 [expr $d/2.-$t]
	set y4 [expr $d/2.]

  	set z1 [expr $d/2.]
	set z2 [expr $d/2.-$t]
	set z3 [expr -$d/2.+$t]
	set z4 [expr -$d/2.]

  
	section Fiber  $secID  {
   		#                     nfIJ  nfJK    yI  zI    yJ  zJ    yK  zK    yL  zL
   		patch quad  $matID  $nfd $nft   $y1 $z1   $y1 $z4   $y2 $z4   $y2 $z1
		patch quad  $matID  $nft $nfd   $y2 $z1   $y2 $z2   $y3 $z2   $y3 $z1
		patch quad  $matID  $nft $nfd   $y2 $z3   $y2 $z4   $y3 $z4   $y3 $z3
   		patch quad  $matID  $nfd $nft   $y3 $z1   $y3 $z4   $y4 $z4   $y4 $z1
	}
}
