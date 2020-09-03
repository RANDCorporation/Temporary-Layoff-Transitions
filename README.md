# RAND Commentary – Temporary Layoff Transitions
ED & Labor Unit

This GitHub repository supports a RAND Commentary written by Kathryn Edwards and can be found at the following URL: https://www.rand.org/blog/2020/08/what-unemployment-statistics-obscure-about-temporary-layoffs.html

#### -- Project Status: Completed.

## Project Description
Using the CPS Basic Monthly Sample of the Current Population Survey (CPS) from January to June, we count the number of workers in month t who are on temporary layoff and what employment state they are in month t+1. 

### Methods Used
* Descriptive statistics

### Technologies
* Stata 15

## Getting Started

1. Download the three Do files in this repository.

2. Download data from the cps.ipums.org (see “Analysis” do file for list of variables).
    
3. Run “Format CPS extract.do”

4. Run “Analysis – Temp v Permanent Layoffs.do” to generate the transition statistics used in the commentary. Once exported, the number of workers transitioning can be calculated from the total in temporary by the relevant transition rates. 


### Other notes

In this file, we estimate the transitions between discrete labor market statuses from month to month. We are most interested in temporary layoffs. Unlike permanent layoffs, workers on temporary layoff indicate in the CPS survey that they will be recalled back to their job within six months. Our question is, of the workers who started were on temporary layoff in a specific month, how many remained so the next month? There are two key considerations. First, due to the unique nature of the pandemic and the quarantine orders, many workers who were unemployed were counted as “employed but not at work” and the reason for being not at work was “other”. The Commissioner of the Bureau of Labor Statistics indicated that these workers were misclassified as employed when they should have been unemployed. We assume that these workers would have been counted as temporary layoff, and we include them in our count of temporary layoffs. You can read more about these workers in a discussion from Brookings (Bauer, Edelberg, O'Donnell, and Shambaugh, 2020) and find the labor questionnaire from the CPS here (https://www2.census.gov/programs-surveys/cps/techdocs/questionnaires/Labor%20Force.pdf).
 
The second consideration is the appropriate weights. The CPS has two separate weights to make the survey sample representative of the US population. One weight (WTFINL) is used if you are looking at a specific point in time, or one month of data. Using WTFINL allows us to calculate the distribution of workers across different employment statuses in a given month (e.g., May 2020). The second weight (LNKFW1MWT) is used to analyze month-to-month transitions of workers that can be linked across the Basic Monthly CPS. That’s because each month, about a fourth of the CPS sample leaves the survey, by design. To calculate the transition rates, we use LNKFW1MWT which accounts for this aspect of the survey design. For example, LNKFW1MWT allows us to calculate the share of workers on temporary layoff in April who were still on temporary layoff in May, preserving May as a representative sample of the United States. Using the transitions rates calculated using the LNKFW1MWT weight, we then apply these rates to the estimates of the number of workers in a given month (calculated using WTFINL). This keeps both the count of workers and the share transitioning accurate, even though the weights used are different.

Data extract from the CPS downloaded on August 1, 2020 by Daniel Schwam.

Reference(s): 

1. Sarah Flood, Miriam King, Renae Rodgers, Steven Ruggles and J. Robert Warren. Integrated Public Use Microdata Series, Current Population Survey: Version 7.0 [dataset]. Minneapolis, MN: IPUMS, 2020. https://doi.org/10.18128/D030.V7.0

2. Bauer, Laren, Wendy Edelberg, Jimmy O'Donnell, and Jay Shambaugh (2020). "Who are the potentially misclassified in the Employment Report?" Brookings. Published online on June 30, 2020. https://www.brookings.edu/blog/up-front/2020/06/30/who-are-the-potentially-misclassified-in-the-employment-report/#cancel

## Project Members:

Kathryn Edwards (kathryne@rand.org) and Daniel Schwam (dschwam@rand.org)

* Feel free to contact team leads with any questions or if you are interested in contributing!

## Suggested Citation for this repository: 

Schwam, Daniel, and Kathryn Edwards, “Within Unemployment Transitions in the Current Population Survey,” GitHub, RAND Corporation Repository, last updated 24 August 2020. As of August 27, 2020: https://github.com/RANDCorporation/Temporary-Layoff-Transitions

