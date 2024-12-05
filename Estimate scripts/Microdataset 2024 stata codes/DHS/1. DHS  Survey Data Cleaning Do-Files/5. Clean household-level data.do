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
clear
clear matrix
clear mata 
set maxvar 30000

global survey_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data
global clean_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Clean Data
global combined_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Combined Data

*******************************************************************
*Household Level Analysis: Create Indicators and Clean data
*******************************************************************
**DHS Survey round years
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

use "${survey_data}\\`country'_${`country'_SR}\\`country'_Household.dta", clear
	
if hv000!= "KH6"  {
decode hv201, gen(water_source)
}

if hv000== "KH6"  {
	decode sh102, gen(water_source)
}
decode hv205, gen(sanit_source)

if  hv000 == "MV5"|hv000 == "KH6" {
	
gen hv801=.
gen hv802=.
gen hv803=.
gen hv804=.

}

gen v001=hv001
gen v002=hv002
gen v000=hv000
gen hh_line=hv003

label var v001 "cluster number"
label var v002 "household number"
lab var v000 "country code and phase"

gen survey_month=hv006
gen survey_year=hv007

lab var survey_month "month of interview"
lab var survey_year "year of interview"

if v000== "KH6"| v000== "MV5" {
	gen hv243e=. 
	lab var hv243e "has a ind_computer"
	gen safe_water=hv201
	
}

if v000== "PK7" | v000== "ML7" | v000== "RW7" | v000== "NG7" | v000== "MR7" | v000== "TL7" | v000== "KE8" | v000== "KH8" | v000== "TZ8" | v000== "NP8" {
	
	gen safe_water=1
	replace safe_water=0 if hv201==32|hv201==42|hv201==43|hv201==61|hv201==62|hv201==96	
	*Members of household are considered to have safe sanitation if the household is facility improved and not shared with other households (hv225). 
	replace hv225=0 if hv205==31
	
	gen safe_sanitation=1
	replace safe_sanitation=. if hv205==.
	replace safe_sanitation=1 if hv205==11|hv205==12|hv205==13|hv205==21|hv205==22|hv205==41
	replace safe_sanitation=0 if hv205==14|hv205==15|hv205==23|hv205==31|hv205==42|hv205==43|hv205==51|hv205==61|hv205==96
	*replace safe_sanitation=0 if hv238a==3
	replace safe_sanitation=0 if hv225==1
				
	gen clean_cook_fuel=1 if hv226==1|hv226==2|hv226==3|hv226==4
	replace  clean_cook_fuel=0 if hv226==5|hv226==6|hv226==7|hv226==8|hv226==9|hv226==10|hv226==11|hv226==12|hv226==13|hv226==95|hv226==96
	replace  clean_cook_fuel=. if hv226==.
		
	rename hv207 ind_radio 
	rename hv208 ind_tv
	rename hv209 ind_refrig
	rename hv221 ind_phone
	rename hv243a cell_new
	rename hv210 ind_bike 
	rename hv211 ind_motorcycle 
	rename hv212 ind_autos
	rename hv243e ind_computer 

	gen deprive_sl_asset = 0
	replace deprive_sl_asset = 1 if (( ind_radio + ind_tv + ind_phone + ind_refrig + ind_bike + ind_motorcycle < 2) & ind_autos==0)
	replace deprive_sl_asset = . if ind_radio==. & ind_tv==. & ind_phone==. & ind_refrig==. & ind_bike==. & ind_motorcycle==. & ind_autos==.
	
	egen ind_asset_ownership=rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_motorcycle ind_autos ind_computer ind_bike)

	gen quality_floor=1 
	replace quality_floor=0 if hv213==11|hv213==12|hv213==13|hv213==21|hv213==22|hv213==96
	replace quality_floor=1 if  hv213==31|hv213==32|hv213==33|hv213==34|hv213==35|hv213==36
	replace quality_floor=. if hv213==.|hv213==.a
	
	gen quality_roof=1  
	replace quality_roof=0 if hv215==32|hv215==31|hv215==11|hv215==12|hv215==13|hv215==21|hv215==22|hv215==23|hv215==24|hv215==25|hv215==34|hv215==37|hv215==36|hv215==96
	replace quality_roof=1 if hv215==33|hv215==35
	replace quality_roof=. if hv215==.|hv215==.a
	
	decode hv215, gen(roof_source)
	replace quality_roof =1 if roof_source=="cement/concrete"| roof_source=="cement/rcc"|roof_source=="ceramic tiles"|roof_source=="roofing tiles"|roof_source=="reinforced brick cement/rcc"| roof_source=="metal"| roof_source=="metal sheet"| roof_source=="iron sheets/metal"| roof_source=="iron sheets"| roof_source=="metal/zinc"|roof_source=="bricks" |roof_source=="galvanized sheets" |roof_source=="roofing shingles" |roof_source=="corrugated iron/zinc" |roof_source=="metal/galvanized sheet"|roof_source=="calamine/cement fiber"
	
	gen quality_wall=1 
	replace quality_wall=0 if hv214==11|hv214==12|hv214==13|hv214==14|hv214==15|hv214==21|hv214==22|hv214==23|hv214==24|hv214==25|hv214==26|hv214==96
	replace quality_wall=1 if hv214==31|hv214==32|hv214==33|hv214==34|hv214==35|hv214==36
	replace quality_wall=. if hv214==.|hv214==.a
	
	decode hv214, gen(wall_source)
	replace quality_wall =0 if wall_source=="bricks, unplastered"|wall_source=="thin plywood/wood sticks"|wall_source=="tree trunks with mud and cement"|wall_source=="unburnt bricks with cement"|wall_source=="wood planks"|wall_source=="wood planks/shingles"
	replace quality_wall =1 if wall_source=="metal"
		
	gen adequate_housing=1 if quality_floor==1&quality_roof==1&quality_wall==1
	replace adequate_housing=0 if quality_floor==0|quality_roof==0|quality_wall==0
	replace adequate_housing=. if quality_floor==.&quality_roof==.&quality_wall==.
	}

if v000== "HT7"  {
	
	gen safe_water=1
	replace safe_water=0 if hv201==32|hv201==42|hv201==43|hv201==61|hv201==62|hv201==96

	*Members of household are considered to have safe sanitation if the household is facility improved and not shared with other households (hv225). 
	*If no facility, adjust the indicator for whether household shares faciltiy with other households
	replace hv225=0 if hv205==31
	
	gen safe_sanitation=1
	replace safe_sanitation=. if hv205==.
	replace safe_sanitation=1 if hv205==11|hv205==12|hv205==13|hv205==21|hv205==22|hv205==41
	replace safe_sanitation=0 if hv205==14|hv205==15|hv205==23|hv205==31|hv205==42|hv205==43|hv205==51|hv205==61|hv205==96
	
	*replace safe_sanitation=0 if hv238a==3
	replace safe_sanitation=0 if hv225==1
		
	gen clean_cook_fuel=1 if hv226==1|hv226==2|hv226==3|hv226==4
	replace  clean_cook_fuel=0 if hv226==5|hv226==6|hv226==7|hv226==8|hv226==9|hv226==10|hv226==11|hv226==12|hv226==13|hv226==95|hv226==96
	replace  clean_cook_fuel=. if hv226==.

	rename hv207 ind_radio 
	rename hv208 ind_tv
	rename hv209 ind_refrig
	rename hv221 ind_phone
	rename hv243a cell_new
	rename hv210 ind_bike 
	rename hv211 ind_motorcycle 
	rename hv212 ind_autos
	rename hv243e ind_computer 
	
	gen deprive_sl_asset = 0
	replace deprive_sl_asset = 1 if (( ind_radio + ind_tv + ind_phone + ind_refrig + ind_bike + ind_motorcycle < 2) & ind_autos==0)
	replace deprive_sl_asset = . if ind_radio==. & ind_tv==. & ind_phone==. & ind_refrig==. & ind_bike==. & ind_motorcycle==. & ind_autos==.
	
	egen ind_asset_ownership=rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_motorcycle ind_autos ind_computer ind_bike)

	gen quality_floor=1 
	replace quality_floor=0 if hv213==11|hv213==12|hv213==21|hv213==22|hv213==96
	replace quality_floor=. if hv213==.
	
	gen quality_roof=1  
	replace quality_roof=0 if hv215==11|hv215==12|hv215==21|hv215==22|hv215==23|hv215==23|hv215==32|hv215==96
	replace quality_roof=. if hv215==.
	
	decode hv215, gen(roof_source)
	replace quality_roof =1 if roof_source=="cement/concrete"| roof_source=="cement/rcc"|roof_source=="ceramic tiles"|roof_source=="roofing tiles"|roof_source=="reinforced brick cement/rcc"| roof_source=="metal"| roof_source=="metal sheet"| roof_source=="iron sheets/metal"| roof_source=="iron sheets"| roof_source=="metal/zinc"|roof_source=="bricks" |roof_source=="galvanized sheets" |roof_source=="roofing shingles" |roof_source=="corrugated iron/zinc"
		
	gen quality_wall=1 
	replace quality_wall=0 if hv214==11|hv214==12|hv214==13|hv214==14|hv214==15|hv214==21|hv214==22|hv214==23|hv214==24|hv214==25|hv214==26|hv214==96
	replace quality_wall=. if hv214==.

	decode hv214, gen(wall_source)
	replace quality_wall =0 if wall_source=="bricks, unplastered"|wall_source=="thin plywood/wood sticks"|wall_source=="tree trunks with mud and cement"|wall_source=="unburnt bricks with cement"|wall_source=="wood planks"|wall_source=="wood planks/shingles"
	replace quality_wall =1 if wall_source=="metal"
	
	gen adequate_housing=1 if quality_floor==1&quality_roof==1&quality_wall==1
	replace adequate_housing=0 if quality_floor==0|quality_roof==0|quality_wall==0
	replace adequate_housing=. if quality_floor==.&quality_roof==.&quality_wall==.
	
	}


if v000== "KH6" {
	*No water source variable for KH6.
	drop safe_water
	
	gen safe_water_ds=1
	replace safe_water_ds=0 if sh102==32|sh102==42|sh102==43|sh102==61|sh102==62|sh102==96
	
	gen safe_water_ws=1
	replace safe_water_ws=0 if sh104b==32|sh104b==42|sh104b==43|sh104b==61|sh104b==62|sh104b==96
	
	gen safe_water=1 if safe_water_ds==1
	replace safe_water=0 if safe_water_ds==0
	
	*Members of household are considered to have safe sanitation if the household is facility improved. Sharing infromation not avaialble for KH6. 
	replace hv225=0 if hv205==31
	
	gen safe_sanitation=1
	replace safe_sanitation=. if hv205==.
	replace safe_sanitation=1 if hv205==11|hv205==12|hv205==13|hv205==21|hv205==22|hv205==41
	replace safe_sanitation=0 if hv205==14|hv205==15|hv205==23|hv205==31|hv205==42|hv205==43|hv205==51|hv205==61|hv205==96
	*replace safe_sanitation=0 if hv238a==3
	replace safe_sanitation=0 if hv225==1
		
	gen clean_cook_fuel=1 if hv226==1|hv226==2|hv226==3|hv226==4
	replace  clean_cook_fuel=0 if hv226==5|hv226==6|hv226==7|hv226==8|hv226==9|hv226==10|hv226==11|hv226==12|hv226==13|hv226==95|hv226==96
	replace  clean_cook_fuel=. if hv226==.
	
	rename hv207 ind_radio 
	rename hv208 ind_tv
	rename hv209 ind_refrig
	rename hv221 ind_phone
	rename hv243a cell_new
	rename hv210 ind_bike 
	rename hv211 ind_motorcycle 
	rename hv212 ind_autos
	*rename sh112e ind_computer 
	
	gen ind_computer=.
	
	*KH has no ind_computer variable
	gen deprive_sl_asset = 0
	replace deprive_sl_asset = 1 if (( ind_radio + ind_tv + ind_phone + ind_refrig + ind_bike + ind_motorcycle < 2) & ind_autos==0)
	replace deprive_sl_asset = . if ind_radio==. & ind_tv==. & ind_phone==. & ind_refrig==. & ind_bike==. & ind_motorcycle==. & ind_autos==.
	
	egen ind_asset_ownership=rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_motorcycle ind_autos ind_computer ind_bike)
	
	gen quality_floor=1 
	replace quality_floor=0 if hv213==11|hv213==12|hv213==13|hv213==21|hv213==22|hv213==96|hv213==41
	replace quality_floor=1 if  hv213==31|hv213==32|hv213==33|hv213==34|hv213==35|hv213==36
	replace quality_floor=. if hv213==.
	
	gen quality_roof=1  
	replace quality_roof=0 if hv215==32|hv215==31|hv215==11|hv215==12|hv215==13|hv215==21|hv215==22|hv215==23|hv215==24|hv215==96
	replace quality_roof=1 if hv215==33|hv215==34|hv215==35|hv215==36
	replace quality_roof=. if hv215==.

	decode hv215, gen(roof_source)
	replace quality_roof =1 if roof_source=="cement/concrete"| roof_source=="cement/rcc"|roof_source=="ceramic tiles"|roof_source=="roofing tiles"|roof_source=="reinforced brick cement/rcc"| roof_source=="metal"| roof_source=="metal sheet"| roof_source=="iron sheets/metal"| roof_source=="iron sheets"| roof_source=="metal/zinc"|roof_source=="bricks" |roof_source=="galvanized sheets"|roof_source=="roofing shingles" |roof_source=="corrugated iron/zinc" 
	
	gen quality_wall=1 
	replace quality_wall=0 if hv214==11|hv214==12|hv214==13|hv214==14|hv214==15|hv214==21|hv214==22|hv214==23|hv214==24|hv214==25|hv214==26|hv214==27|hv214==28|hv214==96
	replace quality_wall=1 if hv214==31|hv214==32|hv214==33|hv214==34|hv214==35|hv214==36
	replace quality_wall=. if hv214==.

	decode hv214, gen(wall_source)
	replace quality_wall =0 if wall_source=="bricks, unplastered"|wall_source=="thin plywood/wood sticks"|wall_source=="tree trunks with mud and cement"|wall_source=="unburnt bricks with cement"|wall_source=="wood planks"|wall_source=="wood planks/shingles"
	replace quality_wall =1 if wall_source=="metal"
	
	gen adequate_housing=1 if quality_floor==1&quality_roof==1&quality_wall==1
	replace adequate_housing=0 if quality_floor==0|quality_roof==0|quality_wall==0
	replace adequate_housing=. if quality_floor==.&quality_roof==.&quality_wall==.

}

if v000== "MV5" {
	
	drop safe_water
	
	gen safe_water=1
	replace safe_water=0 if hv201==32|hv201==42|hv201==43|hv201==61|hv201==62|hv201==96
	gen safe_sanitation=1
	replace safe_sanitation=0 if hv205==14|hv205==15|hv205==31|hv205==23|hv205==42|hv205==43|hv205==96
	*replace safe_sanitation=0 if hv238a==3
	replace safe_sanitation=. if hv205==.
	
	gen clean_cook_fuel=1 if hv226==1|hv226==2|hv226==3|hv226==4
	replace  clean_cook_fuel=0 if hv226==5|hv226==6|hv226==7|hv226==8|hv226==9|hv226==10|hv226==11|hv226==12|hv226==13|hv226==95|hv226==96
	replace  clean_cook_fuel=. if hv226==.
	
	rename hv207 ind_radio 
	rename hv208 ind_tv
	rename hv209 ind_refrig
	rename hv221 ind_phone
	rename hv243a cell_new
	rename hv210 ind_bike 
	rename hv211 ind_motorcycle 
	rename hv212 ind_autos
	rename sh112e ind_computer 
	
	gen deprive_sl_asset = 0
	replace deprive_sl_asset = 1 if (( ind_radio + ind_tv + ind_phone + ind_refrig + ind_bike + ind_motorcycle < 2) & ind_autos==0)
	replace deprive_sl_asset = . if ind_radio==. & ind_tv==. & ind_phone==. & ind_refrig==. & ind_bike==. & ind_motorcycle==. & ind_autos==.
	
	egen ind_asset_ownership=rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_motorcycle ind_autos ind_computer ind_bike)
	
	gen quality_floor=1 
	replace quality_floor=0 if hv213==11|hv213==12|hv213==13|hv213==21|hv213==22|hv213==96
	replace quality_floor=1 if  hv213==31|hv213==32|hv213==33|hv213==34|hv213==35|hv213==36
	replace quality_floor=. if hv213==.
	
	gen quality_roof=1  
	replace quality_roof=0 if hv215==34|hv215==32|hv215==31|hv215==11|hv215==12|hv215==13|hv215==21|hv215==22|hv215==23|hv215==24|hv215==96
	replace quality_roof=1 if hv215==33|hv215==35|hv215==36
	replace quality_roof=. if hv215==.
	
	decode hv215, gen(roof_source)
	replace quality_roof =1 if roof_source=="cement/concrete"| roof_source=="cement/rcc"|roof_source=="ceramic tiles"|roof_source=="roofing tiles"|roof_source=="reinforced brick cement/rcc"| roof_source=="metal"| roof_source=="metal sheet"| roof_source=="iron sheets/metal"| roof_source=="iron sheets"| roof_source=="metal/zinc"|roof_source=="bricks" |roof_source=="galvanized sheets" |roof_source=="roofing shingles" |roof_source=="corrugated iron/zinc"
	
	gen quality_wall=1 
	replace quality_wall=0 if hv214==11|hv214==12|hv214==13|hv214==14|hv214==15|hv214==21|hv214==22|hv214==23|hv214==24|hv214==25|hv214==26|hv214==32|hv214==96
	replace quality_wall=1 if hv214==31|hv214==32|hv214==33|hv214==34|hv214==35|hv214==36
	replace quality_wall=. if hv214==.

	decode hv214, gen(wall_source)
	replace quality_wall =0 if wall_source=="bricks, unplastered"|wall_source=="thin plywood/wood sticks"|wall_source=="tree trunks with mud and cement"|wall_source=="unburnt bricks with cement"|wall_source=="wood planks"|wall_source=="wood planks/shingles"
	replace quality_wall =1 if wall_source=="metal"
	
	gen adequate_housing=1 if quality_floor==1&quality_roof==1&quality_wall==1
	replace adequate_housing=0 if quality_floor==0|quality_roof==0|quality_wall==0
	replace adequate_housing=. if quality_floor==.&quality_roof==.&quality_wall==.


}

if  v000== "SN7"  {
	
	gen safe_water=1
	replace safe_water=0 if hv201==32|hv201==42|hv201==43|hv201==61|hv201==62|hv201==96
	
	*Members of household are considered to have safe sanitation if the household is facility improved and not shared with other households (hv225). 
	replace hv225=0 if hv205==31
	
	gen safe_sanitation=1
	replace safe_sanitation=. if hv205==.
	replace safe_sanitation=1 if hv205==11|hv205==12|hv205==13|hv205==21|hv205==22|hv205==41
	replace safe_sanitation=0 if hv205==14|hv205==15|hv205==23|hv205==31|hv205==42|hv205==43|hv205==51|hv205==61|hv205==96
	
	*replace safe_sanitation=0 if hv238a==3
	replace safe_sanitation=0 if hv225==1
		
	gen clean_cook_fuel=1 if hv226==1|hv226==2|hv226==3|hv226==4
	replace  clean_cook_fuel=0 if hv226==5|hv226==6|hv226==7|hv226==8|hv226==9|hv226==10|hv226==11|hv226==12|hv226==13|hv226==95|hv226==96
	replace  clean_cook_fuel=. if hv226==.

	rename hv207 ind_radio 
	rename hv208 ind_tv
	rename hv209 ind_refrig
	rename hv221 ind_phone
	rename hv243a cell_new
	rename hv210 ind_bike 
	rename hv211 ind_motorcycle 
	rename hv212 ind_autos
	rename hv243e ind_computer 
	
	gen deprive_sl_asset = 0
	replace deprive_sl_asset = 1 if (( ind_radio + ind_tv + ind_phone + ind_refrig + ind_bike + ind_motorcycle < 2) & ind_autos==0)
	replace deprive_sl_asset = . if ind_radio==. & ind_tv==. & ind_phone==. & ind_refrig==. & ind_bike==. & ind_motorcycle==. & ind_autos==.
	
	egen ind_asset_ownership=rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_motorcycle ind_autos ind_computer ind_bike)
	
	gen quality_floor=1 
	replace quality_floor=0 if hv213==11|hv213==12|hv213==21|hv213==22|hv213==96
	replace quality_floor=. if hv213==.
	
	gen quality_roof=1  
	replace quality_roof=0 if hv215==11|hv215==12|hv215==13|hv215==21|hv215==22|hv215==23|hv215==24|hv215==96
	replace quality_roof=. if hv215==.
	
	decode hv215, gen(roof_source)
	replace quality_roof =1 if roof_source=="cement/concrete"| roof_source=="cement/rcc"|roof_source=="ceramic tiles"|roof_source=="roofing tiles"|roof_source=="reinforced brick cement/rcc"| roof_source=="metal"| roof_source=="metal sheet"| roof_source=="iron sheets/metal"| roof_source=="iron sheets"| roof_source=="metal/zinc"|roof_source=="bricks" |roof_source=="galvanized sheets" |roof_source=="roofing shingles" |roof_source=="corrugated iron/zinc"
	
	gen quality_wall=1 
	replace quality_wall=0 if hv214==11|hv214==12|hv214==13|hv214==21|hv214==22|hv214==23|hv214==24|hv214==25|hv214==26|hv214==96
	replace quality_wall=. if hv214==.

	decode hv214, gen(wall_source)
	replace quality_wall =0 if wall_source=="bricks, unplastered"|wall_source=="thin plywood/wood sticks"|wall_source=="tree trunks with mud and cement"|wall_source=="unburnt bricks with cement"|wall_source=="wood planks"|wall_source=="wood planks/shingles"
	replace quality_wall =1 if wall_source=="metal"
	
	gen adequate_housing=1 if quality_floor==1&quality_roof==1&quality_wall==1
	replace adequate_housing=0 if quality_floor==0|quality_roof==0|quality_wall==0
	replace adequate_housing=. if quality_floor==.&quality_roof==.&quality_wall==.
	
}

if v000== "UG7" {
	
	gen safe_water=1
	replace safe_water=0 if hv201==32|hv201==42|hv201==43|hv201==61|hv201==62|hv201==63|hv201==96
	
	*Members of household are considered to have safe sanitation if the household is facility improved and not shared with other households (hv225). 
	replace hv225=0 if hv205==31
	
	gen safe_sanitation=1
	replace safe_sanitation=. if hv205==.
	replace safe_sanitation=1 if hv205==11|hv205==12|hv205==13|hv205==21|hv205==22|hv205==41
	replace safe_sanitation=0 if hv205==14|hv205==15|hv205==23|hv205==31|hv205==42|hv205==43|hv205==51|hv205==61|hv205==96
	*replace safe_sanitation=0 if hv238a==3
	replace safe_sanitation=0 if hv225==1
		
	gen clean_cook_fuel=1 if hv226==1|hv226==2|hv226==3|hv226==4
	replace  clean_cook_fuel=0 if hv226==5|hv226==6|hv226==7|hv226==8|hv226==9|hv226==10|hv226==11|hv226==12|hv226==13|hv226==95|hv226==96
	replace  clean_cook_fuel=. if hv226==.
	
	rename hv207 ind_radio 
	rename hv208 ind_tv
	rename hv209 ind_refrig
	rename hv221 ind_phone
	rename hv243a cell_new
	rename hv210 ind_bike 
	rename hv211 ind_motorcycle 
	rename hv212 ind_autos
	rename hv243e ind_computer 
	
	gen deprive_sl_asset = 0
	replace deprive_sl_asset = 1 if (( ind_radio + ind_tv + ind_phone + ind_refrig + ind_bike + ind_motorcycle < 2) & ind_autos==0)
	replace deprive_sl_asset = . if ind_radio==. & ind_tv==. & ind_phone==. & ind_refrig==. & ind_bike==. & ind_motorcycle==. & ind_autos==.
	
	egen ind_asset_ownership=rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_motorcycle ind_autos ind_computer ind_bike)
	
	gen quality_floor=1 
	replace quality_floor=0 if hv213==11|hv213==12|hv213==13|hv213==21|hv213==22|hv213==96|hv213==36
	replace quality_floor=1 if  hv213==31|hv213==32|hv213==33|hv213==34|hv213==35|hv213==37
	replace quality_floor=. if hv213==.
	
	gen quality_roof=1  
	replace quality_roof=0 if hv215==33|hv215==32|hv215==31|hv215==11|hv215==12|hv215==13|hv215==21|hv215==22|hv215==23|hv215==24|hv215==25|hv215==96
	replace quality_roof=1 if hv215==34|hv215==35|hv215==36|hv215==37
	replace quality_roof=. if hv215==.
	
	decode hv215, gen(roof_source)
	replace quality_roof =1 if roof_source=="cement/concrete"| roof_source=="cement/rcc"|roof_source=="ceramic tiles"|roof_source=="roofing tiles"|roof_source=="reinforced brick cement/rcc"| roof_source=="metal"| roof_source=="metal sheet"| roof_source=="iron sheets/metal"| roof_source=="iron sheets"| roof_source=="metal/zinc"|roof_source=="bricks" |roof_source=="galvanized sheets" |roof_source=="roofing shingles" |roof_source=="corrugated iron/zinc"
	
	gen quality_wall=1 
	replace quality_wall=0 if hv214==11|hv214==12|hv214==13|hv214==14|hv214==15|hv214==21|hv214==22|hv214==23|hv214==24|hv214==25|hv214==26|hv214==27|hv214==28|hv214==96
	replace quality_wall=1 if hv214==31|hv214==32|hv214==33|hv214==34|hv214==35|hv214==36
	replace quality_wall=. if hv214==.

	decode hv214, gen(wall_source)
	replace quality_wall =0 if wall_source=="bricks, unplastered"|wall_source=="thin plywood/wood sticks"|wall_source=="tree trunks with mud and cement"|wall_source=="unburnt bricks with cement"|wall_source=="wood planks"|wall_source=="wood planks/shingles"
	replace quality_wall =1 if wall_source=="metal"
	
	gen adequate_housing=1 if quality_floor==1&quality_roof==1&quality_wall==1
	replace adequate_housing=0 if quality_floor==0|quality_roof==0|quality_wall==0
	replace adequate_housing=. if quality_floor==.&quality_roof==.&quality_wall==.
	
	}


if v000== "ZA7"  {
	gen safe_water=1
	replace safe_water=0 if hv201==32|hv201==42|hv201==43|hv201==61|hv201==62|hv201==96
	
	*Members of household are considered to have safe sanitation if the household is facility improved and not shared with other households (hv225). 
	replace hv225=0 if hv205==31
	
	gen safe_sanitation=1
	replace safe_sanitation=. if hv205==.
	replace safe_sanitation=1 if hv205==11|hv205==12|hv205==13|hv205==21|hv205==41
	replace safe_sanitation=0 if hv205==14|hv205==15|hv205==22|hv205==23|hv205==31|hv205==42|hv205==43|hv205==51|hv205==61|hv205==96
	
	*replace safe_sanitation=0 if hv238a==3
	replace safe_sanitation=0 if hv225==1
		
	gen clean_cook_fuel=1 if hv226==1|hv226==2|hv226==3|hv226==4|hv226==12|hv226==13|hv226==14
	replace  clean_cook_fuel=0 if hv226==5|hv226==6|hv226==7|hv226==8|hv226==9|hv226==10|hv226==11|hv226==95|hv226==96
	replace  clean_cook_fuel=. if hv226==.
	
	rename hv207 ind_radio 
	rename hv208 ind_tv
	rename hv209 ind_refrig
	rename hv221 ind_phone
	rename hv243a cell_new
	rename hv210 ind_bike 
	rename hv211 ind_motorcycle 
	rename hv212 ind_autos
	rename hv243e ind_computer 
	
	gen deprive_sl_asset = 0
	replace deprive_sl_asset = 1 if (( ind_radio + ind_tv + ind_phone + ind_refrig + ind_bike + ind_motorcycle < 2) & ind_autos==0)
	replace deprive_sl_asset = . if ind_radio==. & ind_tv==. & ind_phone==. & ind_refrig==. & ind_bike==. & ind_motorcycle==. & ind_autos==.
	
	egen ind_asset_ownership=rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_motorcycle ind_autos ind_computer ind_bike)
		
	gen quality_floor=1 
	replace quality_floor=0 if hv213==11|hv213==12|hv213==13|hv213==21|hv213==22|hv213==96
	replace quality_floor=1 if  hv213==31|hv213==32|hv213==33|hv213==34|hv213==35|hv213==36
	replace quality_floor=. if hv213==.
	
	gen quality_roof=1  
	replace quality_roof=0 if hv215==32|hv215==31|hv215==11|hv215==12|hv215==13|hv215==21|hv215==22|hv215==23|hv215==24|hv215==25|hv215==26|hv215==33|hv215==96
	replace quality_roof=1 if hv215==34|hv215==35|hv215==36
	replace quality_roof=. if hv215==.
	
	decode hv215, gen(roof_source)
	replace quality_roof =1 if roof_source=="cement/concrete"| roof_source=="cement/rcc"|roof_source=="ceramic tiles"|roof_source=="roofing tiles"|roof_source=="reinforced brick cement/rcc"| roof_source=="metal"| roof_source=="metal sheet"| roof_source=="iron sheets/metal"| roof_source=="iron sheets"| roof_source=="metal/zinc"|roof_source=="bricks" |roof_source=="galvanized sheets" |roof_source=="roofing shingles" | roof_source=="corrugated iron/zinc"
	
	gen quality_wall=1 
	replace quality_wall=0 if hv214==11|hv214==12|hv214==13|hv214==14|hv214==15|hv214==21|hv214==22|hv214==23|hv214==24|hv214==25|hv214==26|hv214==96
	replace quality_wall=1 if hv214==31|hv214==32|hv214==33|hv214==34|hv214==35|hv214==36
	replace quality_wall=. if hv214==.

	decode hv214, gen(wall_source)
	replace quality_wall =0 if wall_source=="bricks, unplastered"|wall_source=="thin plywood/wood sticks"|wall_source=="tree trunks with mud and cement"|wall_source=="unburnt bricks with cement"|wall_source=="wood planks"|wall_source=="wood planks/shingles"
	replace quality_wall =1 if wall_source=="metal"
	
	gen adequate_housing=1 if quality_floor==1&quality_roof==1&quality_wall==1
	replace adequate_housing=0 if quality_floor==0|quality_roof==0|quality_wall==0
	replace adequate_housing=. if quality_floor==.&quality_roof==.&quality_wall==.
	
}

rename hv206 ind_electric
rename clean_cook_fuel ind_cleanfuel

	lab var ind_electric "Electricity"
	lab var ind_cleanfuel "Clean cooking fuel"

	lab var ind_radio "Household has radio"
	lab var ind_tv "Household has television"
	lab var ind_refrig "Household has refrigerator"
	lab var ind_phone "Household has telephone"
	lab var cell_new "Household has mobile"
	lab var ind_bike "Household has bike"
	lab var ind_motorcycle "Household has motorcycle"
	lab var ind_autos "Household has automobile"
	lab var ind_computer "Household has computer"
	
rename quality_floor ind_floor 
rename quality_roof ind_roof
rename quality_wall ind_wall
rename safe_water ind_water
rename safe_sanitation ind_toilet
rename adequate_housing ind_livingcond
	
	lab var ind_floor "Floor quality"
	lab var ind_roof "Roof quality"
	lab var ind_wall "Wall Quality"
	lab var ind_water "Safely managed water source"
	lab var ind_toilet "Safely managed sanitation"
	lab var ind_asset_ownership "Share of  Assets"
	lab var ind_livingcond "Adequate housing"

	if v000!="PK7" {
gen hh_weight = hv005/1000000
	}
	if v000=="PK7" {
gen hh_weight = hv005/1000000
replace hh_weight=shv005/1000000 if v000=="PK7"&(hv024==5|hv024==7)
	}
lab var hh_weight "Household Sample weight"

decode hv213, gen(floor_source)

rename hv801 hh_surveytime_start
rename hv802 hh_surveytime_end

save "${clean_data}//`country'_${`country'_SR}_Household_Updated_Intermediate.dta", replace

keep hh_line hh_weight hv022 hv803 hv804 v000 v001 v002 hv003 deprive_sl_asset ind_cleanfuel ind_electric water_source sanit_source hv201 hv205 ind_computer ind_radio ind_tv ind_refrig ind_phone cell_new ind_bike ind_motorcycle ind_autos ind_computer ind_floor ind_roof ind_wall ind_water ind_toilet ind_asset_ownership ind_livingcond roof_source floor_source wall_source hh_surveytime_start hh_surveytime_end

sort v000 v001 v002 

save "${clean_data}//`country'_${`country'_SR}_Household_Updated.dta", replace

********************************************************************************
use "${clean_data}//`country'_${`country'_SR}_Household_Updated_Intermediate.dta", clear

merge 1:m v001 v002 using "${clean_data}//`country'_${`country'_SR}_Household_Member_Updated.dta", keep(match)

duplicates drop v001 v002, force

keep hhid hh_weight v000 v001 v002 hv005 hv022 survey_month survey_year hv025 func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh hv206 hv207 hv208 hv221 ind_cleanfuel ind_electric water_source sanit_source hv201 hv205 ind_computer ind_radio ind_tv ind_refrig ind_phone cell_new ind_bike ind_motorcycle ind_autos ind_computer ind_floor ind_roof ind_wall ind_water ind_toilet ind_asset_ownership ind_livingcond roof_source roof_source floor_source wall_source hh_surveytime_start hh_surveytime_end

rename hv025 ResidenceType
rename v001 cluster_number
rename v002 hh_number

save "${combined_data}/`country'_${`country'_SR}_Household_Level_Analysis.dta",replace

}
