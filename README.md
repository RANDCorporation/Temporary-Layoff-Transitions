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

Data extract from the CPS downloaded on August 1, 2020 by Daniel Schwam.

Reference: Sarah Flood, Miriam King, Renae Rodgers, Steven Ruggles and J. Robert Warren. Integrated Public Use Microdata Series, Current Population Survey: Version 7.0 [dataset]. Minneapolis, MN: IPUMS, 2020. 
https://doi.org/10.18128/D030.V7.0

## Project Members:

Kathryn Edwards (kathryne@rand.org)

* Feel free to contact team leads with any questions or if you are interested in contributing!
