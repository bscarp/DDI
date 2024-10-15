# DSD-E
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(bslib)
library(shinyjs)
library(tidyverse)
library(readxl)
library(stringi)
library(ggiraph)
library(DT)
library(terra)
library(sf)

### df_country = read_xlsx("C:/Users/bcarpenter/Downloads/Census/Database/PowerBI/StatisticsCountry/region_names.xlsx")
### df_indicator = read_xlsx("C:/Users/bcarpenter/Downloads/Census/Database/PowerBI/Types/indicators_types.xlsx")
### df_group = read_xlsx("C:/Users/bcarpenter/Downloads/Census/Database/PowerBI/Types/population_types.xlsx")
### df_disability = read_xlsx("C:/Users/bcarpenter/Downloads/Census/Database/PowerBI/Types/difficulty_types.xlsx")
### data_n = read_xlsx("C:/Users/bcarpenter/Downloads/Census/Database/PowerBI/StatisticsTopics/satistics_national.xlsx")
### data_n = left_join(left_join(left_join(data_n,df_indicator),df_group),df_disability)
### data_n = data_n %>% select(Country,IndicatorName,PopulationName,DifficultyName,Value)
### data2 = read_xlsx("C:/Users/bcarpenter/Downloads/Census/Database/PowerBI/StatisticsCountry/statistics_admin1_level.xlsx")
### data2 = left_join(left_join(left_join(data2,df_indicator),df_group),df_disability)
### data2 = data2 %>% select(Country,Region,IndicatorName,PopulationName,DifficultyName,Value)
# 
# data0 = read_xlsx("C:/Users/bcarpenter/Downloads/Census/Database/Wide_Table_Output_Admin0_reduced.xlsx")
# names(data0) = names(data0) %>% sub("Household_Prevalence_","Household_Prevalence ",.)
# names(data0)[3:83] = names(data0)[3:83] %>% paste0("Prevalence ",.)
# # names(data0)[!grepl(" .* ",names(data0))][-c(1:2)] = names(data0)[!grepl(" .* ",names(data0))][-c(1:2)] %>% sub("(\\()(.*)(\\))","\\2 \\1all_adults\\3",.)
# data0 = data0 %>% pivot_longer(.,names(.)[-c(1:2)],names_to = c("IndicatorName","DifficultyName","PopulationName"),names_pattern = "(.*) (.*) \\((.*)\\)",
#                                values_to = "Value")
# data0 = data0 %>% select(-date)
# data1 = read_xlsx("C:/Users/bcarpenter/Downloads/Census/Database/Wide_Table_Output_Admin1_reduced.xlsx")
# names(data1) = names(data1) %>% sub("Household_Prevalence_","Household_Prevalence ",.)
# names(data1)[3:83] = names(data1)[3:83] %>% paste0("Prevalence ",.)
# # names(data1)[!grepl(" .* ",names(data1))][-c(1:2)] = names(data1)[!grepl(" .* ",names(data1))][-c(1:2)] %>% sub("(\\()(.*)(\\))","\\2 \\1all_adults\\3",.)
# data1 = data1 %>% pivot_longer(.,names(.)[-c(1:2)],names_to = c("IndicatorName","DifficultyName","PopulationName"),names_pattern = "(.*) (.*) \\((.*)\\)",
#                                values_to = "Value")
# 
# data0 = data0 %>% mutate(IndicatorName  = str_replace_all(IndicatorName, setNames(c("Prevalence",unique(data_n$IndicatorName)), unique(data0$IndicatorName))))
# data0 = data0 %>% mutate(DifficultyName = str_replace_all(DifficultyName,setNames(unique(data_n$DifficultyName),unique(data0$DifficultyName)[c(1,2,3,10,11,4,5,8,7,9,6)])))
# data0 = data0 %>% mutate(PopulationName = str_replace_all(PopulationName,setNames(c(unique(data_n$PopulationName),"Adults ages 25 to 29"),unique(data0$PopulationName)[c(1,4,5,2,3,6:10)])))
# data1 = data1 %>% mutate(IndicatorName  = str_replace_all(IndicatorName, setNames(c("Prevalence",unique(data_n$IndicatorName)), unique(data1$IndicatorName))))
# data1 = data1 %>% mutate(DifficultyName = str_replace_all(DifficultyName,setNames(unique(data_n$DifficultyName),unique(data1$DifficultyName)[c(1,2,3,10,11,4,5,8,7,9,6)])))
# data1 = data1 %>% mutate(PopulationName = str_replace_all(PopulationName,setNames(c(unique(data_n$PopulationName),"Adults ages 25 to 29"),unique(data1$PopulationName)[c(1,4,5,2,3,6:10)])))
# 
# df_country = df_country$Country
# df_indicator = df_indicator$IndicatorName
# df_group = df_group$PopulationName
# df_disability = c("Disability versus no disability" = 1, "Severe versus moderate versus no disability" = 2, "Severe versus moderate or no disability" = 3,
#                   "Disability by type" = 4)
# df_disability2 = unique(data1$DifficultyName)
# 
# map_df = read_sf("C:/Users/bcarpenter/Downloads/world shp/ne_10m_admin_1_states_provinces.shp")
# iso = read_xlsx("C:/Users/bcarpenter/Downloads/Census/Database/R Shiny/REGION_ISO_CODESv2.xlsx") %>% select(Country,Region,ISOCode) %>% setNames(c("country","admin1","ISOCode"))
# data1 = left_join(data1,iso %>% filter(!admin1 == "tiris zemour et inchiri", !country == "Vietnam"), by = c("country","admin1"))
# 
# save(data0,data1,map_df,df_country,df_indicator,df_group,df_disability,df_disability2,file = "DSD-E/Test.Rbin")
# rm(list = ls())

# map_df %>% filter(iso_3166_2 %in% iso$ISOCode)

load("Test.Rbin")
data0 = data0 %>% rename("Country" = "country")
data1 = data1 %>% rename("Country" = "country")

# Define UI for application that draws a histogram
ui <- page_navbar(
  id = "nav",
  title = "DS-E",
  tags$style(
    "img {
      display: block;
      margin-left: auto;
      margin-right: auto;
      max-width: 50%
    }"
  ),
  
  # Landing page
  nav_panel(value = "home", title = "Home",
            # useShinyjs(),
            # extendShinyjs(text = 'shinyjs.hideSidebar = function(params) { $("body").addClass("sidebar-collapsed") }', functions = c("hideSidebar")),
            img(src="DDI_Logo.png", `max-width` = "50%", align = "center"),
            h1("The Disability Statistics Database", align = "center"),
            h4("The Disability Statistics (DS) Databases provide internationally comparable statistics to monitor the rights of persons with disabilities.", align = "center"),
            layout_columns(
              card(card_header(h1(tags$a("Disability Statistics – Estimates (DS-E)", href = "https://bscarp.shinyapps.io/DS-E/", target = "_blank"))),
                   card_body(h4("The Disability Statistics – Estimates (DS-E) Database includes national and subnational descriptive statistics based on the analysis and disaggregation of national population and housing censuses and household surveys."))
              ),
              card(card_header(h1(tags$a("Disability Statistics – Questionnaire Review (DS-QR)", href = "https://bscarp.shinyapps.io/DS-QR/", target = "_blank"))),
                   card_body(h4("The Disability Statistics – Questionnaire Review Database (DS-QR) reports on whether population and housing censuses and household surveys include internationally recommended disability questions."))
              )
            )
  ),
  
  #Selectors
  sidebar = sidebar(id = "sidebar",
               conditionalPanel(condition = "input.nav == 'across'", selectInput("country", "Countries (select mutiple)", df_country, multiple = TRUE, selected = "Namibia"), ns = NS(NULL)),
               conditionalPanel(condition = "input.nav == 'within'", selectInput("country_sin", "Country (select single)", df_country, selected = "Namibia"), ns = NS(NULL)),
               conditionalPanel(condition = "input.nav != 'home'", selectInput("indicator", "Indicators", df_indicator,selected = "Multidimensional poverty"), ns = NS(NULL)),
               conditionalPanel(condition = "input.nav != 'home'", selectInput("group", "Population Groups", df_group,selected = "All adults (ages 15 and older)"), ns = NS(NULL)),
               conditionalPanel(condition = "input.nav == 'across' | (input.nav == 'within' & input.h2 == 't3')", selectInput("disability", "Disability groups", df_disability,selected = 1), ns = NS(NULL)),
               conditionalPanel(condition = "input.nav == 'within' & input.h2 == 't2'", selectInput("disability2", "Disability groups", df_disability2,selected = "Disability"), ns = NS(NULL))
  ),
  nav_panel("Cross-country estimates", value = "across",
            navset_card_underline(id = "h1",
                                  nav_panel(value = 't1', "Graph", girafeOutput("stat_top_gra")),
                                  nav_panel(value = 't1', "Table", DTOutput("stat_top_tab"))
            )),
  nav_panel("Estimates within countries", value = "within",
            navset_card_underline(id = "h2",
                                  nav_panel(value = 't2', "Map", girafeOutput("stat_cou_map")),
                                  nav_panel(value = 't3', "Table", DTOutput("stat_cou_tab"))
            )),
)

# Define server logic required to draw a histogram
server <- function(session, input, output) {

  # process inputs to filter data
  dis_grp = reactive({
    unlist(case_when(input$disability == 1 & grepl("Prevalence", input$indicator, ignore.case = TRUE)  ~ list(c("Disability")),
                     input$disability == 2 & grepl("Prevalence", input$indicator, ignore.case = TRUE)  ~ list(c("Moderate disability","Severe disability")),
                     input$disability == 3 & grepl("Prevalence", input$indicator, ignore.case = TRUE)  ~ list(c("Severe disability")),
                     input$disability == 4 & grepl("Prevalence", input$indicator, ignore.case = TRUE)  ~ list(c("Seeing difficulties","Hearing difficulties","Mobility difficulties", "Cognition difficulties",
                                                    "Self-care difficulties", "Communication difficulties")),
                     input$disability == 1 ~ list(c("No disability","Disability")),
                     input$disability == 2 ~ list(c("No disability","Moderate disability","Severe disability")),
                     input$disability == 3 ~ list(c("No and moderate disability","Severe disability")),
                     input$disability == 4 ~ list(c("Seeing difficulties","Hearing difficulties","Mobility difficulties", "Cognition difficulties",
                                                    "Self-care difficulties", "Communication difficulties","No disability"))))
    })
  
  data_sel0 = reactive({data0 %>% filter(Country %in% input$country, IndicatorName == input$indicator, PopulationName == input$group, DifficultyName %in% dis_grp()) %>%
    mutate(DifficultyName = factor(DifficultyName,levels = dis_grp()))})
  data_sel1 = reactive({data1 %>% filter(Country == input$country_sin, IndicatorName == input$indicator, PopulationName == input$group, DifficultyName %in% dis_grp())})
  data_sel2 = reactive({data1 %>% filter(Country == input$country_sin, IndicatorName == input$indicator, PopulationName == input$group, DifficultyName == input$disability2)})
  
  output$stat_top_gra <- renderGirafe({
    # draw the plot using data
    plot = ggplot(data = data_sel0()) + geom_col_interactive(mapping = aes(y = Value, x = Country, fill = DifficultyName, tooltip = paste0(Country,"\n",DifficultyName,"\n",round(Value,1),"%"), data_id = Country), position = "dodge") + theme(legend.title=element_blank())
    girafe(ggobj = plot, options = list(opts_hover(css = ''), opts_sizing(rescale = TRUE), opts_hover_inv(css = "opacity:0.1;")))
  })
  
  output$stat_top_tab <- renderDT({
    # draw the plot using data
    data_sel0() %>% pivot_wider(names_from = c(IndicatorName,DifficultyName,PopulationName),names_glue = "{DifficultyName}",values_from = Value) %>% datatable() %>% formatRound(columns = dis_grp())
  })
  
  output$stat_cou_map <- renderGirafe({
    map <- inner_join(map_df, data_sel2(), by = join_by(iso_3166_2 == ISOCode))
    plot = ggplot(data=map) + geom_sf_interactive(aes(fill=Value, tooltip = paste0(name,"\n",round(Value,1),"%"), data_id = admin1),colour="black")
    girafe(ggobj = plot, options = list(opts_hover(css = ''), opts_sizing(rescale = TRUE), opts_hover_inv(css = "opacity:0.1;")))
    })
  
  output$stat_cou_tab <- renderDT({
    # draw the plot using data
    data_sel1() %>% pivot_wider(names_from = c(IndicatorName,DifficultyName,PopulationName),names_glue = "{DifficultyName}",values_from = Value) %>% datatable() %>% formatRound(columns = dis_grp())
  })
  
  # observe({
  #   if (input$nav == "home") {
  #     js$hideSidebar()
  #   }
  # })
}

# Run the application 
shinyApp(ui = ui, server = server)
