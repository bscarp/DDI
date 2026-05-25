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
library(shinyWidgets)
library(shiny.i18n)
library(tidyverse)
library(ggiraph)
library(DT)
library(sf)

load("Data.RData")

i18n <- Translator$new(translation_csvs_path = ".")
i18n$set_translation_language("en") # here you select the default translation to display

sf_use_s2(use_s2 = FALSE)

# Define UI for application that draws a histogram
ui <- page_navbar(
  title = "Disability Statistics Database (DS-QR)",
  theme = bs_theme(
    bootswatch = "flatly",
    primary = "#0072B5",
    secondary = "#E9ECEF"
  ) |>
    bs_add_rules(
      list(
        ".header {text-align: center; padding: 20px;}",
        ".filter-area {display: flex; justify-content: center; gap: 20px; margin-top: 20px;}",
        ".data-area {padding: 20px; margin: auto;}",
        ".card {margin: 15px; padding: 20px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); border-radius: 8px;}",
        ".download-btn {background-color: #0072B5; color: white; border: none; margin-top: 10px; width: 200px;}"
      )
    ),

  # Landing page
  nav_item(a(
    usei18n(i18n),
    href = "https://ds-qr.disabilitydatainitiative.org",
    i18n$t("Home")
  )),

  sidebar = sidebar(
    usei18n(i18n),
    title = i18n$t("Select a Language"),
    virtualSelectInput(
      "selected_language",
      NULL,
      choices = prepare_choices(df_lang, label, value),
      selected = i18n$get_key_translation()
    )
  ),

  nav_panel(
    title = i18n$t("Overview of Results"),

    # Map and Table side by side
    navset_card_pill(
      nav_panel(
        title = h5(i18n$t("Map of Disability Questions by Country")),
        layout_sidebar(
          full_screen = TRUE,
          sidebar = sidebar(
            title = i18n$t("Region"),
            virtualSelectInput(
              "region",
              NULL,
              choices = prepare_choices(df_region, label, value),
              selected = "World"
            )
          ),
          h4(
            style = "text-align: center;",
            i18n$t(
              "Do the datasets reviewed in each country include functional difficulty questions?"
            )
          ),
          girafeOutput("map", width = "100%")
        )
      ),
      nav_panel(
        h5(i18n$t("Table of Disability Questions by Country")),
        div(
          div(
            style = "align-items: center; margin: auto; width: 100%; max-width: 1600px;",
            h4(
              style = "text-align: center;",
              i18n$t(
                "Do the datasets reviewed in each country include functional difficulty questions?"
              )
            ),
            DTOutput("table1")
          ),
          #downloadButton(" ", "Download Table", class = "download-btn", style = "margin-top: 20px;")
        )
      )
    )
  ),

  nav_panel(
    title = i18n$t("Detailed results"),
    # Data table
    div(
      class = "data-area",
      style = "align-items: center; text-align: center; padding: 20px;",
      div(style = "width: 100%;", DTOutput("table2")),
      #downloadButton(" ", "Download Table", class = "download-btn", style = "margin-top: 20px;")
    )
  ),
  nav_item(a(
    href = "https://www.disabilitydatainitiative.org/accessibility",
    i18n$t("Accessibility"),
    target = "_blank"
  )),

  nav_panel(
    value = 'citation',
    i18n$t("Citation"),
    div(
      style = "display: flex; flex-direction: column; align-items: left; margin: auto; width: 100%; max-width: 1600px;",
      h4(i18n$t(
        "By using the Data, you agree to provide attribution to the DDI. Electronic publications will include a hyperlink to https://ds-e.disabilitydatainitiative.org/. Publications, whether printed, electronic or broadcast, based wholly or in part on the Data, will cite the source as follows:"
      )),
      h4(em(i18n$t(
        "DDI. Disability Statistics – Questionnaire Review Database (DS-QR Database). Disability Data Initiative collective. Fordham University: New York, USA. 2025."
      ))),
      h4(i18n$t("For the full terms and conditions, click the link below:")),
      a(
        href = "https://www.disabilitydatainitiative.org/data-use-agreement-for-the-disability-data-initiatives-disability-statistics-estimates-database/",
        i18n$t("Terms and conditions"),
        target = "_blank"
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(session, input, output) {
  session$allowReconnect(TRUE)

  i18n_r = reactive({
    i18n
  })

  observeEvent(input$selected_language, {
    print(paste("Language change!", input$selected_language))
    update_lang(input$selected_language, session)
  })

  #Translate region
  observe({
    temp = input$region
    temp2 = df_region %>% mutate(label = i18n_r()$t(label))
    updateVirtualSelect(
      "region",
      choices = prepare_choices(temp2, label, value),
      selected = temp,
      session = session
    )
  })

  data_sel_map = reactive({
    if (input$region == "World") {
      map_df
    } else if (input$region == "East Asia & Pacific") {
      map_df %>% st_crop(xmin = 80, xmax = 180, ymin = -90, ymax = 60)
    } else if (input$region == "Europe & Central Asia") {
      map_df %>% st_crop(xmin = -20, xmax = 45, ymin = 30, ymax = 73)
    } else if (input$region == "Latin America & Caribbean") {
      map_df %>% st_crop(xmin = -100, xmax = -30, ymin = -60, ymax = 30)
    } else if (input$region == "Middle East & North Africa") {
      map_df %>% st_crop(xmin = -20, xmax = 70, ymin = 10, ymax = 40)
    } else if (input$region == "North America") {
      map_df %>% st_crop(xmin = -180, xmax = -50, ymin = 10, ymax = 90)
    } else if (input$region == "South Asia") {
      map_df %>% st_crop(xmin = 60, xmax = 100, ymin = 5, ymax = 40)
    } else if (input$region == "Sub-Saharan Africa") {
      map_df %>% st_crop(xmin = -20, xmax = 55, ymin = -40, ymax = 30)
    }
  })

  output$map <- renderGirafe({
    map = left_join(data_sel_map(), ddi_2025_s, by = join_by(ISO3)) %>%
      mutate(
        Summary = factor(
          if_else(is.na(Summary), "Not assessed", Summary),
          levels = c(
            "Washington Group Short Set",
            "Other functional difficulty questions",
            "No functional difficulty questions",
            "Not assessed"
          ),
          labels = i18n_r()$t(c(
            "Washington Group Short Set",
            "Other functional difficulty questions",
            "No functional difficulty questions",
            "Not assessed"
          ))
        )
      )
    plot = ggplot(data = map) +
      geom_sf_interactive(
        aes(
          fill = Summary,
          tooltip = paste0(i18n_r()$t(NAME), "\n", Summary)
        ),
        colour = "black"
      ) +
      labs(fill = "") +
      scale_fill_manual_interactive(
        values = c("green4", "steelblue", "firebrick", "grey40"),
        labels = label_wrap_gen(17)
      ) +
      theme(legend.position = "bottom")
    girafe(
      ggobj = plot,
      options = list(
        opts_hover(css = ''),
        opts_sizing(rescale = TRUE),
        opts_hover_inv(css = "opacity:0.1;"),
        opts_zoom(max = 10)
      )
    )
  })

  output$table1 <- renderDT({
    ddi_2025_s %>%
      arrange(ISO3) %>%
      select(Region, Country, Summary) %>%
      mutate(
        Region = factor(
          Region,
          levels = levels(Region),
          labels = i18n_r()$t(levels(Region))
        ),
        Country = factor(
          Country,
          levels = levels(Country),
          labels = i18n_r()$t(levels(Country))
        ),
        Summary = factor(
          Summary,
          levels = levels(Summary),
          labels = i18n_r()$t(levels(Summary))
        )
      ) %>%
      datatable(filter = "top")
  })

  output$table2 <- renderDT({
    ddi_2025 %>%
      select(
        Region,
        Country,
        Dataset,
        Year,
        Notes,
        `WG-SS`,
        `Other functional difficulty questions`,
        `Difference of Other functional difficulty questions versus WG-SS`
      ) %>%
      mutate(
        Region = factor(
          Region,
          levels = levels(Region),
          labels = i18n_r()$t(levels(Region))
        ),
        Country = factor(
          Country,
          levels = levels(Country),
          labels = i18n_r()$t(levels(Country))
        ),
        `WG-SS` = factor(
          `WG-SS`,
          levels = levels(`WG-SS`),
          labels = i18n_r()$t(levels(`WG-SS`))
        ),
        `Other functional difficulty questions` = factor(
          `Other functional difficulty questions`,
          levels = levels(`Other functional difficulty questions`),
          labels = i18n_r()$t(levels(`Other functional difficulty questions`))
        )
      ) %>%
      arrange(Dataset, Year, Notes) %>%
      datatable(
        filter = "top",
        options = list(autoWidth = TRUE),
        caption = htmltools::tags$caption(
          style = "caption-side: bottom; text-align: left;",
          HTML(paste0(
            i18n_r()$t(
              "Notes: WG-SS stands for the Washington Group Short"
            ),
            "<br/>",
            i18n_r()$t(
              "(1) - Yes/No answer; (2) - Answer scale is different from that in the WG-SS; (3) - Wording of questions is different from the WG-SS; (4) - Does not have the selfcare domain; (5) - Does not have the communication domain"
            )
          ))
        )
      )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
