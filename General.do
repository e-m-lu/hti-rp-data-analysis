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

//Cases with the following id's have an avoidmean above 3:
// | 104 |109 |216 |304 | 316 | 414 | 502 |604 |

//Look at age:
codebook age, det
tab age
