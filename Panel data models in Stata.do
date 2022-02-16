clear all 
set more off
*Giulia Roggero
*16/02/2022

*pooled OLS Estimator
*between estimator
*first differences estimator
*fixed effect within estimator
*dummy variables regression
*random effects estimator
*Hausman test for fixed vs random effects

global datadir "C:\Users\giuli\OneDrive\Desktop\panel data models in stata"
*note:remember to put dummy variables for years
use "$datadir/JTRAIN.dta", clear
*effect of training grants on firm scrap rate

*drop missing observations for dependent variables
drop if lscrap==.
*309 observations deleted


*let's analyse the data

describe fcode year lscrap tothrs d88 d89 grant grant_1
*lscrap is indicating the productivity or lack of productivity: it's the dependent variable.

list fcode year lscrap tothrs d88 d89 grant grant_1 in 1/10

summarize fcode year lscrap tothrs d88 d89 grant grant_1

*summarize is not taking account that we are dealing with panel data
*we need to set everything as panel data
* we have 3 years of data for each firm! 

xtset fcode year
xtdescribe
xtsum fcode year lscrap tothrs d88 d89 grant grant_1

*within variation: is within the same firm over time
*between variation: one firm compared to the rest of the firms

*****POOLED OLS,Between, and first differences estimator

*pooled ols estimator(we are ignoring the panel data nature of the dataset):

reg lscrap tothrs d88 d89 grant grant_1
*the Rsquared is really low and none of the coefficients are significantly different from zero except from the intercept

*interpretation: how the total hours of training across the firms and over time influence the log of scrap rate. we don't distinguish between the variaition across the firm and over time.

*BETWEEN ESTIMATOR: (xtreg tells stata that we have panel data)

xtreg lscrap tothrs d88 d89 grant grant_1, be

*Lscrap is not the original value, but it's the average of lscrap over time for each firm-> regression on group means!
*for the betweeen estimator is the variation between each firm and not within each firm(we are not looking at within)
*we are collapsing the dataset with one observation per year for each firm 

*FIRST DIFFERENCES ESTIMATOR
sort fcode year
gen dlscrap=d.lscrap
gen dtothrs=d.tothrs
gen dgrant=d.grant
*note: we are not including the other indipendent variaibles because of perfect collinearity: they would be omitted anyway
reg dlscrap dtothrs dgrant

*INTERPRETATION: if the total hours of training increase from one period to the next for a particular firm, the lscrap would decrease of 0.003 from one period to the next(for the same firm)

*FIXED EFFECT WITHIN ESTIMATOR* (within the same firm!)


xtreg lscrap tothrs d88 d89 grant grant_1, fe

*NOTE*we don't have the original variables, but we have the within transformation, which means: we have log of scrap minus the average of the log of scrap for same firm over time. and same for all the independent variables!

*predict and summarize  the individual specific effect a_i

predict ai,u
list fcode year lscrap ai in 1/10
summarize ai
*interpretation: there is something about the first firm that the log of scrap rate are that much lower than the average firm.

*DUMMY VARIABLES REGRESSION!

sort fcode

reg lscrap tothrs d88 d89 grant grant_1 i.fcode
*create dummy variables for each firm
*54 dummy variables one for each firm->so 53 coefficients

*R squared for fixed effect estimator and dummy variables regression
*calculate them manually

xtreg lscrap tothrs d88 d89 grant grant_1, fe

display e(mss)
display e(rss)
scalar rsquared0 = e(mss)/((e(mss)+e(rss)))
display rsquared0

reg lscrap tothrs d88 d89 grant grant_1 i.fcode
display e(mss)
display e(rss)
scalar rsquared1 = e(mss)/((e(mss)+e(rss)))
display rsquared1

*why the R squared is much higher in the dummy variable regression?
*the reason is that in the within the coefficients and the independent variable are not the original variable, but are time 
*dimind variable. (VARIABLE MINUS ITS MEAN OVER TIME FOR THE WITHIN)
* so we don't have that much variation

*********RANDOM EFFECT ESTIMATOR*

xtreg lscrap tothrs d88 d89 grant grant_1, re

*an increase of total number of hours in training will result in lower scrap rates

*random effect parameter theta

xtreg lscrap tothrs d88 d89 grant grant_1, re theta


*the hausman test is used to decide wether to use fixed effect or random effect.

*h0= fe coeefficients are not significanlty different from the Re coefficients

xtreg lscrap tothrs d88 d89 grant grant_1,fe
estimates store fixed

xtreg lscrap tothrs d88 d89 grant grant_1,re
estimates store random


hausman fixed random

*look at the p value, we reject the null hypothesis! so Fe coefficients are significantly different from Re coefficients.
*the coefficients are very similar
* 
*if the hausman test statistic is insignificant, then use RE
*if the hausman test is significant, use FE
*HERE IT'S NOT significant, we use RE so we are more efficients

*if the coefficients weren't so similar, we would have a significant test, so we would have used the FE

*the end



































