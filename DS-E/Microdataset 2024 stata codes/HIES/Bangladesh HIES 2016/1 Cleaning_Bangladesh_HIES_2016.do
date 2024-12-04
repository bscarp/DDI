cd "C:\Users\Jaclyn Yap\Desktop\WB_2024\Bangladesh\Bangladesh\BGD_2016_HIES_v01_M_Stata\" 

**PREPARE DATASETS


** Note: some individual ID ==0 OR MORE THAN 20 are dropped. (since they are not in the ROSTER)


**SOCIAL PROTECTION - Household level
use "HH_SEC_1C.dta", clear
*more than one, enrolled indid  -> aggregate
*reocode other values to missing
* take minimum by hhid indid
drop if indid==.

clonevar social_prot_ind = s1cq01 //individual level
fre social_prot_ind 

recode social_prot_ind (0 4 7 = .)

collapse (min) social_prot_ind, by(hhid) 
unique hhid
rename social_prot_ind social_prot
tab social_prot
replace social_prot=0 if social_prot==2
tab social_prot,m

save "BD_social_prot", replace



*EDUCATION
use "HH_SEC_2A.dta", clear
drop if indid==.
unique hhid indid
*bys hhid indid: gen dup_ind = (_N>1) 
*bys hhid indid: gen dup_ind1 = (_n>1) 

keep hhid indid s2aq01 s2aq02 s2aq03 s2aq04 
save BD_temp_educvars, replace

use "HH_SEC_2B.dta", clear
drop if indid==.
unique hhid indid
*bys hhid indid: gen dup_ind = (_N>1) 
*bys hhid indid: gen dup_ind1 = (_n>1) 

merge 1:1 hhid indid using BD_temp_educvars, gen(merge_educvars)

/*

  Result                           # of obs.
    -----------------------------------------
    not matched                            29
        from master                         0  (_merge==1)
        from using                         29  (_merge==2)

    matched                           168,106  (_merge==3)
    -----------------------------------------
*/
save BD_education, replace


*Expenditure
*health expenditure
use HH_SEC_9D2.dta, clear

keep if s9d2q00 >=400 &  s9d2q00 <=413 | s9d2q00 >=420 & s9d2q00 <=434
gen health_exp_total_yr = s9d2q01
collapse (sum) health_exp_total_yr, by(hhid)
gen health_exp_total_month = health_exp_total_yr/ 12

merge 1:1 hhid using "poverty_indicators2016.dta", keepusing(fexp hsvalhh nfexp2 consexp2) gen(merge_expenditures)
*consexp2 Monthly expenditure  (food + nonfood) including predicted rents     for hhlds who didn't report rents

/*

      Result                           # of obs.
    -----------------------------------------
    not matched                         1,365
        from master                        64  (merge_expenditures==1)
        from using                      1,301  (merge_expenditures==2)

    matched                            44,513  (merge_expenditures==3)
    -----------------------------------------

*/

drop if merge_expenditures==2
gen health_exp_hh = health_exp_total_month/consexp2

su health_exp_hh,d

save BD_healthexpense, replace

*EMPLOYMENT
use "HH_SEC_4", clear
*activity 1 is assumed to be primary activity
unique hhid indid activity

/*
bys hhid indid: gen dup_ind = (_N>1) 
tab dup_ind
bro if dup_ind==1


sort hhid indid activity
bys hhid indid (s4aq08) : gen dup_ind1 = _n
sort hhid indid dup_ind1
*/
keep if activity==1
*(5,576 observations deleted)
save BD_labor, replace
bro hhid indid activity s4aq02 s4aq01a s4aq01b s4aq01c s4aq06 s4aq07 s4aq08 
**************

*SHOCK
use "HH_SEC_6B", clear
clonevar shock_any = s6bq02
collapse (min) shock_any, by(hhid)

save BD_shock, replace


*assets

use "HH_SEC_9E", clear

local asset_name = "ind_radio" 
local asset_code = 571
gen `asset_name' = cond(mi(s9eq00) | (mi(s9eq01b) & mi(s9eq01a)) , ., cond(s9eq00 == `asset_code' & s9eq01b == "X",1, 0))

local asset_name = "ind_tv" 
local asset_code = 582
gen `asset_name' = cond(mi(s9eq00) | (mi(s9eq01b) & mi(s9eq01a)) , ., cond(s9eq00 == `asset_code' & s9eq01b == "X",1, 0))


local asset_name = "ind_refrig" 
local asset_code = 577
gen `asset_name' = cond(mi(s9eq00) | (mi(s9eq01b) & mi(s9eq01a)) , ., cond(s9eq00 == `asset_code' & s9eq01b == "X",1, 0))


local asset_name = "ind_bike" 
local asset_code = 574
gen `asset_name' = cond(mi(s9eq00) | (mi(s9eq01b) & mi(s9eq01a)) , ., cond(s9eq00 == `asset_code' & s9eq01b == "X",1, 0))


local asset_name = "ind_motorcycle" 
local asset_code = 575
gen `asset_name' = cond(mi(s9eq00) | (mi(s9eq01b) & mi(s9eq01a)) , ., cond(s9eq00 == `asset_code' & s9eq01b == "X",1, 0))


local asset_name = "ind_autos" 
local asset_code = 576
gen `asset_name' = cond(mi(s9eq00) | (mi(s9eq01b) & mi(s9eq01a)) , ., cond(s9eq00 == `asset_code' & s9eq01b == "X",1, 0))


local asset_name = "ind_computer" 
local asset_code = 598
gen `asset_name' = cond(mi(s9eq00) | (mi(s9eq01b) & mi(s9eq01a)) , ., cond(s9eq00 == `asset_code' & s9eq01b == "X",1, 0))


local asset_name = "cell_new" 
local asset_code = 597
gen `asset_name' = cond(mi(s9eq00) | (mi(s9eq01b) & mi(s9eq01a)) , ., cond(s9eq00 == `asset_code' & s9eq01b == "X",1, 0))



collapse (max)  ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_autos ind_computer cell_new, by(hhid)
gen ind_phone = .

save BD_assets.dta, replace
