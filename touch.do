use "C:\Users\Fei\Desktop\touch.dta", clear
set more off

//GitHub test!!

browse

* drop variables we won't analyze
drop timestamp-confederate
drop meaningofthetouch-whyorwhynot

* rename items
ren participantid id
ren questionwastouchreceived touchq

ren a comfortable
ren b pleasant
ren c welcomed
ren d atease
ren e acceptable
ren f pleased

ren g light_heavy
ren h soft_hard
ren i short_long
ren j relaxed_tense
ren k smooth_rough
ren l elastic_rigid

* drop bad cases, see general for why
table id
drop if id == 101
drop if id == 105 // one touch
drop if id == 207
drop if id == 208
drop if id == 302 // one touch
drop if id == 409
drop if id == 616

* reverse touchq if script is B // this doesn't work yet, please let me know if you find a solution :)
if script == "B"{
	recode (2=4) (4=2)
}

* check missing data, how to deal with it? listwise or casewise option?
mdesc

* check items with low variance
sum comfortable-elastic_rigid, det

* check outliers? how in Likert scale?

* scale reliability test (cronbach's alpha) for uncomfortable/comfortable
alpha comfortable-pleased, item // include missing, alpha=0.89, excluding any items gives a lower alpha, so no item is removed

* correlation matrix (pos vs. neg) drop items with < 0.3 with all other items
polychoric light_heavy-elastic_rigid if touchq == 2 // short_long doesn't seem to correlate well with others except for the first two items
												   // but most have low-medium correlation, we want to avoid multicollinearity in factor analysis 
												   // (less shared explained variance)
polychoric light_heavy-elastic_rigid if touchq == 4 // short_long still doesn't correlate well, except for the first two items

* factor analysis for physical sensation
display r(sum_w)
global N = r(sum_w)
matrix r = r(R)
factormat r, n($N) pf // factors(2)
rotate, oblimin oblique normalize blank(.3)

// factor light_heavy-elastic_rigid if touchq == 2
// * factor rotations
// rotate, varimax // 2 factors: g&h is related to 'applied force', j,k,l is related to 'movement characteristic'
// 				// when including short_long, it gives 3 instead of 2 factors, consider it as the 3rd factor 'duration'
// 				// notice it has low correlations with all other items				
// * sample adequacy
// estat kmo // 0.70 is adequate
//
// factor light_heavy-elastic_rigid if touchq == 4
// rotate, varimax // similar loading of the factors compared to 2

estat kmo // 0.74 is adequate (>=0.7)

* do paird ttest on the average of the comfortable scale
* assumptions
swilk comfortable if touchq == 2
swilk comfortable if touchq == 4 // normal
robvar comfortable, by(touchq) // equal variance

// recode data into wide format so that q2 and q4 are in different columns, and then do paired
// this also doesn't work so far.. no idea why
reshape wide comfortable, i(id) j(touchq)

// gen comfort_pos = comfortable if touchq == 2
// gen comfort_neg = comfortable if touchq == 4

* for physical sensation, do ttest per factor, not per item

* whether age / gender is a mediator?
