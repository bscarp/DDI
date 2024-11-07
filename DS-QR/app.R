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
  title = "DS-QR",
  tags$style(
    "img {
      display: block;
      margin-left: auto;
      margin-right: auto;
      max-width: 50%
    }"
  ),
  
  # sidebar = sidebar(),
  
  # Landing page
  nav_panel(title = "Home",
            img(src="DDI_Logo.png", align = "center"),
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
  nav_panel(title = "Overview of results",
            layout_sidebar(
              sidebar = sidebar(selectInput("region", "Region", choices = c("World", unique(ddi_2024_s$Region)), selected = "World")),
              navset_card_underline(
                nav_panel("Map",
                          h4("Do the datasets reviewed in each country include functional difficulty questions?", align = "center"),
                          girafeOutput("map", width = "100%")
                ),
                nav_panel("Table", DTOutput("table1"))
              )
            )
  ),
  nav_panel(title = "Detailed results", 
            layout_sidebar(
              sidebar = sidebar(selectInput("country", "Country", choices = unique(ddi_2024$Country))),
              DTOutput("table2")
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
