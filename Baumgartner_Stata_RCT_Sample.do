*My main work in Stata occurrs through my Research Assistant position at NYU Africa House. Unfortunately, the code I write for this role is proprietary, and I have signed an NDA to not provide it to third parties. To provide evidence of my skill in Stata, I have downloaded a dataset (see below) from the World Bank associated with a Stata exercise as part of the book, "Handbook on Impact Evaluation: Quantitative Methods and Practices - Exercises 2009." In this program, I solve the exercise of evaluating a major microcredit program in Bangladesh, the Grameen bank. I have chosen an exercise from a Stata workbook that is over 10 years out of date to ensure that my personal coding skills are truly reflected. 

*This exercise dataset was created for researchers interested in learning how to use the models described in the "Handbook on Impact Evaluation: Quantitative Methods and Practices" by S. Khandker, G. Koolwal and H. Samad, World Bank, October 2009 (permanent URL http://go.worldbank.org/FE8098BI60).


*Open the RCT data
*cd "C:\Users\aleid\OneDrive\Documents\Proffesional\Coding Tests\Code\Samples\RCT Stata Code"

use "hh_91.dta"
describe

**ASSIGNMENT**

*generate dummy variable called "assign" to randomly assign 420 of the sample to the experimental group. The variable assign = 1 if household participates, assign = 0 otherwise. 

drop random
drop assign

generate random = runiform()
sort random
generate assign = (_n <= 420)
tabulate assign

*set seed to maintain assignment results: 
set seed 1234

**TEST EXTERNAL VALIDITY**
*The code below explores the representativeness of an experimental sample of 50 households compared to the larger sample of 420 households. 

*drop assign_50

generate assign_50 = (_n <= 50)
twoway (kdensity exptot) ///
(kdensity exptot if assign == 1, lpattern(dash)) ///
(kdensity exptot if assign_50 == 1, lpattern(shortdash)), ///
legend(label(1 "survey") label(2 "large sample") label(3 "small sample"))

*in the above we plot the density of 3 distributions: the full sample, the mini 50 person sample, and the 420 sample. We can conclude from plotting the densities that the larger experimental sample is the one that more closely matches the distribution of the entire sample. 

**TREATMENT AND CONTROL GROUP**
*randomly assign participating households to treatment or control group, much as we did before:  

generate random_treatment = runiform()
generate treatment = (random_treatment < 0.5) if assign == 1
tabulate treatment, missing

*we end up with 211 in the treatment group (treatment = 1), and 209 are in the control group (treatment = 0). 

*CALCULATE REQUIRED SAMPLE SIZE* 
summarize exptot
local mean_0 = r(mean)
local sd_0 = r(sd)

*set macro mean_1 to exepcted outcome in the treatment group (mean_0). In this case we assume that the program increases the total household expenditures by 600 taka, but in general this minimum program effect would be determined by similar literature. 


local mean_1 = `mean_0' + 600
sampsi `mean_0' `mean_1', sd(`sd_0') power(0.8)

*we see from the output that our required sample size is 205. Both the treatment and control group satisfy this requirement. 

*POWER CALCULATIONS*

count if treatment == 1 
local n_1 = r(N)

count if treatment == 0 
local n_0 = r(N)


sampsi  `mean_0', `mean_1', sd1(`sd_0') n1(`n_0') n2(`n_1')
*power twomeans `mean_0' `mean_1', sd1(`sd_0') sd2(`sd_1') n(220)

*chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://www.stata.com/manuals/pss-2power.pdf see page 13

**TABULATE TREATMENT**
tabulate treatment

*make it log: 
gen lnexptot = ln(exptot)

**AVERAGE TREATMENT EFFECT**
*calculate a t-test to compare the the averages between the treatment and control groups: 




*it appears from these results that the households who received the treatment did not increase their expenditure, but instead reduced it. This change is not statistically significant. 

**HETEROGENOUS IMPACT**
*see if incorporating other factors changes the effect on consumption: 

reg lnexptot treatment sexhead educhead famsize


*It looks like households with and educated head of household suffer less from a reduction in consumption, although again, the restuls are not statistically significant. 


