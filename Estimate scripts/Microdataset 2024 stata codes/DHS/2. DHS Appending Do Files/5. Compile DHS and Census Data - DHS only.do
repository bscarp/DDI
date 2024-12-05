/*******************************************************************************
********************************DHS*********************************************
********************************************************************************
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/
Reference to appendix and paper:
For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).
Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, GVS, Pinilla-Roncancio, M.,  Rivas Velarde, M., Teodoro, D.,  and Mitra, S. (2024). The Disability Statistics – Estimates Database: an innovative database of internationally comparable statistics on disability inequalities. International Journal of Population Data Science.
Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com
Author: Katherine Theiss
Suggested citation: DDI. Disability Statistics Database - Estimates (DS-E Database)). Disability Data Initiative collective. Fordham University: New York, USA. 2024.
*******************************************************************************/
********************************************************************************
*Globals 
********************************************************************************
global survey_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data
global clean_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Clean Data
global combined_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Combined Data
global tonga_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\Cleaning Do-files\5. TON_PHC_2016\Datasets\2023 Report Clean Data

cd "\\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\Cleaning Do-files\8. World Bank Collaboration\Output - Spring 2024"

*Append individual level data
********************************************************************************
use "${combined_data}\\DHS_Cross_Country_Data.dta", clear

*append using "${tonga_data}\Tonga_Cleaned_Individual_Data_Trimmed.dta", force

la var admin2 "Admin 2 level"
la var psu "PSU"
la var school_new "Currently attending school"
la var edattain_new "Educational Attainment"
la var computer "Individual uses computer"
la var youth_idle "Individual uses computer"
la var work_manufacturing "In manufacturing"
la var work_managerial "Women in managerial position"
la var work_informal "Informal work"
la var fp_demsat_mod "Women with family planning needs met"
la var health_insurance "Adults with a health insurance coverage"
la var social_prot "Adults in households receiving social protection"
la var food_insecure "Adults in food insecure households"
la var shock_any "Adults in households that experienced a shock recently"
la var health_exp_hh "Household health expenditures out of total consumption expenditures"
la var dv_weight "DHS Domestic Violence sample weight"
la var ind2_weight "DHS Individual sample weight"

*Change DHS individual survey variables to missing for individuals ages above 45
replace ind_emp=. if age>=45
replace lit_new=. if age>=45
replace internet=. if age>=45
replace mobile_own=. if age>=45
replace fp_demsat_mod=. if age>=45
replace anyviolence_byh_12m=. if age>=45

replace admin1 = "azad jammu and Kashmir" if admin1=="ajk"&country_abrev=="PK"
replace admin1 = "gilgit baltistan" if admin1=="gb"&country_abrev=="PK"
replace admin1 = "islamabad capital territory" if admin1=="ict"&country_abrev=="PK"
replace admin1 = "khyber pakhtunkhwa" if admin1=="kpk"&country_abrev=="PK"
replace admin1 = "federally administered tribal areas" if admin1=="fata"&country_abrev=="PK"

save "${combined_data}\Final_Individual_DHS_only.dta", replace

*Append household level data
********************************************************************************
use "${combined_data}\\DHS_Cross_Country_HH_Data.dta", clear

*append using "${tonga_data}\Tonga_Cleaned_Household_Level_Data_Trimmed.dta", force

la var admin2 "Admin 2 level"
la var psu "PSU"
la var school_new "Currently attending school"
la var edattain_new "Educational Attainment"
la var computer "Individual uses computer"
la var youth_idle "Individual uses computer"
la var work_manufacturing "In manufacturing"
la var work_managerial "Women in managerial position"
la var work_informal "Informal work"
la var fp_demsat_mod "Women with family planning needs met"
la var health_insurance "Adults with a health insurance coverage"
la var social_prot "Adults in households receiving social protection"
la var food_insecure "Adults in food insecure households"
la var shock_any "Adults in households that experienced a shock recently"
la var health_exp_hh "Household health expenditures out of total consumption expenditures"
la var dv_weight "DHS Domestic Violence sample weight"
la var ind2_weight "DHS Individual sample weight"

*Change DHS individual survey variables to missing for individuals ages above 45
replace ind_emp=. if age>=45
replace lit_new=. if age>=45
replace internet=. if age>=45
replace mobile_own=. if age>=45
replace fp_demsat_mod=. if age>=45
replace anyviolence_byh_12m=. if age>=45

replace admin1 = "azad jammu and Kashmir" if admin1=="ajk"&country_abrev=="PK"
replace admin1 = "gilgit baltistan" if admin1=="gb"&country_abrev=="PK"
replace admin1 = "islamabad capital territory" if admin1=="ict"&country_abrev=="PK"
replace admin1 = "khyber pakhtunkhwa" if admin1=="kpk"&country_abrev=="PK"
replace admin1 = "federally administered tribal areas" if admin1=="fata"&country_abrev=="PK"

save "${combined_data}\Final_Household_DHS_only.dta", replace
