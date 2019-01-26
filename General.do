clear
use general.dta

//file has weird empty last rows, so remove last empty rows:
gen n = _n 
drop if n>93


ren (participantid ) (id )

drop if id == 101 | id == 105 | id == 207 | id == 208 | id == 302 | id == 409 | id == 616 //first, drop same participants. 
codebook id // 86 cases left, also for general.dta, so that is good.

egen avoidmean = rmean(avoidshakinghandsofstrangers-annoyingwhenfriendsfamilyhug)


codebook avoidmean, det
//hist avoidmean
tab avoidmean, freq

//Cases with the following id's have an avoidmean above 3 (which is an arbitrary number, not necessarily going to be our threshold):
// | 104 |109 |216 |304 | 316 | 414 | 502 |604 |

//WATCH OUT: FOLLOWING NUMBERS ARE BASED ON ORIGINAL DATASET, NO TOUCH AVOIDANCE PEOPLE REMOVED YET!

//Look at age:
codebook age, det
tab age //average age: 27.1279, SD=10.126

//Look at etnicity:
tab  ethnicgroup, freq //51 dutch persons, 16 indian guys 

//Look at gender:
tab gender,freq //47 males, 39 females


