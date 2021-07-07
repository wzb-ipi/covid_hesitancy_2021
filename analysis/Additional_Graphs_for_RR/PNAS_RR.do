***********************************************
***********************************************
***			COVID-19 Vaccination			***
***											***
***			Paper 1 - PNAS	R&R			    ***
***											***
***********************************************
***********************************************


***    Globals    *******************************************
*************************************************************
global data 	"C:\Users\geisslef\_Work\04_Paper\Covid-19-Vaccination\Daten\Wave2"
global out 		"C:\Users\geisslef\_Work\04_Paper\Covid-19-Vaccination\Daten\Wave2\Out"
global log		"C:\Users\geisslef\_Work\04_Paper\Covid-19-Vaccination\Daten\Wave2\Log"

clear all
set scheme plottigblind

* ---------------------------------------------------------------------------- *

********************
*** Prepare data ***
********************

use "C:\Users\geisslef\_Work\04_Paper\Covid-19-Vaccination\Daten\Wave1\D-P21-13185 HU Berlin Impfskeptiker_Finaler_Datensatz_ID-Link.dta", clear
foreach var of varlist * {
	rename `var' `var'_w1
}
rename ID_w1 ID
save "C:\Users\geisslef\_Work\04_Paper\Covid-19-Vaccination\Daten\Wave1\D-P21-13185 HU Berlin Impfskeptiker_Finaler_Datensatz_ID-Link-W1.dta", replace


use "$data/D-P21-13185 HU Berlin Impfskeptiker_Welle 2_Finaler_Datensatz_ergaenzt", clear

foreach var of varlist * {
	rename `var' `var'_w2
}
rename ID_w2 ID

format ID %20.0f
order ID
destring ID, replace

sort ID
merge 1:1 ID using "C:\Users\geisslef\_Work\04_Paper\Covid-19-Vaccination\Daten\Wave1\D-P21-13185 HU Berlin Impfskeptiker_Finaler_Datensatz_ID-Link-W1.dta"
drop _merge

save "C:\Users\geisslef\_Work\04_Paper\Covid-19-Vaccination\Daten\Wave1\Wave1_2_Merged_for-PNAS.dta", replace

* ---------------------------------------------------------------------------- *

***************************
*** Graphs for R&R PNAS ***
***************************

cap drop vacc_w2 
cap drop vig1_w2 
cap drop vig2_w2
clonevar vacc_w2 = v_28_w2
mvdecode vacc_w2, mv(99)
replace vacc_w2 = 0 if vacc_w2 == 2

gen vig1_w2 = v_74_w1
gen vig2_w2 = v_77_w1

mean vacc_w2, over(vig1_w2)
graph bar vacc_w2, over(vig1_w2) ytitle("Reported vaccination status in wave 2", size(medium)) b1title("Reported likelihood of getting" "vaccinated under hypothetical scenario in wave 1", size(medium)) graphregion(margin(0 0 0 2))
graph export "$out\Vaccination-in-Wave2-by-Willingness1.emf", as(emf) replace
graph export "$out\Vaccination-in-Wave2-by-Willingness1.png", as(png) replace

mean vacc_w2, over(vig2_w2)
graph bar vacc_w2, over(vig2_w2) ytitle("Reported vaccination status in wave 2", size(medium)) b1title("Reported likelihood of getting" "vaccinated under hypothetical scenario in wave 1", size(medium)) graphregion(margin(0 0 0 2))
graph export "$out\Vaccination-in-Wave2-by-Willingness2.emf", as(emf) replace
graph export "$out\Vaccination-in-Wave2-by-Willingness2.png", as(png) replace


* Pooled (Vignette 1 + Vignette 2) *
preserve
stack v_74   vacc_w2   v_77   vacc_w2 , into(pooled vacc_w2) wide
corr vacc_w2 pooled
mean vacc_w2, over(pooled)
graph bar vacc_w2, over(pooled) ytitle("Reported vaccination status in wave 2", size(medium)) b1title("Reported likelihood of getting" "vaccinated under hypothetical scenario in wave 1", size(medium)) graphregion(margin(0 0 0 2))
graph export "$out\Vaccination-in-Wave2-by-Willingness2-Pooled.emf", as(emf) replace
graph export "$out\Vaccination-in-Wave2-by-Willingness2-Pooled.png", as(png) replace
save "C:\Users\geisslef\_Work\04_Paper\Covid-19-Vaccination\Daten\Wave1\Wave1_2_Merged_for-PNAS--Stacked.dta", replace
restore


* Vaccination intention
tab v_33_w1 vacc_w2, row

cap drop vacc_w2no
gen vacc_w2no = vacc_w2 == 0
replace vacc_w2no = . if vacc_w2 == .

mean vacc_w2, over(v_33_w1)
graph bar vacc_w2 vacc_w2no, over(v_33_w1, relabel(1 "Yes" 2 "No" 3 "Have not decided yet")) ///
	 ytitle("Vaccination status in wave 2", size(medium)) /// 
	 b1title("Vaccination intention in wave 1", size(medium)) ///
	 yvaroptions(relabel(1 "Vaccinated" 2 "Not vacinated")) ///
	 graphregion(margin(0 0 0 2)) ///
	 stack percent
graph export "$out\Vaccination-in-Wave2-by-Vaccination_Intention-in-Wave1.emf", as(emf) replace
graph export "$out\Vaccination-in-Wave2-by-Vaccination_Intention-in-Wave1.png", as(png) replace

keep ID lfdn_w2 v_33_w1 vacc_w2
save "C:\Users\geisslef\_Work\04_Paper\Covid-19-Vaccination\Daten\Wave1\Wave1_2_Merged_for-PNAS--Intention.dta", replace



* ---------------------------------------------------------------------------- *

