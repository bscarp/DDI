********************************************************************************
*Globals 
********************************************************************************
clear
clear matrix
clear mata 
set maxvar 30000

global survey_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data
global clean_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Clean Data
global combined_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Combined Data

********************************************************************************
*Household Member: Create Indicators and Clean data
*Household Member DHS survey has information on disability status
********************************************************************************
global PK_SR 2017_2018
global ML_SR 2018
global MV_SR 2009
global HT_SR 2016_2017
global KH_SR 2014
global SN_SR 2018
global ZA_SR 2016
global RW_SR 2019_2020
global NG_SR 2018 
global MR_SR 2019_2021
global TL_SR 2016
global UG_SR 2016
global KE_SR 2022
global KH2_SR 2021_2022
global TZ_SR 2022
global NP_SR 2022

local country_list PK ML HT KH SN ZA RW NG MR TL UG MV KE KH2 TZ NP

foreach country of local country_list  {
		
use "${survey_data}\\`country'_${`country'_SR}\\`country'_Household Member.dta", clear

ta hv000
********************************************************************************
*Clean geographic and socio-demographic data
********************************************************************************
*Create country name
gen country_name="Pakistan" if hv000=="PK7"
replace country_name="Mali" if hv000=="ML7"
replace country_name="Haiti" if hv000=="HT7"
replace country_name="Cambodia" if hv000=="KH6"
replace country_name="Cambodia2" if hv000=="KH8"
replace country_name="Kenya" if hv000=="KE8"
replace country_name="Senegal" if hv000=="SN7"
replace country_name="South Africa" if hv000=="ZA7"
replace country_name="Rwanda" if hv000=="RW7"
replace country_name="Nigeria" if hv000=="NG7"
replace country_name="Timor-Leste" if hv000=="TL7"
replace country_name="Uganda" if hv000=="UG7"
replace country_name="Maldives" if hv000=="MV5"
replace country_name="Mauritania" if hv000=="MR7"
replace country_name="Tanzania" if hv000=="TZ8"
replace country_name="Nepal" if hv000=="NP8"

lab var country_name "Country name"
gen country_dataset_year = country_name + "_${`country'_SR}"
la var country_dataset_year "Country Data and year"

rename hhid hh_id
la var hh_id "Household ID"

tostring hvidx, gen(person_num)

gen ind_id = hh_id + " " + person_num
la var ind_id "Individual ID"
drop person_num

*Generate region name
decode hv024, gen(admin1)
lab var admin1 "Admin 1 level"

if hv000!="KH8" {
decode hv022, gen(sample_strata)
}
else {
gen sample_strata = hv022
}

if hv000 == "SN7" {
	decode shzone, gen(region_SN)
	replace admin1=region_SN
}

rename hv104 sex_new
lab var sex_new "sex 1 for male sex 2 for female"

gen female = 1 if sex_new==2
replace female = 0 if sex_new==1
lab var female "Female or Male"


*Rename demographic variables and clean missing values
rename hv105 age
recode age (98=.)

drop if age<15 
la var age "Age"

*Age group
gen age_group_label= "15-29" if age>14&age<30
replace age_group_label= "30-44" if age>29&age<45
replace age_group_label= "45-64" if age>44&age<65
replace age_group_label= "65+" if age>64|age==95

gen age_group= 1 if age>14&age<30
replace age_group= 2 if age>29&age<45
replace age_group= 3 if age>44&age<65
replace age_group= 4 if age>64|age==95
la var age_group "Age Group"

gen urban_new = 1 if hv025==1
replace urban_new =0 if hv025==2
lab var urban_new "Urban or Rural"

*Rename education variables and clean missing values
rename hv106 highest_educ_level
recode highest_educ_level (8 98=.)
rename hv107 higehst_educ_yr
recode higehst_educ_yr (98=.)
rename hv108 educ_yrs
recode educ_yrs (98=.)
rename hv109 educ_attainment
recode educ_attainment (8 98=.)

*Education - atleast primary
gen ind_atleastprimary=1 if educ_attainment==2|educ_attainment==3|educ_attainment==4|educ_attainment==5
replace ind_atleastprimary=0 if educ_attainment==0|educ_attainment==1
replace ind_atleastprimary=. if educ_attainment==8|educ_attainment==.
replace ind_atleastprimary=. if age<25
lab var ind_atleastprimary "Primary school completion or higher adults 25+"

*Education - atleast primary - all
gen ind_atleastprimary_all=1 if educ_attainment==2|educ_attainment==3|educ_attainment==4|educ_attainment==5
replace ind_atleastprimary_all=0 if educ_attainment==0|educ_attainment==1
replace ind_atleastprimary_all=. if educ_attainment==8|educ_attainment==.
lab var ind_atleastprimary_all "Primary school completion or higher adults 15+"

*Education - completed at least secondary school
gen ind_atleastsecondary=1 if educ_attainment==4|educ_attainment==5
replace ind_atleastsecondary=0 if educ_attainment==0|educ_attainment==1|educ_attainment==2|educ_attainment==3
replace ind_atleastsecondary=. if educ_attainment==8|educ_attainment==.
replace ind_atleastsecondary=. if age<25
lab var ind_atleastsecondary "Upper secondary school completion or higher"

*Ever attended school
gen everattended_new =1 if educ_yrs>0
replace everattended_new  =0 if educ_yrs==0
replace everattended_new  =. if educ_yrs==98
lab var everattended_new "Ever attended school"

gen  edattain_new=educ_attainment
recode edattain_new (0 1 =1) (2 3 =2) (4 =3) (5= 4)
lab var  edattain_new "1 Less than Prim 2 Prim 3 Sec 4 Higher"

gen v001 = hv001
gen v002 = hv002
gen v003 = hvidx

sort v001 v002 v003

label var v001 "cluster number"
label var v002 "household number"
label var v003 "respondent's line number"

gen v000=hv000

gen survey_month=hv006
gen survey_year=hv007
********************************************************************************
*Clean data on functional difficulties
********************************************************************************
if  hv000 == "KH6" {

forvalues x= 1/6 {
gen sh2`x'_recode=1 if sh2`x' ==0
replace sh2`x'_recode=2 if sh2`x' ==1
replace sh2`x'_recode=3 if sh2`x' ==2
replace sh2`x'_recode=4 if sh2`x' ==3
*replace sh2`x'_recode=. if sh2`x' ==.|sh2`x' ==8
}

*Glasses -n/a
gen hdis1 = .
*Seeing Difficulty
gen hdis2 = sh21_recode
*Hearing Aid - n/a
gen hdis3 = .
*Hearing Difficulty
gen hdis4 = sh22_recode
*Difficulty Communicating
gen hdis5 = sh26_recode
*Difficulty Remembering or Concentrating
gen hdis6 = sh24_recode
*Difficulty Walking or Climbing Steps
gen hdis7 = sh23_recode
*Difficulty Washing All Over or Dressing
gen hdis8 = sh25_recode

local domain_list hdis2 hdis4 hdis5 hdis6 hdis7 hdis8
foreach var of local domain_list {
	replace `var'=. if `var'==8
}
*Max difficulty in any one domain
egen hdis9=rowmax(hdis2 hdis4 hdis5 hdis6 hdis7 hdis8)
replace hdis9=. if hdis2==.&hdis4==.& hdis5==.& hdis6==.& hdis7==.&hdis8 ==.

lab var hdis2 "Difficulty Seeing"
lab var hdis4 "Difficulty Hearing"
lab var hdis5 "Difficulty Communicating" 
lab var hdis6 "Difficulty Remembering or Concentrating"
lab var hdis7 "Difficulty Walking or Climbing Steps"
lab var hdis8 "Difficulty Washing All Over or Dressing"
lab var hdis9 "Difficulty Any Domain"

}

if  hv000 == "SN7" {

*Glasses
gen hdis1 = sh20ga
*Seeing Difficulty
gen hdis2 = sh20gc if sh20ga==0
replace hdis2 = sh20gb if sh20ga==1
*Hearing Aid
gen hdis3 = sh20gd
*Hearing Difficulty
gen hdis4 = sh20gf if sh20gd==0
replace hdis4 = sh20ge if sh20gd==1
*Difficulty Communicating
gen hdis5 = sh20gg
*Difficulty Remembering or Concentrating
gen hdis6 = sh20gh
*Difficulty Walking or Climbing Steps
gen hdis7 = sh20gi
*Difficulty Washing All Over or Dressing
gen hdis8 = sh20gj

local domain_list hdis2 hdis4 hdis5 hdis6 hdis7 hdis8
foreach var of local domain_list {
	replace `var'=. if `var'==8
}
*Max difficulty in any one domain
egen hdis9=rowmax(hdis2 hdis4 hdis5 hdis6 hdis7 hdis8)
replace hdis9=. if hdis2==.&hdis4==.& hdis5==.& hdis6==.& hdis7==.&hdis8 ==.

lab var hdis2 "Difficulty Seeing"
lab var hdis4 "Difficulty Hearing"
lab var hdis5 "Difficulty Communicating" 
lab var hdis6 "Difficulty Remembering or Concentrating"
lab var hdis7 "Difficulty Walking or Climbing Steps"
lab var hdis8 "Difficulty Washing All Over or Dressing"
lab var hdis9 "Difficulty Any Domain"

}

if  hv000 == "MV5" {

forvalues x= 4/9 {
gen sh2`x'_recode= sh2`x'
replace sh2`x'_recode=1 if sh2`x' ==0
*replace sh2`x'_recode=. if sh2`x' ==.|sh2`x' ==8
}


*Glases - n/a
gen hdis1 =.
*Seeing Difficulty
gen hdis2 = sh24_recode
*Hearing Aid - n/a
gen hdis3 =.
*Hearing Difficulty
gen hdis4 = sh25_recode
*Difficulty Communicating
gen hdis5 = sh26_recode
*Difficulty Remembering or Concentrating
gen hdis6 = sh27_recode
*Difficulty Walking or Climbing Steps
gen hdis7 = sh28_recode
*Difficulty Washing All Over or Dressing
gen hdis8 = sh29_recode

local domain_list hdis2 hdis4 hdis5 hdis6 hdis7 hdis8
foreach var of local domain_list {
	replace `var'=. if `var'==8
}
*Max difficulty in any one domain
egen hdis9=rowmax(hdis2 hdis4 hdis5 hdis6 hdis7 hdis8)
replace hdis9=. if hdis2==.&hdis4==.& hdis5==.& hdis6==.& hdis7==.&hdis8 ==.

lab var hdis2 "Difficulty Seeing"
lab var hdis4 "Difficulty Hearing"
lab var hdis5 "Difficulty Communicating" 
lab var hdis6 "Difficulty Remembering or Concentrating"
lab var hdis7 "Difficulty Walking or Climbing Steps"
lab var hdis8 "Difficulty Washing All Over or Dressing"
lab var hdis9 "Difficulty Any Domain"
}


if  hv000 == "UG7" {

*Glases 
gen hdis1 = sh23
*Seeing Difficulty
gen hdis2 = sh24 if sh23==1
replace hdis2 = sh25 if sh23==0
*Hearing Aid 
gen hdis3 = sh26
*Hearing Difficulty
gen hdis4 = sh27 if sh26==1
replace hdis4 = sh28 if sh26==0
*Difficulty Communicating
gen hdis5 = sh29
*Difficulty Remembering or Concentrating
gen hdis6 = sh30
*Difficulty Walking or Climbing Steps
gen hdis7 = sh31
*Difficulty Washing All Over or Dressing
gen hdis8 = sh32

local domain_list hdis2 hdis4 hdis5 hdis6 hdis7 hdis8
foreach var of local domain_list {
	replace `var'=. if `var'==8
}
*Max difficulty in any one domain
egen hdis9=rowmax(hdis2 hdis4 hdis5 hdis6 hdis7 hdis8)
replace hdis9=. if hdis2==.&hdis4==.& hdis5==.& hdis6==.& hdis7==.&hdis8 ==.

lab var hdis2 "Difficulty Seeing"
lab var hdis4 "Difficulty Hearing"
lab var hdis5 "Difficulty Communicating" 
lab var hdis6 "Difficulty Remembering or Concentrating"
lab var hdis7 "Difficulty Walking or Climbing Steps"
lab var hdis8 "Difficulty Washing All Over or Dressing"
lab var hdis9 "Difficulty Any Domain"
}


*Disability - Threshold three (DISABILITY3: the level of inclusion is any 1 domain/question is coded A LOT OF DIFFICULTY or CANNOT DO AT ALL)
*NOTE: DISABILITY3 IS THE CUT-OFF RECOMMENDED BY THE WG.

local domain_list hdis2 hdis4 hdis5 hdis6 hdis7 hdis8
foreach var of local domain_list {
	replace `var'=. if `var'==8
}

*Max difficulty in any one domain
egen hdis10=rowmax(hdis2 hdis4 hdis5 hdis6 hdis7 hdis8)
replace hdis10=. if hdis2==.&hdis4==.& hdis5==.& hdis6==.& hdis7==.&hdis8 ==.
replace hdis9 =hdis10

*Any difficulty in any domain indicator
gen any_difficulty = 1 if hdis9>1
replace any_difficulty = 0 if hdis9==1
replace any_difficulty = . if hdis9==.

*Some difficulty in any domain  indicator
gen some_difficulty = 1 if hdis9==2
replace some_difficulty = 0 if hdis9!=2
replace some_difficulty = . if hdis9==.

*At least a lot of difficulty in any domain indicator
gen atleast_alot_difficulty = 1 if hdis9>=3
replace atleast_alot_difficulty = 0 if hdis9<=2
replace atleast_alot_difficulty = . if hdis9==.

*No difficulty in any domain indicator
gen no_difficulty=1 if hdis9==1
replace no_difficulty = 0 if hdis9>1
replace no_difficulty = . if hdis9==.

*Any difficulty for each domain
forvalues x= 2/9 {
	gen hdis`x'_any = 1 if hdis`x'>1 
	replace hdis`x'_any = 0 if hdis`x'==1 
	replace hdis`x'_any = . if hdis`x'==.
}
 
lab var hdis2_any "Any Difficulty Seeing"
lab var hdis4_any "Any Difficulty Hearing"
lab var hdis5_any "Any Difficulty Communicating" 
lab var hdis6_any "Any Difficulty Remembering or Concentrating"
lab var hdis7_any "Any Difficulty Walking or Climbing Steps"
lab var hdis8_any "Any Difficulty Washing All Over or Dressing"
lab var hdis9_any "Any Difficulty in Any Domain"

*Some difficulty for each domain
forvalues x= 2/9 {
	gen hdis`x'_some = 1 if hdis`x'==2
	replace hdis`x'_some = 0 if hdis`x'!=2 
	replace hdis`x'_some = . if hdis`x'==.
}
 
lab var hdis2_some "Some Difficulty Seeing"
lab var hdis4_some "Some Difficulty Hearing"
lab var hdis5_some "Some Difficulty Communicating" 
lab var hdis6_some "Some Difficulty Remembering or Concentrating"
lab var hdis7_some "Some Difficulty Walking or Climbing Steps"
lab var hdis8_some "Some Difficulty Washing All Over or Dressing"
lab var hdis9_some "Some Difficulty Washing in Any Domain"

*At least a lot of difficulty for each domain
forvalues x= 2/9 {
	gen hdis`x'_atleast_alot = 1 if hdis`x'>=3
	replace hdis`x'_atleast_alot = 0 if hdis`x'<=2 
	replace hdis`x'_atleast_alot = . if hdis`x'==.
}
 
lab var hdis2_atleast_alot "Atleast a lot of Difficulty Seeing"
lab var hdis4_atleast_alot "Atleast a lot of Difficulty Hearing"
lab var hdis5_atleast_alot "Atleast a lot of Difficulty Communicating" 
lab var hdis6_atleast_alot "Atleast a lot of Difficulty Remembering or Concentrating"
lab var hdis7_atleast_alot "Atleast a lot of Difficulty Walking or Climbing Steps"
lab var hdis8_atleast_alot "Atleast a lot of Difficulty Washing All Over or Dressing"
lab var hdis9_atleast_alot "Atleast a lot of Difficulty in Any Domain"

*No difficulty for each domain
forvalues x= 2/9 {
	gen hdis`x'_none = 1 if hdis`x'==1
	replace hdis`x'_none = 0 if hdis`x'>1
	replace hdis`x'_none = . if hdis`x'==.
}
 
lab var hdis2_none "No Difficulty Seeing"
lab var hdis4_none "No Difficulty Hearing"
lab var hdis5_none "No Difficulty Communicating" 
lab var hdis6_none "No Difficulty Remembering or Concentrating"
lab var hdis7_none "No Difficulty Walking or Climbing Steps"
lab var hdis8_none "No Difficulty Washing All Over or Dressing"
lab var hdis9_none "No Difficulty in Any Domain"

*Household level Disability Threshold 3
egen func_difficulty_hh=max(hdis9), by(hh_id)
lab var func_difficulty_hh "Max Difficulty in HH"

gen disability_any_hh=1 if func_difficulty_hh>1
replace disability_any_hh=0 if func_difficulty_hh==1
replace disability_any_hh=. if func_difficulty_hh==.

lab var disability_any_hh "P3 Any difficulty in Any Domain for any adult in the hh"

gen disability_some_hh=1 if func_difficulty_hh==2
replace disability_some_hh=0 if func_difficulty_hh!=2
replace disability_some_hh=. if func_difficulty_hh==.

lab var disability_some_hh "P3 Some difficulty in Any Domain for any adult in the hh"

gen disability_atleast_hh=1 if func_difficulty_hh>2
replace disability_atleast_hh=0 if func_difficulty_hh<3
replace disability_atleast_hh=. if func_difficulty_hh==.

lab var disability_atleast_hh "P3 At least a lot of difficulty in Any Domain for any adult in the hh"


if hv000!="PK7" {
	gen shv005=.
}

gen hh_resp = (hv003==hvidx)
gen hh_resp_female_track = (sex_new==2) if hh_resp==1
egen hh_resp_female = max(hh_resp_female_track), by(hv001 hv002)

gen hh_resp_age_track = age if hh_resp==1
replace hh_resp_age_track = -999999 if hh_resp==0
replace hh_resp_age_track = -999999 if age==.
egen hh_resp_age = max(hh_resp_age_track), by(hv001 hv002)

gen hh_resp_educ_track = edattain_new if hh_resp==1
replace hh_resp_educ_track = -999999 if hh_resp==0
replace hh_resp_educ_track = -999999 if edattain_new==.
egen hh_resp_educ = max(hh_resp_educ_track), by(hv001 hv002)

keep shv005 sample_strata hv021 hv000 hv001 idxh4 hv006 hv016 hv007 hvidx v000 v001 v002 v003 v000 hv005 hv024 hv121 hv218 admin1 hdis1 hdis2 hdis3 hdis4 hdis5 hdis6 hdis7 hdis8 hdis9 func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh hv206 hv207 hv208 hv221 hv243a hdis2_any hdis4_any hdis5_any hdis6_any hdis7_any hdis8_any hdis9_any hdis2_some hdis4_some hdis5_some hdis6_some hdis7_some hdis8_some hdis9_some hdis2_atleast_alot hdis4_atleast_alot hdis5_atleast_alot hdis6_atleast_alot hdis7_atleast_alot hdis8_atleast_alot hdis9_atleast_alot country_name country_dataset_year admin1 female sex_new age age_group_label age_group urban_new everattended_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary hv002 hv027 hh_id ind_id hh_resp hh_resp_female hh_resp_age hh_resp_educ

gen survey ="DHS"

replace hdis2 =. if hdis2==8|hdis2==9

forvalues x = 4/8 {
	replace hdis`x'=. if hdis`x'==8|hdis`x'==9
}

replace hdis9=. if hdis2==.&hdis4==.& hdis5==.& hdis6==.& hdis7==.&hdis8 ==.
********************************************************************************
rename hdis1 wears_glasses
rename hdis3 wears_hearingaid

rename hdis2_any seeing_any
rename hdis4_any hearing_any
rename hdis5_any communicating_any
rename hdis6_any cognition_any
rename hdis7_any mobile_any
rename hdis8_any selfcare_any
rename hdis9_any disability_any

rename hdis2_some seeing_some
rename hdis4_some hearing_some
rename hdis5_some communicating_some
rename hdis6_some cognition_some
rename hdis7_some mobile_some
rename hdis8_some selfcare_some
rename hdis9_some disability_some

rename hdis2_atleast seeing_atleast_alot
rename hdis4_atleast hearing_atleast_alot
rename hdis5_atleast communicating_atleast_alot
rename hdis6_atleast cognition_atleast_alot
rename hdis7_atleast mobile_atleast_alot
rename hdis8_atleast selfcare_atleast_alot
rename hdis9_atleast disability_atleast

lab var seeing_any "Any Difficulty in seeing"
lab var hearing_any "Any Difficulty in hearing"
lab var communicating_any "Any Difficulty in communicating" 
lab var cognition_any "Any Difficulty in cognition"
lab var mobile_any "Any Difficulty in walking"
lab var selfcare_any "Any Difficulty in selfcare"
lab var disability_any "Any Difficulty in Any Domain"

lab var seeing_some "Some Difficulty in seeing"
lab var hearing_some "Some Difficulty in hearing"
lab var communicating_some "Some Difficulty in communicating" 
lab var cognition_some "Some Difficulty in cognition"
lab var mobile_some "Some Difficulty in walking"
lab var selfcare_some "Some Difficulty in selfcare"
lab var disability_some "Some Difficulty Washing in Any Domain"

lab var seeing_atleast_alot "Atleast a lot of Difficulty in seeing"
lab var hearing_atleast_alot "Atleast a lot of Difficulty in hearing"
lab var communicating_atleast_alot "Atleast a lot of Difficulty in communicating" 
lab var cognition_atleast_alot "Atleast a lot of Difficulty in cognition"
lab var mobile_atleast_alot "Atleast a lot of Difficulty in walking"
lab var selfcare_atleast_alot "Atleast a lot of Difficulty in selfcare"
lab var disability_atleast "Atleast a lot of Difficulty in Any Domain"

rename hdis2 seeing_diff_new
la var seeing_diff_new "Difficulty in seeing"
rename hdis4 hearing_diff_new
la var hearing_diff_new "Difficulty in hearing"
rename hdis5 comm_diff_new
la var comm_diff_new "Difficulty in communicating"
rename hdis6 cognitive_diff_new
la var cognitive_diff_new "Difficulty in cognition"
rename hdis7 mobility_diff_new
la var mobility_diff_new "Difficulty in walking"
rename hdis8 selfcare_diff_new
la var selfcare_diff_new "Difficulty in selfcare"
rename hdis9 func_difficulty
la var func_difficulty "Difficulty in Any Domain"

*Create sample weight
gen ind_weight=hv005/1000000
replace ind_weight=shv005/1000000 if hv000=="PK7"&(hv024==5|hv024==7)
lab var ind_weight "Individual Sample weight"

save "${clean_data}//`country'_${`country'_SR}_Household_Member_Updated.dta", replace
}