/*******************************************************************************
******************Afghanistan LCS 2016 ********************************************
********************************************************************************
Author: Jaclyn Yap
Reference: DSE
Website:
*******************************************************************************/

***Clean do file for Health Expenditure and Variable generations********

global RAW "G:\My Drive\4 Census\Datasets_confidentiality\Afghanistan\ALCS\AFG_2016_LCS_v01_M_STATA\AFG_2016_LCS_v01_M_STATA"
global PATH "C:\Users\Jaclyn Yap\Desktop\WB_2024\Afghanistan_LCS\"
cd "$RAW"


use hh_id q_9* using "h_04_10.dta", clear

egen expense1_month =rowtotal(q_9_01-q_9_21)

bro q_9_22 - q_9_40
egen expense2_yr = rowtotal(q_9_22 - q_9_38)
gen expense2_month = expense2_yr/ 12

gen disability_expense_month = (q_9_39 + q_9_40) /12 // hearing aids, canes ,prescription glasses

egen hospitalization_yr = rowtotal(q_9_47_a_1 q_9_47_a_2 q_9_47_a_3 q_9_47_a_4 q_9_47_a_5  q_9_47_a_6  q_9_47_b_1 q_9_47_b_2 q_9_47_b_3 q_9_47_b_4 q_9_47_b_5 q_9_47_b_6  q_9_47_c_1 q_9_47_c_2 q_9_47_c_3 q_9_47_c_4 q_9_47_c_5 q_9_47_c_6)

gen hospitalization_month = hospitalization_yr/ 12

egen outpatient_month = rowtotal( q_9_57_a_1 q_9_57_a_2 q_9_57_a_3 q_9_57_a_4 q_9_57_a_5 q_9_57_a_6  q_9_57_b_1 q_9_57_b_2 q_9_57_b_3 q_9_57_b_4 q_9_57_b_5 q_9_57_b_6  q_9_57_c_1 q_9_57_c_2 q_9_57_c_3 q_9_57_c_4 q_9_57_c_5 q_9_57_c_6 )

egen medicine_month = rowtotal(q_9_64_a q_9_64_b q_9_64_c)


gen total_expense_month = expense1_month + expense2_month + disability_expense_month + hospitalization_month + outpatient_month + medicine_month
gen health_expense_month = disability_expense_month + hospitalization_month + outpatient_month + medicine_month

gen health_exp_hh = health_expense_month / total_expense_month
replace health_exp_hh = 0 if health_expense_month==.

save "$PATH/Afganistan_expenditures.dta", replace
