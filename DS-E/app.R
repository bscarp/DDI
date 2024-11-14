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
library(tidyverse)
library(ggiraph)
library(DT)
library(sf)
library(terra)

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
  nav_panel(
    id = "home",
    title = "Home",
    div(class = "header",
        style = "display: flex; flex-direction: column; align-items: center; text-align: center;",
        img(src = "DDI_Logo.png", style = "width: 250px; margin-bottom: 20px;"),
        h1("The Disability Statistics Database", style = "font-weight: 700; color: #0072B5;"),
        p("The Disability Statistics (DS) Databases provide internationally comparable statistics to monitor the rights of persons with disabilities.")
    ),
    layout_columns(fill = FALSE,
    card(h4("Disability Statistics – Estimates (DS-E)"),
            p("This database includes national and subnational descriptive statistics based on the analysis and disaggregation of national population and housing censuses and household surveys."),
            actionButton("ds_e_button", "Explore DS-E Database", onclick = "window.open('https://bscarp.shinyapps.io/DS-E/', '_blank')", class = "download-btn")
        ),
        card(h4("Disability Statistics – Questionnaire Review (DS-QR)"),
            p("This database reports on whether population and housing censuses and household surveys include internationally recommended disability questions."),
            actionButton("ds_qr_button", "Explore DS-QR Database", onclick = "window.open('https://bscarp.shinyapps.io/DS-QR/', '_blank')", class = "download-btn")
        )
    )
  ),
  
  #Selectors
  sidebar = sidebar(id = "sidebar",
                    conditionalPanel(condition = "input.nav == 'across'", selectInput("country", "Countries (select multiple)", df_country, multiple = TRUE, selected = "Namibia"), ns = NS(NULL)),
                    conditionalPanel(condition = "input.nav == 'across'", actionLink("selectall","Select all countries")),
                    conditionalPanel(condition = "input.nav == 'within'", selectInput("country_sin", "Country (select single)", df_country, selected = "Namibia"), ns = NS(NULL)),
                    conditionalPanel(condition = "input.nav != 'home'", selectInput("indicator", "Indicators", df_indicator,selected = "Multidimensional poverty"), ns = NS(NULL)),
                    conditionalPanel(condition = "input.nav != 'home'", selectInput("group", "Population Groups", df_group,selected = "All adults (ages 15 and older)"), ns = NS(NULL)),
                    conditionalPanel(condition = "input.nav == 'across' | (input.nav == 'within' & input.h2 == 't3')", selectInput("disability", "Disability breakdown", df_disability,selected = 1), ns = NS(NULL)),
                    conditionalPanel(condition = "input.nav == 'within' & input.h2 == 't2'", selectInput("disability2", "Disability group", df_disability2,selected = "Disability"), ns = NS(NULL))
  ),
  nav_panel("Cross-country estimates", value = "across",
            navset_card_underline(id = "h1",
                                  nav_panel(value = 't1', "Graph", girafeOutput("stat_top_gra"), textOutput("key1"),textOutput("ind1")),
                                  nav_panel(value = 't1', "Table", DTOutput("stat_top_tab"), textOutput("key2"),textOutput("ind2"))
            )),
  nav_panel("Estimates within countries", value = "within",
            navset_card_underline(id = "h2",
                                  nav_panel(value = 't2', "Map", girafeOutput("stat_cou_map"), textOutput("ind3")),
                                  nav_panel(value = 't3', "Table", DTOutput("stat_cou_tab"), textOutput("ind4"))
            )),
)

# Define server logic required to draw a histogram
server <- function(session, input, output) {
  #Select all countries
  observe({
    if(input$selectall == 0) {
      return(NULL)
    } else if (input$selectall%%2 == 0) {
      updateSelectInput(session,"country","Countries (select multiple)",choices=df_country, selected = "Namibia")
      updateActionLink(session,"selectall","Select all countries")
    } else {
      updateSelectInput(session,"country","Countries (select multiple)",choices=df_country, selected = df_country)
      updateActionLink(session,"selectall","Select no countries")
    }
  })
  
  #Change categories for indicator selector
  observe({
    temp = input$indicator
    updateSelectInput(session,"indicator", "Indicators", choices = unique(data0$IndicatorName[data0$Country %in% input$country & data0$PopulationName == input$group & data0$DifficultyName %in% dis_grp() & !is.na(data0$Value)]), selected = temp)
  })
  
  #Change categories for grouping selector
  observe({
    temp = input$group
    if(grepl("least",input$indicator)) {
      temp = sub("Adults ages 15 to 29","Adults ages 25 to 29",temp)
    } else {
      temp = sub("Adults ages 25 to 29","Adults ages 15 to 29",temp)
    }
    updateSelectInput(session,"group", "Population Groups", choices = unique(data0$PopulationName[data0$Country %in% input$country & data0$IndicatorName == input$indicator & data0$DifficultyName %in% sub("No disability","Other",dis_grp()) & !is.na(data0$Value)]), selected = temp)
  })
  
  # process inputs to filter data
  dis_grp = reactive({
    unlist(case_when(input$disability == 1 & grepl("Prevalence", input$indicator, ignore.case = TRUE)  ~ list(c("Disability")),
                     input$disability == 2 & grepl("Prevalence", input$indicator, ignore.case = TRUE)  ~ list(c("Moderate Disability","Severe Disability")),
                     input$disability == 3 & grepl("Prevalence", input$indicator, ignore.case = TRUE)  ~ list(c("Severe Disability")),
                     input$disability == 4 & grepl("Prevalence", input$indicator, ignore.case = TRUE)  ~ list(c("Seeing Disability","Hearing Disability","Mobility Disability", "Cognition Disability",
                                                    "Self-care Disability", "Communication Disability")),
                     input$disability == 1 ~ list(c("No Disability","Disability")),
                     input$disability == 2 ~ list(c("No Disability","Moderate Disability","Severe Disability")),
                     input$disability == 3 ~ list(c("No and moderate disability","Severe Disability")),
                     input$disability == 4 ~ list(c("Seeing Disability","Hearing Disability","Mobility Disability", "Cognition Disability",
                                                    "Self-care Disability", "Communication Disability","No Disability"))))
    })
  
  data_sel0 = reactive({data0 %>% filter(Country %in% input$country, IndicatorName == input$indicator, PopulationName == input$group, DifficultyName %in% dis_grp()) %>%
    mutate(DifficultyName = factor(DifficultyName,levels = dis_grp()))})
  data_sel1 = reactive({data1 %>% filter(Country == input$country_sin, IndicatorName == input$indicator, PopulationName == input$group, DifficultyName %in% dis_grp())})
  data_sel2 = reactive({data1 %>% filter(admin=="admin1",Country == input$country_sin, IndicatorName == input$indicator, PopulationName == input$group, DifficultyName == input$disability2)})
  
  output$stat_top_gra <- renderGirafe({
    # draw the plot using data
    data_g = data_sel0() %>% mutate(label = paste0(Country,"\n",DifficultyName,"\n",if_else(is.na(Value), "Insufficient Sample Size", paste0(round(Value,1),"%"))))
    plot = ggplot(data = data_g) + geom_col_interactive(mapping = aes(y = Value, x = Country, fill = DifficultyName, tooltip = label, data_id = Country), position = "dodge") + 
      scale_y_continuous(name = NULL, labels = scales::label_percent(scale = 1), limits = c(0,100)) + 
      theme(axis.title = element_blank(), legend.title = element_blank(), axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))
    girafe(ggobj = plot, options = list(opts_hover(css = ''), opts_sizing(rescale = TRUE), opts_hover_inv(css = "opacity:0.1;")))
  })
  
  output$key1 <- output$key2 <- renderText({
    paste0("Key message: ",key_m %>% filter(Original == input$indicator) %>% select(`Key messages`) %>% as.character())
  })
  
  output$ind1 <- output$ind2 <- output$ind3 <- output$ind4 <- renderText({
    paste0("Indicator definition: ", key_m %>% filter(Original == input$indicator) %>% select(Tooltip) %>% as.character())
  })
  
  output$stat_top_tab <- renderDT({
    # draw the plot using data
    data_sel0() %>% mutate(Value = Value/100) %>% pivot_wider(names_from = c(IndicatorName,DifficultyName,PopulationName),names_glue = "{DifficultyName}",values_from = Value) %>% datatable() %>% formatPercentage(columns = dis_grp(), digits = 1)
  })
  
  output$stat_cou_map <- renderGirafe({
    data_m = data_sel2() %>% mutate(label = paste0(level,"\n",if_else(is.na(Value), "Insufficient Sample Size", paste0(round(Value,1),"%"))))
    map <- inner_join(map_df, data_m, by = join_by(iso_3166_2 == ISOCode))
    plot = ggplot(data=map) + geom_sf_interactive(aes(fill=Value, tooltip = label, data_id = level),colour="black") +
      scale_fill_continuous(name = NULL, labels = scales::label_percent(scale = 1), limits = c(0,100)) + 
      theme(axis.text = element_blank(), axis.ticks = element_blank())
    girafe(ggobj = plot, options = list(opts_hover(css = ''), opts_sizing(rescale = TRUE), opts_hover_inv(css = "opacity:0.1;"), opts_zoom(max = 10)))
    })
  
  output$stat_cou_tab <- renderDT({
    # draw the plot using data
    data_sel1() %>% mutate(Value = Value/100) %>% pivot_wider(names_from = c(IndicatorName,DifficultyName,PopulationName),names_glue = "{DifficultyName}",values_from = Value) %>% datatable() %>% formatPercentage(columns = dis_grp(), digits = 1)
  })
  
  # observe({
  #   if (input$nav == "home") {
  #     js$hideSidebar()
  #   }
  # })
}

# Run the application 
shinyApp(ui = ui, server = server)
