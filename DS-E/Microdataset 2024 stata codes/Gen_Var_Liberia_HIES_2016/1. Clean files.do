/*******************************************************************************
******************Liberia HIES 2016 ********************************************
********************************************************************************
Author: Jaclyn Yap
Reference: DSE
Website:
*******************************************************************************/

*Clean and reshape datasets for merging


*shock - needs to be collapsed before merging 
use HH_Q.dta, clear
 unique hhid hh_q_00 //shock id 
bys hhid: egen shock_any = min(hh_q_01_2)
collapse (min) shock_any , by(hhid)
replace shock_any = 0 if shock_any == 2

save LR_HIES_shocks.dta, replace


use HH_M.dta, clear
*hhid hh_m_00
*assets - need to be collapsed to include only relevant assets
*tracks count of the asset hh_m_01_2 - this converts it to a binary
local asset_name = "ind_radio"
local asset_number = 401
gen `asset_name' = cond(mi(hh_m_00) | mi(hh_m_01_2)  , ., cond(hh_m_00 == `asset_number' & hh_m_01_2 > 0 & hh_m_01_2 < .,1, 0))

 
*ind_tv	=1  =0
local asset_name = "ind_tv"
local asset_number = 405
gen `asset_name' = cond(mi(hh_m_00) | mi(hh_m_01_2)  , ., cond(hh_m_00 == `asset_number' & hh_m_01_2 > 0 & hh_m_01_2 < .,1, 0))

*ind_bike	=1 =0
local asset_name = "ind_bike"
local asset_number = 425
gen `asset_name' = cond(mi(hh_m_00) | mi(hh_m_01_2)  , ., cond(hh_m_00 == `asset_number' & hh_m_01_2 > 0 & hh_m_01_2 < .,1, 0))

*ind_motorcycle	=1 =0
local asset_name = "ind_motorcycle"
local asset_number = 424
gen `asset_name' = cond(mi(hh_m_00) | mi(hh_m_01_2)  , ., cond(hh_m_00 == `asset_number' & hh_m_01_2 > 0 & hh_m_01_2 < .,1, 0))

*ind_phone=1 with phone (telephone) =0 
*question on telephone and mobile is the same. for this, will skip telephone (mobile) and assign to mobile/cell instead
gen ind_phone= .

*ind_refrig	=1 =0
local asset_name = "ind_refrig"
local asset_number = 403
gen `asset_name' = cond(mi(hh_m_00) | mi(hh_m_01_2)  , ., cond(hh_m_00 == `asset_number' & hh_m_01_2 > 0 & hh_m_01_2 < .,1, 0))

*cell_new 	=1 =0
local asset_name = "cell_new"
local asset_number = 402
gen `asset_name' = cond(mi(hh_m_00) | mi(hh_m_01_2)  , ., cond(hh_m_00 == `asset_number' & hh_m_01_2 > 0 & hh_m_01_2 < .,1, 0))

*ind_computer	=1 if computer =0 
local asset_name = "ind_computer"
local asset_number = 414
gen `asset_name' = cond(mi(hh_m_00) | mi(hh_m_01_2)  , ., cond(hh_m_00 == `asset_number' & hh_m_01_2 > 0 & hh_m_01_2 < .,1, 0))

*car/auto
local asset_name = "ind_autos"
*asset number 422 - motors, vans 423 - trucks, mini buses
gen `asset_name' = cond(mi(hh_m_00) | mi(hh_m_01_2)  , ., cond( (hh_m_00 == 422 & hh_m_01_2 > 0 & hh_m_01_2 < .) | (hh_m_00 == 423 & hh_m_01_2 > 0 & hh_m_01_2 < .) ,1, 0))


collapse (max) ind_* cell_new, by( hhid)
save LR_HIES_assets, replace





*social protection - need to be collapsed
use HH_N1.dta, clear
unique hhid hh_n_01_2
bys hhid: egen social_prot = min(hh_n_01_3)
collapse (min) social_prot, by(hhid)
tab social_prot
recode social_prot (2=0)
destring hhid, replace
save LR_HIES_social_prot.dta, replace



use HH_I1, clear
destring hhid ea,replace
egen food_insecure = rowmin(hh_i_01 hh_i_08)
recode food_insecure (2=0) (6=.)
save LR_HIES_food_insecure, replace

