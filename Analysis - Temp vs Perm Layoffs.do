* COMMENTARY (The RAND Blog)
* Title: What Unemployment Statistics Obscure About Temporary Layoffs

* Commentary written by: Kathryn Anne Edwards

* Stata code written by: Daniel Schwam

* This Do file uses a pre-generated data dictionary from IPUMS to format the CPS extract.

* NOTE(S): 
* 1. You need to set the Stata working directory to the path where the data file 
*    is located.
* 2. You also need to ensure that the CPS data extract file name reflects the file 
*    name of your query (see line 67 of "Format CPS extract.do").

/*
Variables in our extract: 
Type	Variable			Label
H		YEAR				Survey year
H		SERIAL				Household serial number
H		MONTH				Month
H		HWTFINL				Household weight, Basic Monthly
H		CPSID				CPSID, household record
H		ASECFLAG			Flag for ASEC
H		MISH				Month in sample, household level
H		REGION				Region and division
H		STATEFIP			State (FIPS code)
H		METAREA				Metropolitan area
H		COUNTY				FIPS county code
H		FAMINC				Family income of householder
H		HRHHID				Household ID, part 1
H		HRHHID2				Household ID, part 2
P		PERNUM				Person number in sample unit
P		WTFINL				Final Basic Weight
P		CPSIDP				CPSID, person record
P		RELATE				Relationship to household head
P		AGE					Age
P		SEX					Sex
P		RACE				Race
P		POPSTAT				Adult civilian, armed forces, or child
P		HISPAN				Hispanic origin
P		EMPSTAT				Employment status
P		LABFORCE			Labor force status
P		OCC					Occupation
P		IND					Industry
P		CLASSWKR			Class of worker
P		UHRSWORKT			Hours usually worked per week at all jobs
P		UHRSWORK1			Hours usually worked per week at main job
P		UHRSWORK2			Hours usually worked per week, other job(s)
P		AHRSWORKT			Hours worked last week
P		AHRSWORK1			Hours worked last week, main job
P		AHRSWORK2			Hours worked last week, other job(s)
P		ABSENT				Absent from work last week
P		DURUNEM2			Continuous weeks unemployed, intervalled
P		DURUNEMP			Continuous weeks unemployed
P		WHYUNEMP			Reason for unemployment
P		WHYABSNT			Reason for absence from work
P		WHYPTLWK			Reason for working part time last week
P		WKSTAT				Full or part time status
P		EDUC				Educational attainment recode
P		EDUC99				Educational attainment, 1990
P		EDDIPGED			High school or GED
P		SCHLCOLL			School or college attendance
P		LNKFW1MWT			Longitudinal weight for two adjacent months (BMS only)
P		PANLWT				Month-to-month panel weight
P		HOURWAGE			Hourly wage
P		PAIDHOUR			Paid by the hour
P		UNION				Union membership
P		EARNWEEK			Weekly earnings
P		UHRSWORKORG			Usual hours worked per week, outgoing rotation groups
P		WKSWORKORG			Weeks worked per year, outgoing rotation groups
P		ELIGORG				(Earnings) eligibility flag
P		OTPAY				Usually receive overtime, tips, or commissions
P		UH_MLR_B3			Monthly labor force recode (formerly esr), 1994-2020_06
P		UH_LAY6M_B1			Recall to work within 6 months, 1994-2020_06
P		UH_LAYDT_B1			Return to work date, 1994-2020_06
P		UH_LAYOFF_B1		On layoff last week, 1994-2020_06
*/

* Set color scheme for figure output
set scheme s2color

* Set working directory
cd []

* Set to your personal CPS extract
global cpsextract 00039

* Format raw CPS data from IPUMS
do "Format CPS extract.do"

* Historical comparison of temporary and permanent layoffs

* Load analytic file
use "cps_${cpsextract}.dta", clear

* Subset to population aged 19 and older
drop if age < 19

* Drop children and people in the Armed Forces
drop if popstat != 1

* Subset unemployed persons and people not at work last week
drop if empstat != 12 & empstat != 21 & empstat != 22

* Make sure all individuals included in analysis are in the labor force
tab labforce, m

* Define employment states

* Temporary layoff (include employed, not at work for other reason)
gen emp_state = 1 if absent == 2 & uh_lay6m_b1 == 1
replace emp_state = 1 if empstat == 12 & whyabsnt == 15

* Permanent layoff (including people that are permanently unemployed)
replace emp_state = 2 if absent == 2 & uh_lay6m_b1 == -1
replace emp_state = 2 if absent == 1 & empstat == 21

* Other unemployed (i.e., new worker)
replace emp_state = 3 if empstat == 22

* Drop people not at work last week, but for a specified reason
drop if emp_state == .

* Variable label
label define emp_states 1 "Temporary layoff/Emp, not at work other" 2 "Permanent layoff/unemployment" 3 "Unemployed, new worker"
label values emp_state emp_states

* Distribution of unemployment states
tab empstat emp_state, m

* Aggregate to the employment state-month level
gen n = 1
collapse (sum) n [pweight=wtfinl], by(emp_state year month)

* Subset to 2020
drop if year != 2020

* Convert to millions
gen n_mil = n / 1000000

* Line graph over time
twoway (line n_mil month if emp_state == 1, lcolor(navy)) (line n_mil month if emp_state == 2, lcolor(maroon)) (line n_mil month if emp_state == 3, lcolor(green)), graphregion(color(white)) legend(order(1 "Temporary layoff" 2 "Permanent layoff/unemployment" 3 "Entrants") rows(2) size(small)) xtitle(" ") ytitle("Number of persons (millions)") xlabel(1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June") note("Temporary layoff includes workers that are employed but not at work for other reasons.") yline(0 20, lcolor(gs13))

graph export "figure1.pdf", replace

save "temp_and_perm_layoffs.dta", replace

* Export data to excel
export excel "temp_and_perm_layoffs.xlsx", sheetreplace sheet("figure1") firstrow(variables)

* Transitions from temporary to permanent layoff

* Re-load analytic file
use "cps_${cpsextract}.dta", clear

* Identify linked individuals across months (see "Long-Validation-Code.do" file 
* for source info and documentation)
do "Long-Validation-Code.do"

* Drop unmatched/unlinked cases
drop if matched_keep == 0

* Format date variable and set panel structure
gen month2 = month
gen date = ym(year, month2)
format date %tm
sort cpsidp date
xtset cpsidp date

* Subset to 2020
drop if year < 2020

* Ensure that individuals are at least 19 at the start of the analysis
by cpsidp: egen min_age = min(age)
drop if min_age < 19

* Drop children and people in the Armed Forces
drop if popstat != 1

* Generate a variable indicating the employment state of the individual in the
* current and following months

* Individuals are considered employed if they were classified as "at work" (empstat == 10)
* or the have a job and were absent from work the previous week for a specified 
* reason (whyabsnt != 15)
gen state_t0 = 1 if empstat == 10 | (empstat == 12 & whyabsnt != 15)


* Individuals classified by layoff status

* The CPS has misclassified workers that were not at work that should have been
* classified as on temporary layoff.
* Source: Bauer, Laren, Wendy Edelberg, Jimmy O'Donnell, and Jay Shambaugh (2020).
*		  "Who are the potentially misclassified in the Employment Report?" Brookings. 
* 		  Published online on June 30, 2020.
* URL: https://www.brookings.edu/blog/up-front/2020/06/30/who-are-the-potentially-misclassified-in-the-employment-report/#cancel

* Temporary layoff (including employed but not at work for other reasons)
replace state_t0 = 2 if empstat == 12 & whyabsnt == 15
replace state_t0 = 2 if absent == 2 & uh_lay6m_b1 == 1

* Permanent layoff (including people that are permanently unemployed)
replace state_t0 = 3 if absent == 2 & uh_lay6m_b1 == -1
replace state_t0 = 3 if absent == 1 & empstat == 21

* Other unemployed (i.e., new worker)
replace state_t0 = 4 if empstat == 22

* Not in the labor force (NILF)
replace state_t0 = 5 if labforce == 1

* Variable label
label define emp_state 1 "Employed" 2 "Temporary layoff" 3 "Permanent layoff/unemployment" 4 "Unemployed, new worker" 5 "NILF"
label values state_t0 emp_state

* Distribution to state in time t = 0
tab state_t0, m

* Employment state in time t = 1
* Employed
by cpsidp: gen state_t1 = 1 if F.empstat == 10 | F.empstat == 12 & F.whyabsnt != 15

* Employed, not at work for other reason

* Temporary layoff (including employed not at work for other reasons)
by cpsidp: replace state_t1 = 2 if F.empstat == 12 & F.whyabsnt == 15
by cpsidp: replace state_t1 = 2 if F.absent == 2 & F.uh_lay6m_b1 == 1

* Permanent layoff (including people that are permanently unemployed)
by cpsidp: replace state_t1 = 3 if F.absent == 2 & F.uh_lay6m_b1 == -1
by cpsidp: replace state_t1 = 3 if F.absent == 1 & F.empstat == 21

* Other unemployed (i.e., new worker)
by cpsidp: replace state_t1 = 4 if F.empstat == 22

* Not in the labor force (NILF)
by cpsidp: replace state_t1 = 5 if F.labforce == 1

* Assign labels
label values state_t1 emp_state

* Distribution to state in time t = 1
tab state_t1, m

* Drop individuals that only appear once (i.e., no longer in CPS) 
drop if state_t1 == .

* Joint distribution
tab state_t0 state_t1, m

cap drop n
gen n = 1

* Transition rates by employment states
preserve

	collapse (sum) n [pweight=lnkfw1mwt], by(state_t0 state_t1 year month)
	
	* Reshape to wide
	quietly reshape wide n, i(year month state_t0) j(state_t1)
	
	tempfile transitiondata
	save `transitiondata'

restore

preserve

	* Calculate population by employment state in time t = 0. Transition rates from specific employment statuses 
	* (e.g., from temporary layoff in April 2020 to employed in May 2020) are relative to the representative
	* sample that transitions from month-to-month. Hence why we use LNKFW1MWT instead of WTFINL here.
	collapse (sum) n [pweight=lnkfw1mwt], by(state_t0 year month)
	ren n t

	* Combine with transition rates
	merge 1:1 state_t0 year month using `transitiondata'
	drop _merge

	drop if month == 6

	format t n* %15.0f

	* Calculate percents
	foreach var of varlist n* {
		gen pct_`var' = (`var' / t) * 100
	}

	* Employment states of interest in time t == 0
	* keep if state_t0 == 2 | state_t0 == 3

	drop t n*

	* Label variables
	label var pct_n1 "Employed" 
	label var pct_n2 "Temporary layoff (incl. employed but not at work for other reason)" 
	label var pct_n3 "Permanent layoff/unemployment" 
	label var pct_n4 "Unemployed, new worker"
	label var pct_n5 "NILF"
	
	save "transition_matrix.dta", replace

	* Export to Excel
	export excel "transition_matrix.xlsx", sheetreplace sheet("Overall") firstrow(varlabels)

restore

* Generate figure 2 data and in-text numbers
use "transition_matrix.dta", clear

* Keep temporary layoff numbers only
keep if state_t0 == 2

* Format label values
label define month_lbl 1 "January to February" 2 "February to March" 3 "March to April" 4 "April to May" 5 "May to June" 6 "June to July" 7 "July to August", replace
label values month month_lbl

* Reorder, label variables, and export to Excel
drop year state_t0 pct_n4
order month pct_n2 pct_n1 pct_n3 pct_n5
label var month "Temporary layoff"
label var pct_n2 "Remained on temporary layoff"
label var pct_n1 "Became employed"
label var pct_n3 "Moved to permanent layoff"
label var pct_n5 "Left labor force"
export excel "temp_and_perm_layoffs.xlsx", sheetreplace sheet("Fig 2 and in-text") firstrow(varlabels) cell(A2)

* Format excel output
putexcel set "temp_and_perm_layoffs.xlsx", modify sheet("Fig 2 and in-text")

	putexcel A1 = "TRANSITION RATES"
	putexcel A1:E1, merge
	
	putexcel A12 = "TRANSITION COUNTS = RATES * NUMBER IN FIRST MONTH"
	putexcel A12:H12, merge
	
	putexcel G1 = "TEMPORARY NUMBERS"
	putexcel G1:H1, merge
	putexcel G2 = "Month"
	putexcel H2 = "Est."

	putexcel G3 = "January"
	putexcel G4 = "February"
	putexcel G5 = "March"
	putexcel G6 = "April"
	putexcel G7 = "May"
	putexcel G8 = "June"
	
	putexcel H3 = formula(=figure1!D2)
	putexcel H4 = formula(=figure1!D3)
	putexcel H5 = formula(=figure1!D4)
	putexcel H6 = formula(=figure1!D5)
	putexcel H7 = formula(=figure1!D6)
	putexcel H8 = formula(=figure1!D7)

	putexcel J1 = "IN-TEXT SHARE PERMANENT"
	putexcel J1:L1, merge
	putexcel J2 = "Month"
	putexcel K2 = "Est."
	
	putexcel J3 = "January"
	putexcel J4 = "February"
	putexcel J5 = "March"
	putexcel J6 = "April"
	putexcel J7 = "May"
	putexcel J8 = "June"
	
	putexcel K3 = formula(=figure1!D8)
	putexcel K4 = formula(=figure1!D9)
	putexcel K5 = formula(=figure1!D10)
	putexcel K6 = formula(=figure1!D11)
	putexcel K7 = formula(=figure1!D12)
	putexcel K8 = formula(=figure1!D13)
	
	putexcel A13 = "Temporary Layoff"
	putexcel A14 = "January to February"
	putexcel A15 = "February to March"
	putexcel A16 = "March to April"
	putexcel A17 = "April to May"
	putexcel A18 = "May to June"
	
	putexcel B13 = "Remained on temporary layoff"
	putexcel B14 = formula(=(B3/100)*H3)
	putexcel B15 = formula(=(B4/100)*H4)
	putexcel B16 = formula(=(B5/100)*H5)
	putexcel B17 = formula(=(B6/100)*H6)
	putexcel B18 = formula(=(B7/100)*H7)
	
	putexcel C13 = "Became employed"
	putexcel C14 = formula(=(C3/100)*H3)
	putexcel C15 = formula(=(C4/100)*H4)
	putexcel C16 = formula(=(C5/100)*H5)
	putexcel C17 = formula(=(C6/100)*H6)
	putexcel C18 = formula(=(C7/100)*H7)
	
	putexcel D13 = "Moved to permanent layoff"
	putexcel D14 = formula(=(D3/100)*H3)
	putexcel D15 = formula(=(D4/100)*H4)
	putexcel D16 = formula(=(D5/100)*H5)
	putexcel D17 = formula(=(D6/100)*H6)
	putexcel D18 = formula(=(D7/100)*H7)
	
	putexcel E13 = "Left labor force"
	putexcel E14 = formula(=(E3/100)*H3)
	putexcel E15 = formula(=(E4/100)*H4)
	putexcel E16 = formula(=(E5/100)*H5)
	putexcel E17 = formula(=(E6/100)*H6)
	putexcel E18 = formula(=(E7/100)*H7)
	
	putexcel F13 = "Entered temporary layoff"
	putexcel F14 = formula(=H4-B14)
	putexcel F15 = formula(=H5-B15)
	putexcel F16 = formula(=H6-B16)
	putexcel F17 = formula(=H7-B17)
	putexcel F18 = formula(=H8-B18)
	
	putexcel G13 = "CHECK"
	putexcel G14 = formula(=F14+B14)
	putexcel G15 = formula(=F15+B15)
	putexcel G16 = formula(=F16+B16)
	putexcel G17 = formula(=F17+B17)
	putexcel G18 = formula(=F18+B18)
	
	putexcel A23 = "Summary for Sankey Diagram"
	putexcel A23:H23, merge
	
	putexcel A25 = "Of the 16.8 million who were on temporary layoff in April 2020:"
	putexcel A26 = "In May"
	putexcel A28 = "Of the 12.4 million who were on temporary layoff in May 2020"
	putexcel A29 = "In June"
	
	putexcel B24 = "Remained on temporary layoff"
	putexcel B26 = formula(=B17)
	putexcel B29 = formula(=B18)
	
	putexcel C24 = "Became employed"
	putexcel C26 = formula(=C17)
	putexcel C29 = formula(=C18)
	
	putexcel D24 = "Moved to permanent layoff"
	putexcel D26 = formula(=D17)
	putexcel D29 = formula(=D18)
	
	putexcel E24 = "Left labor force"
	putexcel E26 = formula(=E17)
	putexcel E29 = formula(=E18)
	
	putexcel F24 = "+ Entered temporary layoff"
	putexcel F26 = formula(=F17)
	putexcel F29 = formula(=F18)
	
putexcel clear

* Other references:

* IPUMS extract:
* Sarah Flood, Miriam King, Renae Rodgers, Steven Ruggles and J. Robert Warren. 
* Integrated Public Use Microdata Series, Current Population Survey: Version 7.0 
* [dataset]. Minneapolis, MN: IPUMS, 2020. https://doi.org/10.18128/D030.V7.0
