*******************************************************************************
*Globals 
********************************************************************************
clear
clear matrix
clear mata 
set maxvar 30000

global survey_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data
global clean_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Clean Data
global combined_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Combined Data
*******************************************************************
*Clean data and create indicators
*******************************************************************
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

local country_list KH
*PK ML HT KH SN ZA RW NG MR TL UG MV KE KH2 TZ NP

foreach country of local country_list  {
	
use "${survey_data}\\`country'_${`country'_SR}\\`country'_Individual.dta", clear

if v000=="PK7" {
replace v005 = sv005 if v000=="PK7"&(v024==7|v024==5)
}

tab v000

sort v001 v002 v003

gen gender="female"
gen female=1
rename v012 age

gen survey="DHS" 
gen survey_month=v006
gen survey_year=v007

decode v024, gen(Admin1)

*violence variables - 12months
**********************

if  v000 != "MV5" {

	*physical violence		
			
	gen	pushed_shook_thrown_12m		=	d105a
	replace pushed_shook_thrown_12m		 =0 if d105a==3|d105a==4
	
	gen	slapped_12m			=	d105b
	replace slapped_12m			=0 if 	d105b==3|d105b==4
	
	gen	punched_12m			=	d105c
	replace	punched_12m			=0 if 	d105c==3|d105c==4
	
	gen	kicked_12m			=	d105d
	replace	kicked_12m			=0 if 	d105d==3|d105d==4
	
	gen	strangled_12m			=	d105e
	replace	strangled_12m			=0 if 	d105e==3|d105e==4
	
	gen	threatened_weapon_12m			=	d105f
	replace	threatened_weapon_12m			=0 if 	d105f==3|d105f==4
	
	gen	ever_armhair_12m	=	d105j
	replace	ever_armhair_12m	=0 if 	d105j==3|d105j==4

	egen physviolence_byh2_12m	=rowmax(pushed_shook_thrown_12m slapped_12m punched_12m kicked_12m strangled_12m threatened_weapon_12m ever_armhair_12m)
	
	egen physviolence_byh_12m=rowmax(pushed_shook_thrown_12m slapped_12m punched_12m kicked_12m strangled_12m threatened_weapon_12m ever_armhair_12m )
	recode physviolence_byh_12m (1 2 = 1)
/*	
	replace physviolence_byh_12m=1 if d130a==1
*/	
	lab var physviolence_byh_12m "experience physcial violence last 12 months"		
	
*sexual violence					
	gen	ever_forcedsex_husb_12m		=	d105h
	replace ever_forcedsex_husb_12m	=0 if d105h==3|d105h==4
	
	gen	ever_forcedsexualacts_husb_12m		=	d105i
	replace ever_forcedsexualacts_husb_12m =0 if d105i==3|d105i==4
	
	gen	ever_phforcedsexualacts_husb_12m		=	d105k
	replace ever_phforcedsexualacts_husb_12m		=0 if	d105k==3|d105k==4
	
	*gen	ever_anysexviolence_husb_12m		=	d108
	
	gen sexviolence_byh_12m=0 if ever_forcedsex_husb_12m!=. |  ever_forcedsexualacts_husb_12m!=.|ever_phforcedsexualacts_husb_12m!=.
	replace sexviolence_byh_12m=1 if inlist(ever_forcedsex_husb_12m,1, 2) | inlist(ever_forcedsexualacts_husb_12m,1, 2)  | inlist(ever_phforcedsexualacts_husb_12m,1, 2) 
	
	recode sexviolence_byh_12m (1 2 = 1)
/*
	replace sexviolence_byh_12m=1 if d130b==1
*/	
	lab var sexviolence_byh_12m "experience sexual violence last 12 months"		
	
*emotional violence 					
	gen	humiliated_bypartner_12m		=	d103a
	replace humiliated_bypartner_12m	=0 if d103a==3|d103a==4
	
	gen	threatened_bypartner_12m		=	d103b
	replace threatened_bypartner_12m =0 if d103b==3|d103b==4

	
	gen	insulted_bypartner_12m		=	d103c
	replace insulted_bypartner_12m	=0 if d103c==3|d103c==4
	
	
	*gen	anyemotionalviolence_12m		=	d104
	
	*gen anyemotionalviolence2_12m=cond(humiliated_bypartner==.&threatened_bypartner==.&insulted_bypartner==.,.,cond(inrange(humiliated_bypartner,1,3)|inrange(threatened_bypartner,1,3)|inrange(insulted_bypartner,1,3),1,0))

	egen emotionalviolence_byh2_12m	=rowmax(humiliated_bypartner_12m threatened_bypartner_12m insulted_bypartner_12m)
	egen emotionalviolence_byh_12m=rowmax(humiliated_bypartner_12m threatened_bypartner_12m insulted_bypartner_12m)
	recode emotionalviolence_byh_12m (1 2 = 1)
/*	
	if v000 !="KH6" & v000 !="UG7" {
	replace emotionalviolence_byh_12m=1 if d130c==1
	}
*/	
	lab var emotionalviolence_byh_12m "experience emotional violence last 12 months"
	
*any violence 		
	gen anyviolence_byh_12m=0 if sexviolence_byh_12m!=. |  physviolence_byh_12m!=. | emotionalviolence_byh_12m!=.
	replace anyviolence_byh_12m=1 if sexviolence_byh_12m==1 |  physviolence_byh_12m==1 | emotionalviolence_byh_12m==1
	
	gen anyviolence_byh2_12m=0 if sexviolence_byh_12m!=. |  physviolence_byh_12m!=. 
	replace anyviolence_byh2_12m=1 if sexviolence_byh_12m==1 |  physviolence_byh_12m==1 
	
	lab var anyviolence_byh_12m "experience any violence last 12 months"
	lab var anyviolence_byh2_12m "experience any sexual or physical violence last 12 months"
}


*********************
//Demand satisfied by modern methods

gen fp_demsat_mod = 0
if v000 != "MV5" {
replace fp_demsat_mod = 1 if (v626a==3 | v626a==4) & v313==3
replace fp_demsat_mod=. if inlist(v626a,0,7,8,9) /*eliminate no need from denominator*/
} 

if v000 == "MV5" {
replace fp_demsat_mod = 1 if (v624==3 | v624==4) & v313==3 //Maldives
replace fp_demsat_mod=. if inlist(v624,0,7,8,9) /*eliminate no need from denominator*/
}

label var fp_demsat_mod "H3_Family_planning"

*********************
//Internet Use
if v000 !="KH6"&v000!="MV5" {
gen internet =  v171a 
recode internet (0 2 3 = 0)
}

if v000 =="KH6" {
	gen internet = 1 if (s112a==1|s112a==2)
	replace  internet = 0 if (s112a==0)
}

if v000 =="MV5" {
gen internet =  s109 
recode internet (1 2 3 = 1)
}

la var internet "Individual uses internet"

save "${clean_data}//`country'_${`country'_SR}_Women_Updated.dta", replace
}

