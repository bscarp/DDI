# DS-E
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
library(shinyWidgets)
library(tidyverse)
library(ggiraph)
library(DT)
library(sf)

load("Data.RData")

# Define UI for application that draws a histogram
ui <- page_navbar(
  id = "nav",
  title = "Disability Statistics Database (DS-E)",
  theme = bs_theme(bootswatch = "flatly", primary = "#0072B5", secondary = "#E9ECEF"),
  
  tags$style(HTML("
    .header {text-align: center; padding: 20px;}
    .filter-area {display: flex; justify-content: center; gap: 20px; margin-top: 20px;}
						
						 
    .data-area {padding: 20px; max-width: 1200px; margin: auto;}
    .card {margin: 15px; padding: 20px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); border-radius: 8px;}
    .download-btn {background-color: #0072B5; color: white; border: none; margin-top: 10px; width: 200px;}
  ")),
  
  # Landing page
  nav_item(a(href="https://ds-e.disabilitydatainitiative.org", "Home")),
  
  #Selectors
  sidebar = sidebar(id = "sidebar",
                    conditionalPanel(condition = "input.nav == 'across'", virtualSelectInput("country", "Countries (select multiple)", list_country, multiple = TRUE, search = TRUE, selected = c("South Africa", "Kenya", "Uganda")), ns = NS(NULL)),
                    conditionalPanel(condition = "input.nav == 'across'", actionLink("selectall","Select all countries"), actionLink("reset","Reset countries")),
                    conditionalPanel(condition = "input.nav == 'within'", virtualSelectInput("country_sin", "Country (select single)", list_country, search = TRUE, selected = "South Africa"), ns = NS(NULL)),
                    conditionalPanel(condition = "input.nav == 'within' & input.h2 == 't3'", tooltip(virtualSelectInput("admin", "Select the subnational level to display:", c("Subnational division 1", "Subnational division 2", "Alternative subnational division"), search = TRUE, selected = "Subnational division 1"),"The Methods tab above has definitions and details about breakdowns", placement = "right"), ns = NS(NULL)),
                    conditionalPanel(condition = "input.nav != 'home'", tooltip(virtualSelectInput("indicator", "Indicators", list_indicator, search = TRUE, selected = "Multidimensional poverty"),"The Methods tab above has definitions and details about breakdowns", placement = "right"), ns = NS(NULL)),
                    conditionalPanel(condition = "input.nav != 'home'", tooltip(selectInput("group", "Population Groups", list_group,selected = "All adults (ages 15 and older)"),"The Methods tab above has definitions and details about breakdowns", placement = "right"), ns = NS(NULL)),
                    conditionalPanel(condition = "input.nav == 'across' | (input.nav == 'within' & input.h2 == 't3')", tooltip(selectInput("disability", "Disability breakdown", choices = list_disability, selected = 1),"The Methods tab above has definitions and details about breakdowns", placement = "right"), ns = NS(NULL)),
                    conditionalPanel(condition = "input.nav == 'within' & input.h2 == 't2'", tooltip(selectInput("disability2", "Disability group", choices = list_disability2, selected = "Disability"),"The Methods tab above has definitions and details about breakdowns", placement = "right"), ns = NS(NULL)),
                    conditionalPanel(condition = "input.nav == 'within' & input.h2 == 't2'", noUiSliderInput("scale", "Indicator scale", min = 0, max = 100, c(0,100)), ns = NS(NULL))
  ),
  nav_panel("Cross-country estimates", value = "across",
            navset_card_underline(id = "h1",
                                  nav_panel(value = 't1', "Graph", h4(textOutput("title1")), h6(textOutput("key1")), h6(textOutput("ind1")), girafeOutput("stat_top_gra")),
                                  nav_panel(value = 't1', "Table", h4(textOutput("title2")), h6(textOutput("key2")), h6(textOutput("ind2")), DTOutput("stat_top_tab"))
            )),
  nav_panel("Estimates within countries", value = "within",
            navset_card_underline(id = "h2",
                                  nav_panel(value = 't2', "Map", h4(textOutput("title3")), textOutput("ind3"), girafeOutput("stat_cou_map")),
                                  nav_panel(value = 't3', "Table", h4(textOutput("title4")), textOutput("ind4"), DTOutput("stat_cou_tab"))
            )),
  nav_item(a(href="https://www.disabilitydatainitiative.org/ds-e-methods", "Methods", target="_blank")),
  nav_item(a(href="https://www.disabilitydatainitiative.org/accessibility", "Accessibility", target="_blank"))
  # nav_panel("Test",tableOutput('show_inputs'), textOutput('show_data'))
)

# Define server logic required to draw a histogram
server <- function(session, input, output) {
  session$allowReconnect(TRUE)
  
  #Select all countries
  observe({
    if(input$selectall == 0) {
      return(NULL)
    } else if (input$selectall%%2 == 0) {
      updateVirtualSelect("country", "Countries (select multiple)", choices = list_country, selected = c("South Africa", "Kenya", "Uganda"), session = session)
      updateActionLink(session,"selectall","Select all countries")
    } else {
      updateVirtualSelect("country", "Countries (select multiple)", choices = list_country, selected = as.character(unlist(list_country)), session = session)
      updateActionLink(session,"selectall","Select no countries")
    }
  })
  
  #Reset countries
  observe({
    if(input$reset == 0) {
      return(NULL)
    } else {
      updateVirtualSelect("country", "Countries (select multiple)", choices=list_country, selected = c("South Africa", "Kenya", "Uganda"), session = session)
      updateActionLink(session,"selectall","Select all countries")
    }
  })
  
  #Change country based on country_sin
  # observe({
  #   updateVirtualSelect("country", "Countries (select multiple)", choices=list_country, selected = input$country_sin, session = session)
  # })
  
  #Change categories for admin selector
  observe({
    temp = if_else(input$admin %in% df_country$admin[df_country$Country %in% input$country_sin], input$admin, "Subnational division 1")
    updateVirtualSelect("admin", "Select the subnational level to display:", choices = df_country$admin[df_country$Country %in% input$country_sin], selected = temp, session = session)
  })
  
  #Change categories for indicator selector
  observe({
    temp = input$indicator
    updateVirtualSelect("indicator", "Indicators", disabledChoices = df_static %>% filter(Country %in% input$country) %>% summarise(min = min(min), .by = IndicatorName) %>% filter(min == "Inf") %>% pull(IndicatorName), selected = temp, session = session)
  })
  
  #Change categories for grouping selector
  observe({
    temp = input$group
    if(grepl("higher",input$indicator)) {
      temp = sub("Adults ages 15 to 29","Adults ages 25 to 29",temp)
      temp2 = sub("Adults ages 15 to 29","Adults ages 25 to 29", list_group)
    } else if(input$disability == 4 & !input$indicator == "Adults with disabilities") {
      temp = list_group[1]
      temp2 = list_group[1]
    } else if(input$indicator == "Households with disabilities") {
      temp = if_else(grepl("Adults ages", temp), list_group[1], temp)
      temp2 = list_group[c(1,4,5)]
    } else {
      temp = sub("Adults ages 25 to 29","Adults ages 15 to 29",temp)
      temp2 = list_group
    }
    updateSelectInput(session, "group", "Population Groups", choices = temp2, selected = temp)
  })
  
  #Change categories for disability selector
  observe({
    temp = input$disability
    if(input$indicator == "Households with disabilities") {
      temp = ifelse(temp==4, 1, temp)
      temp2 = list_disability[1:3]
    } else {
      temp2 = list_disability
    }
    updateSelectInput(session, "disability", "Disability breakdown", choices = temp2, selected = temp)
  })
  
  #Change categories for disability selector
  observe({
    temp = input$disability2
    if(input$indicator == "Households with disabilities") {
      temp = ifelse(temp %in% list_disability2[4:9], list_disability2[1], temp)
      temp2 = list_disability2[c(1:3,10:11)]
    } else {
      temp2 = list_disability2
    }
    updateSelectInput(session, "disability2", "Disability group", choices = temp2, selected = temp)
  })
  
  # process inputs to filter data
  dis_grp = reactive({
    unlist(case_when(input$disability == 1 & grepl("disab", input$indicator, ignore.case = TRUE)  ~ list(c("Disability")),
                     input$disability == 2 & grepl("disab", input$indicator, ignore.case = TRUE)  ~ list(c("Moderate Disability","Severe Disability")),
                     input$disability == 3 & grepl("disab", input$indicator, ignore.case = TRUE)  ~ list(c("Severe Disability")),
                     input$disability == 4 & grepl("disab", input$indicator, ignore.case = TRUE)  ~ list(c("Seeing Disability","Hearing Disability","Mobility Disability", "Cognition Disability",
                                                    "Self-care Disability", "Communication Disability")),
                     input$disability == 1 ~ list(c("No Disability","Disability")),
                     input$disability == 2 ~ list(c("No Disability","Moderate Disability","Severe Disability")),
                     input$disability == 3 ~ list(c("No and moderate Disability","Severe Disability")),
                     input$disability == 4 ~ list(c("Seeing Disability","Hearing Disability","Mobility Disability", "Cognition Disability",
                                                    "Self-care Disability", "Communication Disability","No Disability"))))
    })
  
  adm_grp = reactive({
    unlist(case_when(input$admin == "National" ~ list(c("National")),
                     input$admin == "Subnational division 1" ~ list(c("National","Subnational division 1")),
                     input$admin == "Subnational division 2" ~ list(c("National","Subnational division 2")),
                     input$admin == "Alternative subnational division" ~ list(c("National","Alternative subnational division"))
    ))
  })
  
  data_sel0 = reactive({data0 %>% filter(Country %in% input$country, IndicatorName == input$indicator, PopulationName == input$group, DifficultyName %in% dis_grp()) %>%
    mutate(DifficultyName = factor(DifficultyName,levels = dis_grp()))})
  data_sel1_p1 = reactive({data1 %>% filter(Country == input$country_sin)})
  data_sel1_p2 = reactive({data_sel1_p1() %>% filter(PopulationName == input$group)})
  data_sel1 = reactive({data_sel1_p2() %>% filter(IndicatorName == input$indicator)})
  # data_sel1 = reactive({data1 %>% filter(Country == input$country_sin, IndicatorName == input$indicator, PopulationName == input$group, admin %in% adm_grp(), DifficultyName %in% dis_grp()) %>% select(-c(Country,admin))})
  # data_sel2 = reactive({data1 %>% filter(Country == input$country_sin, IndicatorName == input$indicator, PopulationName == input$group, admin == "Subnational division 1", DifficultyName == input$disability2)})
  
  output$title1 <- renderText({
    paste0("Graph showing ", input$indicator, " for ", ifelse(length(input$country)==1,input$country,paste0(length(input$country), " countries")), " by ", paste0(dis_grp(), collapse = ", "))
  })
  
  output$title2 <- renderText({
    paste0("Table showing ", input$indicator, " for ", ifelse(length(input$country)==1,input$country,paste0(length(input$country), " countries")), " by ", paste0(dis_grp(), collapse = ", "))
  })
  
  output$title3 <- renderText({
    paste0("Map showing ", input$indicator, " for ", input$country_sin, " for ", input$disability2)
  })
  
  output$title4 <- renderText({
    paste0("Table showing ", input$indicator, " for ", input$country_sin, " at ", input$admin, " by ", paste0(dis_grp(), collapse = ", "))
  })
  
  output$key1 <- output$key2 <- renderText({
    key_m %>% filter(IndicatorName == input$indicator) %>% pull(`Key message`) %>% paste0("Key message: ", .)
  })
  
  output$ind1 <- output$ind2 <- output$ind3 <- output$ind4 <- renderText({
    key_m %>% filter(IndicatorName == input$indicator) %>% pull(Tooltip) %>% paste0("Indicator definition: ", .)
  })
  
  output$stat_top_gra <- renderGirafe({
    # draw the plot using data
    data_g = data_sel0() %>% mutate(label = paste0(Country,"\n",DifficultyName,"\n",if_else(is.na(Value), "Insufficient Sample Size", paste0(round(Value,1),"%"))))
    plot = ggplot(data = data_g) + geom_col_interactive(mapping = aes(y = Value, x = Country, fill = DifficultyName, tooltip = label, data_id = Country), position = "dodge") + 
      scale_y_continuous(name = NULL, labels = scales::label_percent(scale = 1), limits = c(0,100)) + labs(caption = source_all()) + 
      theme(axis.title = element_blank(), legend.title = element_blank(), legend.position = "bottom", legend.key.size = unit(2, "cm"), legend.key.spacing = unit(5, "mm"),
            text = element_text(size=60), axis.text.x = element_text(angle = 45, vjust = 1, hjust=1), 
            plot.caption = element_text(size = 40, margin = margin(t = 20)), plot.caption.position = "plot")
    girafe(ggobj = plot, width_svg = 2*length(dis_grp())+18, height_svg = 20, options = list(opts_hover(css = ''), opts_sizing(rescale = TRUE), opts_hover_inv(css = "opacity:0.1;")))
  })
  
  output$stat_top_tab <- renderDT({
    # draw the plot using data
    data_sel0() %>% mutate(Value = Value/100) %>% pivot_wider(names_from = c(IndicatorName,DifficultyName,PopulationName),names_glue = "{DifficultyName}",values_from = Value) %>% select(-c(admin,level)) %>%
      datatable(caption = htmltools::tags$caption(style = "caption-side: bottom; text-align: left;",HTML(paste0(source_all(), "<br/>A blank cell indicates that the estimate is not available.")))) %>% 
      formatPercentage(columns = dis_grp(), digits = 1)
  })
  
  output$stat_cou_map <- renderGirafe({
    data_m = data_sel1() %>% filter(admin == "Subnational division 1", DifficultyName == input$disability2) %>% mutate(label = paste0(level,"\n",if_else(is.na(Value), "Insufficient Sample Size", paste0(round(Value,1),"%"))))
    map <- inner_join(map_df, data_m, by = join_by(iso_3166_2 == ISOCode))
    plot1 = ggplot(data=map) + geom_sf_interactive(aes(fill=Value, tooltip = label, data_id = level),colour="black") +
      scale_fill_continuous(name = NULL, labels = scales::label_percent(scale = 1), limits = c(input$scale[1], input$scale[2])) + labs(caption = source_sin()) + 
      theme(axis.text = element_blank(), axis.ticks = element_blank(), legend.key.size = unit(3, "cm"), text = element_text(size = 60), 
            plot.caption = element_text(size = 40, margin = margin(t = 20)), plot.caption.position = "plot")
    girafe(ggobj = plot1, width_svg = 20, height_svg = 20, options = list(opts_hover(css = ''), opts_sizing(rescale = TRUE), opts_hover_inv(css = "opacity:0.1;"), opts_zoom(max = 10)))
    })
  
  output$stat_cou_tab <- renderDT({
    data_t = data_sel1() %>% filter(admin %in% adm_grp(), DifficultyName %in% dis_grp()) %>% select(-c(Country,admin))
    # draw the plot using data
    data_t %>% mutate(Value = Value/100) %>% pivot_wider(names_from = c(IndicatorName,DifficultyName,PopulationName),names_glue = "{DifficultyName}",values_from = Value) %>% 
      datatable(caption = htmltools::tags$caption(style = "caption-side: bottom; text-align: left;", HTML(paste0(source_sin(), "<br/>A blank cell indicates that the estimate is not available.")))) %>% 
      formatPercentage(columns = dis_grp(), digits = 1)
  })
  
  observe({
    temp = df_static %>% filter(Country == input$country_sin, IndicatorName == input$indicator)
    updateNoUiSliderInput(session = session, "scale", "Indicator scale", value = c(temp$min, temp$max), range = c(0,100))
  })
  
  source_all = reactive({
    df_static %>% filter(Country %in% input$country, IndicatorName == input$indicator) %>% pull(source) %>% paste0(collapse = ", ") %>% gsub("_"," ",.) %>% paste0("Data source(s): ", .)
  })
  
  source_sin = reactive({
    df_static %>% filter(Country == input$country_sin, IndicatorName == input$indicator) %>% pull(source) %>% gsub("_"," ",.) %>% paste0("Data source: ", .)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
