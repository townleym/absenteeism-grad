# Intro

This is an active project analyzing data from the US Department of Education to understand the relationship between chronic absenteeism and graduation rates. It is an ecological analysis of about 20,000 high schools in the US.

**Caveat:** Much of this is actively in progress. As of this writing (2/20/2019) the propensity models (espeically) are incomplete

# Purpose

The data are really, really messy--as expected--so traditional linear modeling doesn't give us a lot of insight. 

Furthermore, because it is observational data, we expect a lot of confounding.

With those in mind we set out to:

1. Evaluate whether ensemble models might improve our predictive ability
2. Account for confounding by using propensity modeling

# Data

We evaluated data for about 20,000 high schools on School Year 2014 graduation rates, rates of chronic absenteeism, and about 35 covariates.

- Graduation rate (Adjusted Cohort Graduation Rate)

  - Number of graduating students divided by
  - The number of students who started 9th grade net of in/out migration
  - Percentage of students that graduate in four years with a regular high school diploma
  - https://nces.ed.gov/fastfacts/display.asp?id=805
 
- Chronic Absenteeism rate
  - Students that miss 15 days or more in a school year
  - All absences of more than 50% of the day count, sickness, vacation, court appearance, susupension, etc.
  - https://ocrdata.ed.gov/Downloads/Master-List-of-CRDC-Definitions.pdf

- Covariates

  - Structural conditions (teacher certification, teacher absenteeism)
  - Administrative care (civil rights, sexual assault, violations, disciplinary actions)
  - Student engagement/achievement (sports participation, enrollment in higher math, AP)

The data were amalgamated from various sources at [US Department of Education](https://www2.ed.gov/about/inits/ed/edfacts/data-files/index.html):

- [Adjusted Cohort Graduation Rates](https://www2.ed.gov/about/inits/ed/edfacts/data-files/index.html#acgr)
- [Office of Civil Rights](https://ocrdata.ed.gov/)

# Code/scripts

- [gm_dataprep.Rmd](https://github.com/townleym/absenteeism-grad/blob/master/gm_dataprep.Rmd): produced the included data file `y1314_clean.csv` from earlier datafiles not included on this repo
- [gm_gradientboost.Rmd](https://github.com/townleym/absenteeism-grad/blob/master/gm_gradientboost.Rmd): random forest + gradient boosted models
- [gm_propscore.Rmd](https://github.com/townleym/absenteeism-grad/blob/master/gm_propscore.Rmd): propensity score estimation/evaluation (causal models)
- [gm_slides.Rmd](https://github.com/townleym/absenteeism-grad/blob/master/gm_slides.Rmd): produced the [slidy presentation visible at RPubs](http://rpubs.com/mtown/468907)
- [grad_model.Rmd](https://github.com/townleym/absenteeism-grad/blob/master/grad_model.Rmd): A scratch space where much of the content in the above files was developed

