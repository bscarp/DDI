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
library(ggiraph)
library(DT)
library(sf)
library(terra)

load("Data.RData")

sf_use_s2(use_s2 = FALSE)

# Define UI for application that draws a histogram
ui <- page_navbar(
  title = "Disability Statistics Database (DS-QR)",
  theme = bs_theme(bootswatch = "flatly", primary = "#0072B5", secondary = "#E9ECEF"),
  
  tags$style(HTML("
    .header {text-align: center; padding: 20px;}
    .filter-area {display: flex; justify-content: center; gap: 20px; margin-top: 20px;}
						
						 
    .data-area {padding: 20px; margin: auto;}
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
  
  nav_panel(title = "Overview of Results",
  
  # Map and Table side by side
  navset_card_pill(
    nav_panel(title = h5("Map of Disability Questions by Country"),
      layout_sidebar(sidebar = sidebar(selectInput("region", "Region", choices = c("World", as.character(unique(ddi_2024_s$Region))), selected = "World")),
                     h5(style = "text-align: center;", "This database reports on whether population and housing censuses and household surveys include internationally recommended disability questions."),
                     girafeOutput("map", width = "100%"))
    ),
    nav_panel(h5("Table of Disability Questions by Country"),
      div(div(style = "align-items: center; margin: auto; width: 100%; max-width: 1600px;",
              h5(style = "text-align: center;", "This database reports on whether population and housing censuses and household surveys include internationally recommended disability questions."),
              DTOutput("table1")
          ),
          #downloadButton(" ", "Download Table", class = "download-btn", style = "margin-top: 20px;")
      )
    )
  )
  ),
  
  nav_panel(
    title = "Detailed results",
    # Data table 
    div(class = "data-area",
        style = "align-items: center; text-align: center; padding: 20px;",
        div(style = "width: 100%;",
            DTOutput("table2")
        ),
        #downloadButton(" ", "Download Table", class = "download-btn", style = "margin-top: 20px;")
        
    )
  ),
  nav_item(a(href="http://www.disabilitydatainitiative.org/databases/methods", "Methods", target="_blank")),
  nav_item(a(href="http://www.disabilitydatainitiative.org/databases/access", "Accessibility", target="_blank"))
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
    girafe(ggobj = plot, options = list(opts_hover(css = ''), opts_sizing(rescale = TRUE), opts_hover_inv(css = "opacity:0.1;"), opts_zoom(max = 10)))
  })
  
  output$table1 <- renderDT({
    ddi_2024_s %>% arrange(ISO3) %>% select(Region,Country,Summary) %>% datatable(filter = "top")
  })
  
  output$table2 <- renderDT({
    ddi_2024 %>% select(Region,Country,Dataset,Year,Notes,`WG-SS`,`Other functional difficulty questions`,`Difference from WG-SS`) %>% arrange(Dataset,Year,Notes) %>% 
      datatable(filter = "top", options = list(autoWidth = TRUE),
                caption = htmltools::tags$caption(style = "caption-side: bottom; text-align: left;",HTML("Notes: WG-SS stands for the Washington Group Short<br/>(1) - Yes/No answer<br/>(2) - Answer scale is different from that in the WG-SS<br/>(3) - Wording of questions is different from the WG-SS<br/>(4) - Does not have the selfcare domain<br/>(5) - Does not have the communication domain")))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
