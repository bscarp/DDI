** FOOD
* 
*7 days
use HH_K1.dta, clear 
gen foodprice_tot = hh_k_05_1
*convert from usd to LRD: exchange_rate LRD -> US Dollar in 2016: 91 LRD: 1 USD
replace foodprice_tot =  hh_k_05_2 * 91 if hh_k_05_1==0 | hh_k_05_1==.

*cost per unit
gen foodprice_perunit = foodprice_tot/hh_k_04_2

*median price of food in district
bys hh_k_00_b hh_a_02: egen item_price = median(foodprice_perunit)

*hh_k_03_2 - quantity
gen food_consumption = foodprice_tot if hh_k_03_2 == hh_k_04_2 & !mi(hh_k_03_2)
replace food_consumption = foodprice_perunit* hh_k_03_2 if hh_k_03_2 != hh_k_04_2 & !mi(hh_k_03_2) & !mi(foodprice_perunit)
replace food_consumption= item_price* hh_k_03_2 if mi(food_consumption)


	collapse (sum) food_consumption, by(hhid)

label var food_consumption "food 7-day"
gen food_month = food_consumption*4
label var food_month "food exp (month)"
save "food_consumption.dta",replace

** NON-FOOD
/* 
Recall Period :
Constructing the non-food aggregate thus entails converting all these reported amounts to a uniform reference period—say one year—, and then aggregating across the various items.

Excluded: 

Expenditures on taxes and levies are not part of consumption, but a deduction from income, and should not be included in the consumption total. In any case, no special treatment is required for commodity taxes.

All purchases of financial assets, as well as repayments of debt, and interest payments should be excluded from the consumption aggregate.

More complex is the case of “lumpy” and relatively infrequent expenditures such as marriages and dowries, births, and funerals. we recommend leaving them out of the consumption aggregate.
we think that there is a relatively good case for excluding health expenditures in the consumption aggregate.
Expenditures at weddings and funerals are another lumpy and occasional item.

Expenditure on health:we think that there is a relatively good case for excluding health expenditures in the consumption aggregate.

educational expenditures:be included in the consumption aggregate.

Another group of expenditures are gifts, charitable contributions, and remittances to other households.excluding gifts and transfers, counting them as they are spent by their recipients.
*/
/* 
1. SEVEN DAY RECALL
101 Cigarettes (Lucky Strike / Marlborough), snuff                                                           
102 Matches                           
103 Public transport                   
104 Candles                            
105 Car Washing/Parking Fees           
106 Garbage Collection                 
107 Shoe Shining                       
108 Mosquito Coil / Insecticide Spray  
109 Cell phone scratch card (vouchers) 
110 Petrol or diesel                   

*/
** 7days
use HH_L1A.dta, clear
gen conv_usd = hh_l1a_02_2 * 91
egen nonfood_cost = rowtotal(hh_l1a_02_1 conv_usd)
collapse (sum) nonfood_cost, by(hhid)

label var nonfood_cost "nonfood (7 day)"

gen nonfood_cost_month_1 = nonfood_cost * 4
label var  nonfood_cost_month_1 "nonfood exp (month) 1"
save "nonfood_7_days.dta", replace

/*

2.THIRTY DAY RECALL
201 Kerosene/Paraffin                    
202 Electricity                         
203 Bottled Gas/Propane(for lighting/cooking)                                                               
204 Shoe Polish                         
205 Wood and other solid fuels           
206 Other energy sources (batteries, etc.)                                
207 Pets (Purchase of cats, dogs, veterinary and other services)                                                   
208 Admission charges(local video club,  cinema, stadium, concert) 
209 Newspapers and Magazines                                                       
210 Charcoal                            
211 Milling fees, grain                  
212 Bar soap (bath/body soap/ palmolive / lifebuoy )                                                                 
213 Laundry soap/Powder Soap (Clothes)   
214 Toothpaste, toothbrush               
215 Vehicle rental                       
216 Personal services (barber, manicure, pedicure, facial, hair dressers)                                                 
217 Toilet paper                         
218 Glycerine, Vaseline, skin creams, personal oils and lotions                                                     
219 Other personal/beauty products products (shampoo, razor blades,                                              cosmetics, hair products, nail polish, powder, oil etc.)                                                        
220 Household cleaning products (dish soap, toilet cleansers, broom, brush  etc.)                                                                            
221 Disposable Diapers (Pampers, etc.)   
222 Light bulbs                          
223 Internet, postage stamps or other postal fees                                                                      
224 Donation - to church, charity, beggar, etc.                                                                     
225 Motor vehicle service, repair, or parts                                                                            
226 Oil change / grease job (car, motorbike, etc.)                                                                     
227 Repair / pumping of tires, wheels    
228 Bicycle service, repair, or parts    
229 Wages paid to domestic help          
230 Bleach (Chlorax)                     
231 Laundry Services                     
232 Game of Chance (Winners, lottery etc.)                                                                             
233 Photocopying / Printing / Typing     
234 Wheel Barrow / Push-Push             

3. Past twelve months                                          
*/

**30days
use HH_L1B.dta, clear
gen conv_usd = hh_l1b_02_2 * 91
egen nonfood_cost_month_2 = rowtotal(hh_l1b_02_1 conv_usd)
collapse (sum) nonfood_cost_month_2,by(hhid)

label var nonfood_cost_month_2 "nonfood exp (month) 2"
save "nonfood_30day.dta", replace
"nonfood_7_days.dta"
** 1year
use HH_L2.dta, clear
gen conv_usd = hh_l2_02_2 * 91
egen nonfood_cost_yr = rowtotal(hh_l2_02_1 conv_usd)
collapse (sum) nonfood_cost_yr,by(hhid)

label var nonfood_cost_yr "nonfood exp (past year)"
gen nonfood_cost_month_3 = nonfood_cost_yr/12 
label var nonfood_cost_month_3 "nonfood exp (month) 3"

save "nonfood_yr.dta", replace


** education 
use HH_C.dta, clear
local question_number "a"
gen conv_usd_a = hh_c_39_a_2 * 91

gen conv_usd_b = hh_c_39_b_2 * 91

gen conv_usd_c = hh_c_39_c_2 * 91

gen conv_usd_d = hh_c_39_d_2 * 91

gen conv_usd_e = hh_c_39_e_2 * 91

gen conv_usd_f = hh_c_39_f_2 * 91

gen conv_usd_g = hh_c_39_g_2 * 91

gen conv_usd_h = hh_c_39_h_2 * 91

egen educ_cost_yr = rowtotal(hh_c_39_a_1 hh_c_39_b_1 hh_c_39_c_1 hh_c_39_d_1 hh_c_39_e_1 hh_c_39_f_1 hh_c_39_g_1 hh_c_39_h_1 conv_usd_a conv_usd_b conv_usd_c conv_usd_d conv_usd_e conv_usd_f conv_usd_g conv_usd_h) 


collapse (sum) educ_cost_yr , by(hhid)
label var educ_cost_yr "educ exp (past year)"
gen educ_cost_month = educ_cost_yr/12
label var educ_cost_month "educ cost (month)"


save "educ_exp.dta",replace


/* SECTION D: HEALTH 

15. How much did the household spend on [NAME] in the last thirty days for medical consultations, prescription medicines, prenatal visits, medical treatments like (bandages, injections prescribed by doctor), vaccinations etc that are not already covered previously? (DO NOT INCLUDE OVERNIGHT HOSPITALISATION COSTS OR VISITS TO A TRADITIONAL HEALER)--included
16. How much in total did the household spend on [NAME] in the last thirty days for non-prescription medicines, bandages etc., for which a doctor's recommendation was not used? -- included
20. What was the total cost of all of [NAME]'s overnight hospitalization(s) in the past twelve months? -- not included
*/

use HH_D.dta, clear
gen conv_usd_15 = hh_d_15_2 * 91
egen cost_medical_mth_1 = rowtotal(hh_d_15_1 conv_usd_15)

gen conv_usd_16 = hh_d_16_2 * 91
egen cost_medical_mth_2 = rowtotal(hh_d_16_1 conv_usd_16)

gen conv_usd_20 = hh_d_20_2 * 91
egen hosp_cost_yr = rowtotal(hh_d_20_1 conv_usd_20)

gen hosp_cost_mth = hosp_cost_yr/12
label var hosp_cost_mth "hospitalization exp (month) "

egen health_cost_month = rowtotal(cost_medical_mth_1 cost_medical_mth_2 hosp_cost_mth)

collapse (sum) health_cost_month , by(hhid)
label var health_cost_month "health exp (month)"

save "health_exp.dta", replace

*merge all separate expenses and sum up
use "health_exp.dta", clear
merge 1:1 hhid using "educ_exp.dta", gen(merge_exp_educ)
merge 1:1 hhid using  "nonfood_yr.dta", gen(merge_exp_nonfood)
merge 1:1 hhid using "nonfood_30day.dta", gen(merge_nonfood_month)
merge 1:1 hhid using "nonfood_7_days.dta", gen(merge_nonfood_week)
merge 1:1 hhid using "food_consumption.dta", gen(merge_food_week)

egen total_exp_month = rowtotal(health_cost_month educ_cost_month nonfood_cost_month_3 nonfood_cost_month_2 nonfood_cost_month_1 food_month)
gen health_exp_hh = health_cost_month/total_exp_month
save "LR_expenditure", replace
