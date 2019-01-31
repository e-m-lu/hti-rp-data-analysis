clear
use touch+general.dta
set more off

//without avoidshakinghandsofstrangers
egen avoidmean2 = rmean(avoidtouchinghandsoffriends-annoyingwhenfriendsfamilyhug)


pwcorr avoidmean comf_mean1sq comf_mean0sq force1 force0 movement1  movement0, sig
//corr avoidmean comf_mean1sq comf_mean0sq force1 force0 movement1  movement0
//only weak to very weak correlations (.15 and 1.6 are the two highest, all others below 0.1).

//Closer look:
pwcorr avoidshakinghandsofstrangers-annoyingwhenfriendsfamilyhug avoidmean2 avoidmean comf_mean1sq comf_mean0sq force1 force0 movement1  movement0, sig
//Still very weak to weak. Only 3 correlations above 0.2 -> uncomfortabletouchedbyfriends/comf_mean1sq (0.28), uncomfortabletouchedbyfriends/comf_mean0sq (0.28), and annoyingwhenfriendsfamilyhug/force1 (0.22)
//Those two 0.28 correlations make sense kinda. Perceiver comfortability of the touch is decreased when someone is uncomfortable being touched (by a friend though, no correlation for being touched by a stranger)


alpha avoidshakinghandsofstrangers-annoyingwhenfriendsfamilyhug, item

polychoric avoidtouchinghandsoffriends-annoyingwhenfriendsfamilyhug
display r(sum_w)
global N = r(sum_w)
matrix r = r(R)
factormat r, n($N) pf factors(1) // results don't change much after specifying extracting 2 factors
rotate, oblimin oblique normalize blank(.3)
estat kmo 

// Say that we took the touch aversion from someone else. Report on alpha of touch aversion. do factor analysis, show forcing everything on 1 factor. First item is not the best (0.55). Look at avoidmean with and without that first item, and report that both are similar (no correlations witht the DV's). 
//Then, use the touch aversion mean to describe the data (mean of means, DV and maybe how many have a mean higher than 3). 

