use touch.dta, clear
set more off

/*POSSIBLE TO DO THINGS:
Should we do a cronbach alpha on the found factors in the factor analysis, to see whether they actually measure a similar thing (because that is what we're doing right)?
Check comfortable scale for variance and missing data (just like we did for the sensation scales). 
Look into touch aversion; skip participants who have high aversion. 
Maybe see whether there is a difference in perceived likability of confederate between group that received possitive vs negative first.
*/

* Drop irrelevant variables
drop timestamp-confederate meaningofthetouch-whyorwhynot

* Rename variables
ren (participantid questionwastouchreceived) (id touchq)
ren (a b c d e f) (comfortable pleasant welcomed atease acceptable pleased)
ren (g h i j k l) (light_heavy soft_hard short_long relaxed_tense smooth_rough elastic_rigid)

* Dropped cases, see general data for why
drop if id == 101 | id == 105 | id == 207 | id == 208 | id == 302 | id == 409 | id == 616

//DROP CASES THAT HAVE AVERAGE TOUCH AVOIDANCE>3!!:
//drop if id== 104 |id== 109 |id== 216 |id== 304 | id== 316 | id== 414 | id== 502 |id== 604 
codebook id // 86 cases left

* Generate pos & neg groups for script A & B
gen pos = 1 if touchq == 2 & script == "A"
replace pos = 1 if touchq == 4 & script == "B"
replace pos = 0 if touchq == 4 & script == "A"
replace pos = 0 if touchq == 2 & script == "B"

* Missing data
// mdesc // pair-wise or case-wise?

* Outliers
/* Antal: checking outliers for Likert scale responses is generally tricky and 
doesn't make much sense because we don't know whether a person REALLY wants to 
respond 4 to all items or is just filling in nonsense. Here we choose to leave 
it for now, we may have to check case by case if we want to find out.
Yeah, checking outliers is hard in this case (Likert scale). I guess you could 
look at people that are vastly different (Cooks distance or leverage), but then 
again, it is always possible that some people truely were that different in 
their experience. 
*/

* Items with low variance
sum comfortable-elastic_rigid, det // Between 1.4 - 1.9 for all items, so no anomalies here I guess

* Scale reliability test for comfortable scale
alpha comfortable-pleased, item // Include missing data, alpha = .89, excluding any items gives a lower alpha, so no item is removed

* Correlation matrix and factor analysis for physical sensation scale (Pos vs. Neg): drop if r<.3 with all other items
/* Can be confusing, so comment these out for the moment:
polychoric light_heavy-elastic_rigid if pos == 1
display r(sum_w)
global N = r(sum_w)
matrix r = r(R)
factormat r, n($N) pf // factors(2)
rotate, oblimin oblique normalize blank(.3)

polychoric light_heavy-elastic_rigid if pos == 0
* factor analysis for physical sensation
display r(sum_w)
global N = r(sum_w)
matrix r = r(R)
factormat r, n($N) pf // factors(2)
rotate, oblimin oblique normalize blank(.3)
*/


//Correlations with all items in there (since we remove short_long later on):
polychoric light_heavy soft_hard short_long relaxed_tense smooth_rough elastic_rigid
polychoric light_heavy soft_hard short_long relaxed_tense smooth_rough elastic_rigid if touchq == 2
polychoric light_heavy soft_hard short_long relaxed_tense smooth_rough elastic_rigid if touchq == 4

* Correlation matrix and factor analysis for physical sensation scale (Q2 vs. Q4)
//its more likely that the meaning/interpretation of the questionnaire changes between questionnaire, that is why we should look at the following factor analyses for q2 and q4. 
polychoric light_heavy soft_hard relaxed_tense smooth_rough elastic_rigid if touchq == 2
display r(sum_w)
global N = r(sum_w)
matrix r = r(R)
factormat r, n($N) pf //factors(2) // results don't change much after specifying extracting 2 factors
rotate, oblimin oblique normalize blank(.3)
estat kmo // .69, nearly adequate sample size (>=.70)

polychoric light_heavy soft_hard relaxed_tense smooth_rough elastic_rigid  if touchq == 4
display r(sum_w)
global N = r(sum_w)
matrix r = r(R)
factormat r, n($N) pf //factors(2)
rotate, oblimin oblique normalize blank(.3)
estat kmo // .72, adequate sample size

/* Variables relaxed_tense,smooth_rough and elastic_rigid load onto a factor nicely. 
However, light_heavy short_long soft_hard  do not load onto the factors the same in q2 and q4 factor analysis. Especially short_long is very different, so, try removing it. 
Results with short_long removed: light_heavy and relaxed_tense now load onto the same factor very strongly. 
*/

* Bartlett's test of sphericity
factortest light_heavy soft_hard relaxed_tense smooth_rough elastic_rigid if touchq == 2
factortest light_heavy soft_hard relaxed_tense smooth_rough elastic_rigid if touchq == 4
// NOTE: these give different KMO than 'estat kmo'!!

* Cronbach's alpha for each factor
alpha light_heavy-soft_hard, item // .83
alpha relaxed_tense-elastic_rigid, item // .80

* Total variance explained by each factor (see first table of factor analysis result)
// Q2: F1: 87.3%; F2: 25.2%
// Q4: F1: 96.4%; F2: 10.8%
// Shall we take an average of the 2Q to report in the result?

* Calculate mean for comfortable scale (rmean is supposed to take average of all NON-MISSING values)
egen comf_mean = rmean(comfortable-pleased)

* Calculate mean for physical sensation scale (per factor)
* First factor: deals with pressure (static sensation), name it "force"
egen force = rmean(light_heavy-soft_hard) //SO: JUST REMOVE THE FIRST FACTOR, AND ONLY LOOK AT THE SECONDFACTOR!
* Second factor: deals with movement (dynamic sensation), name it "movement"
egen movement = rmean(relaxed_tense-elastic_rigid) 
* Third factor: short_long. This one deals with "duration" (time and/or length). One explanation for the insignificance might be that the physical device had a fixed and thus limited length. 

* Reshape to wide format:
reshape wide touchq-elastic_rigid comf_mean force movement, i(id) j(pos)

* T-test assumptions
* Normality for averaged comfortable scale
swilk comf_mean1 // rejected p=0.01
swilk comf_mean0
ladder comf_mean1 
ladder comf_mean0 // squared transformation has p>0.05 in both ladders, so lets use that.
//gladder comf_mean1
//gladder comf_mean0
gen comf_mean1sq = comf_mean1^2
gen comf_mean0sq = comf_mean0^2
swilk comf_mean1sq // p=0.97602, normal
swilk comf_mean0sq // p=0.14892, normal
* Normality for physical sensation scale (per factor)
swilk force1
swilk force0
swilk movement1
swilk movement0
swilk short_long1
swilk short_long0  // all normal

* No significant outliers in the differences between the two related groups
/* I just checked apprantly this is an important assumption, there's no standard 
way to quailfy "outliers" in Likert scale responses, but we can mention it in the report */
// graph box comf_mean0 comf_mean1 firstfactor0 secondfactor0 short_long0 short_long1 firstfactor1 secondfactor1

* Paired t-test for averaged comfortable scale
ttest comf_mean1sq == comf_mean0sq // significant p=0.0001

* Paired t-test for physical sensation scale (per factor)
ttest force1 == force0  // p=0.08
ttest movement1 == movement0 // p=0.051
ttest short_long1 == short_long0 // p=0.75

* Paired t-test for physical sensation scale per item
/* Since we don't report per item result, commented out for now.
ttest light_heavy1 == light_heavy0 
ttest soft_hard1 == soft_hard0
ttest short_long1 == short_long0 //this item is very different. In the q2 factor analysis it was left out (so it would be a seperate factor). Also, short_long deals with time, while all other factors are really about physical sensations. 
//Also, the ttest of the first factor is even more unsignificant if we add short_long to it.
ttest relaxed_tense1 == relaxed_tense0
ttest smooth_rough1 == smooth_rough0
ttest elastic_rigid1 == elastic_rigid0 
*/

* whether age / gender / ethnicity could be moderators?
