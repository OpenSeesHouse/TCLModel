set inputs(sharedInputsFile) ../sharedInputs/inputs_SMF2d-2.tcl
set inputs(nFlrs) 1

set isolatorLabels "
    I1 I1 I1 I1
"
# set isolatorLabels "
#     -  I1 I1 I1 I1 -  
#     -  -  -  -  -  -   
#     -  -  -  -  -  -   
#     -  -  -  -  -  -   
#     -  -  -  -  -  -   
#     -  I1 I1 I1 I1 -  
# "
set beamSec(B1,1,1) W18X35
set beamSec(B1,2,1) W24X62
set beamSec(B1,3,1) W24X68

set columnSec(C1,1) W14X90;
set columnSec(C1,2) W14X145;
set columnSec(C1,3) W14X145;

set inputs(I1,h) 	  0.1;
set inputs(I1,L1) 	  0.3937; # effective length
set inputs(I1,L2) 	  3.7465;
set inputs(I1,L3)     3.7465;
set inputs(I1,mu1)    0.047; # friction coefficient
set inputs(I1,mu2)    0.072;
set inputs(I1,mu3)    0.085;
set inputs(I1,d1)     0.0635; # pendulum displacement limit
set inputs(I1,d2)     0.33528;
set inputs(I1,d3)     0.33528;
set inputs(I1,uy)     0.0005; # displacement where sliding starts (m)
set inputs(I1,kvc)    1e10; # vertical compression stiffness (N/m)
set inputs(I1,krt)    100.; # rotational stiffness about 3-axis, 1-axis and 2-axis
set inputs(I1,kvt)    100.; # vertical tension stiffness (N/m)
set inputs(I1,minFv)  0.1; # minimum compression force in the bearing (N)
set inputs(I1,tol)    1.e-5
set inputs(I1,Fry)    [expr 0.20]