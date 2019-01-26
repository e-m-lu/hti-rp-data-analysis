clear
use general.dta

//file has weird empty last rows, so remove last empty rows:
gen n = _n 
drop if n>93

// rename variables:
ren (participantid ) (id )

//Drop cases that are not good data:
drop if id == 101 | id == 105 | id == 207 | id == 208 | id == 302 | id == 409 | id == 616 //first, drop same participants. 
codebook id // 86 cases left, also for general.dta, so that is good.

//Take average over all the touch avoidance measures: (takes average of all non-missing values):
egen avoidmean = rmean(avoidshakinghandsofstrangers-annoyingwhenfriendsfamilyhug)

//Have a look at avoidmean:
codebook avoidmean, det
tab avoidmean, freq
//hist avoidmean

//Cases with the following id's have an avoidmean above 3 (which is an arbitrary number, not necessarily going to be our threshold):
drop if id== 104 |id== 109 |id== 216 |id== 304 | id== 316 | id== 414 | id== 502 |id== 604 


//WATCH OUT: FOLLOWING NUMBERS ARE BASED ON ORIGINAL DATASET, NO TOUCH AVOIDANCE PEOPLE REMOVED YET!

//Look at age:
codebook age, det
tab age //average age: 27.1279, SD=10.126

//Look at etnicity:
tab  ethnicgroup, freq //51 dutch persons, 16 indian guys 

//Look at gender:
tab gender,freq //47 males, 39 females


