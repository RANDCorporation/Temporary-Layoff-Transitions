# RAND Commentary – Temporary Layoff Transitions
ED & Labor Unit

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

In this file, we estimate the transitions between discrete labor market statuses from month to month. We are most interested in temporary layoffs. Unlike permanent layoff, workers on temporary layoff indicate in the CPS survey that they will be recalled back to their job within six months. Our question is, of the workers who started one month on temporary layoff, how many remained so the next month? There are two key considerations. First, due to the unique nature of the pandemic and the quarantine orders, many workers who were unemployed were counted as “employed but not at work” and the reason for being not at work was “other”. The Commissioner of the Bureau of Labor Statistics indicated that these workers were misclassified as employed when they should have been unemployed. We assume that these workers would have been counted as temporary layoff, and we include them in our count of temporary layoffs. You can read more about these workers in a discussion from Brookings (Bauer, Edelberg, O'Donnell, and Shambaugh, 2020) and find the labor questionnaire from the CPS here (https://www2.census.gov/programs-surveys/cps/techdocs/questionnaires/Labor%20Force.pdf).
 
The second consideration is the appropriate weights. The CPS has two separate weights to make the survey sample representative of the US population. One weight (WTFINL) is used if you are looking at one month of data. The second weight (LNKFW1MWT) is used if you are looking at linked month-to-month data. That’s because each month, about a fourth of the CPS sample leaves the survey, by design. To calculate the transition rates, we use LNKFW1MWT. That is, looking at the share of temporary layoff in April who were still temporary in May, we use the weight that keeps May a representative sample. We then apply these rates to the estimates of the number of workers in the month. This keeps both the count of workers and the share transitioning accurate, even though the weights used are different.

Data extract from the CPS downloaded on August 1, 2020 by Daniel Schwam.

Reference(s): 

1. Sarah Flood, Miriam King, Renae Rodgers, Steven Ruggles and J. Robert Warren. Integrated Public Use Microdata Series, Current Population Survey: Version 7.0 [dataset]. Minneapolis, MN: IPUMS, 2020. https://doi.org/10.18128/D030.V7.0

2. Bauer, Laren, Wendy Edelberg, Jimmy O'Donnell, and Jay Shambaugh (2020). "Who are the potentially misclassified in the Employment Report?" Brookings. Published online on June 30, 2020. https://www.brookings.edu/blog/up-front/2020/06/30/who-are-the-potentially-misclassified-in-the-employment-report/#cancel

## Project Members:

Kathryn Edwards (kathryne@rand.org)

* Feel free to contact team leads with any questions or if you are interested in contributing!
