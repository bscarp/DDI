# DS-QR
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
library(readxl)
library(ggiraph)
library(DT)
library(sf)
library(terra)

ddi_2024 = read_xlsx("Dataset_Review_Results_2024_full.xlsx", sheet = 1)
ddi_2024 = ddi_2024 %>% mutate(ISO3 = countrycode::countryname(Country, "iso3c"), .after = Country)
ddi_2024_s = ddi_2024 %>% group_by(ISO3) %>% summarise(Region = first(Region), Country = first(Country), WG = max(WG, na.rm = TRUE), FL = max(FL, na.rm = TRUE)) %>% select(Region,Country,ISO3,WG,FL)
ddi_2024_s = ddi_2024_s %>% mutate(Summary = case_when(WG == 1 ~ "Washington Group\nShort Set",
                                                       FL == 1 ~ "Other functional\ndifficulty questions",
                                                       WG == 0 & FL == 0 ~ "No",
                                                       TRUE ~ NA))

ddi_2024 = ddi_2024 %>% mutate(WG = case_when(WG==1~"Yes", WG==0~"No", TRUE~NA), FL = case_when(FL==1~"Yes", FL==0~"No", TRUE~NA)) %>% 
  rename(Year = Years, `WG-SS` = WG, `Other functional difficulty questions` = FL)

# map_df = st_read("C:/Users/bscar/Downloads/geodata/gadm_410-levels.gpkg", layer = "ADM_0")
# map_df = left_join(map_df,ddi_2024_s %>% select(!Country), by = join_by(GID_0 == ISO3))
map_df = read_sf("ne_110m_admin_0_countries.shp")
map_df = map_df %>% mutate(ISO3 = if_else(ISO_A3=="-99", ADM0_A3, ISO_A3))
map_df = left_join(map_df,ddi_2024_s, by = join_by(ISO3)) %>% mutate(Summary = factor(if_else(is.na(Summary),"Not assessed",Summary), levels = c("Washington Group\nShort Set", "Other functional\ndifficulty questions", "No", "Not assessed")))
map_df = map_df %>% filter(!NAME == "Antarctica")

sf_use_s2(use_s2 = FALSE)

# Define UI for application that draws a histogram
ui <- page_navbar(
  title = "Disability Statistics Database (DS-QR)",
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
    title = "Home",
    div(class = "header",
        style = "display: flex; flex-direction: column; align-items: center; text-align: center;",
        img(src = "DDI_Logo.png", style = "width: 250px; margin-bottom: 20px;"),
        h1("The Disability Statistics Database", style = "font-weight: 700; color: #0072B5;"),
        p("Providing internationally comparable statistics to monitor the rights of persons with disabilities.")
    ),
    div(class = "data-area",
        style = "display: flex; flex-direction: column; align-items: center; text-align: center; max-width: 800px; margin: auto;",
        div(class = "card",
            h3("Disability Statistics – Estimates (DS-E)"),
            p("This database includes national and subnational descriptive statistics based on the analysis and disaggregation of national population and housing censuses and household surveys."),
            actionButton("ds_e_button", "Explore DS-E Database", onclick = "window.open('https://bscarp.shinyapps.io/DS-E/', '_blank')", class = "download-btn")
        ),
        div(class = "card",
            h3("Disability Statistics – Questionnaire Review (DS-QR)"),
            p("This database reports on whether population and housing censuses and household surveys include internationally recommended disability questions."),
            actionButton("ds_qr_button", "Explore DS-QR Database", onclick = "window.open('https://bscarp.shinyapps.io/DS-QR/', '_blank')", class = "download-btn")
        )
    )
  ),
  
  nav_panel(
    title = "Overview of Results",
    div(class = "header",
        h2("Overview of Disability Statistics"),
        p("Select a region to view disability statistics by country.")
    ),
    
    div(class = "filter-area",
        style = "display: flex; justify-content: center; margin-top: 20px;",
        selectInput("region", "Region", choices = c("World", unique(ddi_2024_s$Region)), selected = "World", width = "200px")
  ),
  
  # Map and Table side by side
  fluidRow(
    column(
      width = 6,
      div(class = "data-area",
          style = "display: flex; flex-direction: column; align-items: center; text-align: center;",
          h4("Map of Disability Questions by Country"),
          div(style = "width: 100%; max-width: 800px;",
              girafeOutput("map", width = "100%")
          ),
          #downloadButton(" ", "Download Table", class = "download-btn", style = "margin-top: 20px;")
      )
    ),
    column(
      width = 6,
      div(class = "data-area",
          style = "display: flex; flex-direction: column; align-items: center; text-align: center;",
          h4("Table of Disability Questions by Country"),
          div(style = "width: 100%; max-width: 800px;",
              DTOutput("table1")
          )
      )
    )
  )
  ),
  
  nav_panel(
    title = "Detailed results", 
    div(class = "header",
        h2("Detailed Country Statistics"),
        p("Select a country to view detailed information on disability questions.")
    ),
    
    div(class = "filter-area",
        style = "display: flex; justify-content: center; margin-top: 10px;",
        selectInput("country", "Country", choices = unique(ddi_2024$Country), width = "200px")
    ),
    
    # Data table 
    div(class = "data-area",
        style = "display: flex; flex-direction: column; align-items: center; text-align: center; padding: 20px;",
        div(style = "width: 100%; max-width: 800px;",
            DTOutput("table2")
        ),
        #downloadButton(" ", "Download Table", class = "download-btn", style = "margin-top: 20px;")
        
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  data_sel_map = reactive({if(input$region == "World"){
    map_df
  } else if(input$region == "East Asia & Pacific") {
    map_df %>% st_crop(xmin = 80, xmax = 180, ymin = -90, ymax = 60)
  } else if(input$region == "Europe & Central Asia") {
    map_df %>% st_crop(xmin = -20, xmax = 45, ymin = 30, ymax = 73)
  } else if(input$region == "Latin America & Caribbean") {
    map_df %>% st_crop(xmin = -100, xmax = -30, ymin = -60, ymax = 30)
  } else if(input$region == "Middle East & North Africa") {
    map_df %>% st_crop(xmin = -20, xmax = 70, ymin = 10, ymax = 40)
  } else if(input$region == "North America") {
    map_df %>% st_crop(xmin = -180, xmax = -50, ymin = 10, ymax = 90)
  } else if(input$region == "South Asia") {
    map_df %>% st_crop(xmin = 60, xmax = 100, ymin = 5, ymax = 40)
  } else if(input$region == "Sub-Saharan Africa") {
    map_df %>% st_crop(xmin = -20, xmax = 55, ymin = -40, ymax = 30)
  }
  })
  
  data_sel_tab = reactive({
    if(input$region == "World") {
      ddi_2024_s
    } else {
    ddi_2024_s %>% filter(Region == input$region)
    }
  })
  
  output$map <- renderGirafe({
    map = data_sel_map()
    plot = ggplot(data = map) + geom_sf_interactive(aes(fill=Summary, tooltip = paste0(NAME,"\n",Summary)),colour="black") + labs(fill = "") + scale_fill_manual_interactive(values = c("green4", "steelblue", "firebrick", "grey40")) + theme(legend.position = "bottom")
    girafe(ggobj = plot, options = list(opts_hover(css = ''), opts_sizing(rescale = TRUE), opts_hover_inv(css = "opacity:0.1;")))
  })
  
  output$table1 <- renderDT({
    data_sel_tab() %>% select(Region,Country,ISO3,Summary) %>% arrange(ISO3) %>% datatable()
  })
  
  output$table2 <- renderDT({
    ddi_2024 %>% filter(Country == input$country) %>% select(Dataset,Year,Notes,`WG-SS`,`Other functional difficulty questions`,`Difference from WG-SS`) %>% arrange(Dataset,Year,Notes) %>% 
      datatable(caption = htmltools::tags$caption(style = "caption-side: bottom; text-align: left;","Notes: WG-SS - The Washington Group Short Set on Functioning; (1) - Yes/No answer; (2) - Answer scale is different from that in the WG-SS; (3) - Wording of questions is different from the WG-SS; (4) - Does not have the selfcare domain; (5) - Does not have the communication domain; # - Communication and cognition domains are in a single question"))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
