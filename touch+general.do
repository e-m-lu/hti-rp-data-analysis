clear
use touch+general.dta
set more off

pwcorr avoidmean comf_mean1sq comf_mean0sq force1 force0 movement1  movement0
corr avoidmean comf_mean1sq comf_mean0sq force1 force0 movement1  movement0
//only weak to very weak correlations (.15 and 1.6 are the two highest, all others below 0.1).

//Closer look:
pwcorr avoidshakinghandsofstrangers-annoyingwhenfriendsfamilyhug avoidmean comf_mean1sq comf_mean0sq force1 force0 movement1  movement0
//Still very weak to weak. Only 3 correlations above 0.2 -> uncomfortabletouchedbyfriends/comf_mean1sq (0.28), uncomfortabletouchedbyfriends/comf_mean0sq (0.28), and annoyingwhenfriendsfamilyhug/force1 (0.22)
//Those two 0.28 correlations make sense kinda. Perceiver comfortability of the touch is decreased when someone is uncomfortable being touched (by a friend though, no correlation for being touched by a stranger)

