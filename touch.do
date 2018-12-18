use touch.dta, clear

// browse
set more off

* drop variables we won't analyze
drop timestamp-confederate meaningofthetouch-whyorwhynot

* rename items
ren (participantid questionwastouchreceived) (id touchq)
ren (a b c d e f) (comfortable pleasant welcomed atease acceptable pleased)
ren (g h i j k l) (light_heavy soft_hard short_long relaxed_tense smooth_rough elastic_rigid)

* drop bad cases, see general data for why
table id
drop if id == 101 | id == 105 | id == 207 | id == 208 | id == 302 | id == 409 | id == 616
codebook id // 86 cases left

* gen pos & neg groups for script A & B
gen pos = 1 if touchq == 2 & script == "A"
replace pos = 1 if touchq == 4 & script == "B"
replace pos = 0 if touchq == 4 & script == "A"
replace pos = 0 if touchq == 2 & script == "B"

* check missing data, how to deal with it? listwise or casewise option?
mdesc

* check items with low variance (variance is somewhere between 1.4 and 1.9 for all items, so no anomalies here I guess)
sum comfortable-elastic_rigid, det

// Antal: checking outliers for Likert scale responses is generally tricky and doesn't make much sense
// because we don't know whether a person REALLY wants to respond 4 to all items or is just filling in nonsense
// here we choose to leave it for now, we may have to check case by case if we want to find out
// Yeah, checking outliers is hard in this case (Likert scale). I guess you could look at people that are vastly different (Cooks distance or leverage), 
// but then again, it is always possible that some people truely were that different in their experience. 

* scale reliability test (cronbach's alpha) for comfortable scale
alpha comfortable-pleased, item // include missing, alpha=0.89, excluding any items gives a lower alpha, so no item is removed

* correlation matrix for physical sensation (pos vs. neg), drop items with < 0.3 with all other items
//Interesting to see how the correlations are for pos and neg touches (short_long also seems to be the outlier here) //agreed
// But wait, I thought we were still doing the factor analysis two times, once for q2 and once for q4? I added correlations for positive and negative responses as an interesting insight, not with the intention of replacing the q2 and q4 factor analysis. 
polychoric light_heavy-elastic_rigid if pos == 1
polychoric light_heavy-elastic_rigid if pos == 0

* factor analysis for physical sensation
display r(sum_w)
global N = r(sum_w)
matrix r = r(R)
factormat r, n($N) pf // factors(2)
rotate, oblimin oblique normalize blank(.3)

* sample adequacy
estat kmo // 0.74 is adequate (>=0.7)

* take mean of all comfortable variables and per factor (rmean is supposed to take average of all NON-MISSING values)
egen comf_mean = rmean(comfortable-pleased) 
egen firstfactor = rmean(relaxed_tense-elastic_rigid) //Lets see how this goes

* reshape to wide format:
reshape wide touchq-elastic_rigid comf_mean firstfactor, i(id) j(pos)

* ttest assumptions
* normality
swilk comf_mean1 // rejected p=0.01
swilk comf_mean0

// * normality per item (since we're not running ttest per item for the first scale, this is perhaps not necessary)
// bysort pos: swilk comfortable // pos rejected p=0.01
// bysort pos: swilk pleasant
// bysort pos: swilk welcomed
// bysort pos: swilk atease
// bysort pos: swilk acceptable // pos rejected p=0.03
// bysort pos: swilk pleased

* equal variances per item
/* these use the old variable names, when I run them they give an error:
robvar comfortable, by(pos) // rejected p=0.01
robvar pleasant, by(pos)
robvar welcomed, by(pos)
robvar atease, by(pos)
robvar acceptable, by(pos)
robvar pleased, by(pos)
*/ 
* paired ttest for comfortable scale (average)
ttest comf_mean1 == comf_mean0 // significant p=0.00

* paired ttest for physical sensation scale (pos vs. neg) per factor
//and for the other variables (or did we have to do the t-test per factor? Let me check that in my notes..)
// I think Antal suggested we do per factor using factor mean
//Yes, I agree, Antal suggested we'd do ttest per factor mean. I made the variable firstfactor as a test, based on the current factor analysis (I added some comments to it btw, have a look). I think we may have to sit down and decide on the factors we will be using. 

ttest light_heavy1 == light_heavy0
ttest soft_hard1 == soft_hard0
ttest short_long1 == short_long0
ttest relaxed_tense1 == relaxed_tense0
ttest smooth_rough1 == smooth_rough0
ttest elastic_rigid1 == elastic_rigid0

ttest firstfactor1 == firstfactor0

* whether age / gender could be mediators?
