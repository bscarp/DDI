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
library(shiny.i18n)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggiraph)
library(DT)
library(sf)
library(arrow)


data0 = read_parquet("data0.parquet", as_data_frame = FALSE)
data1 = read_parquet("data1.parquet", as_data_frame = FALSE)
map_df = read_sf("map_df.shp")
load("Data.RData")

i18n <- Translator$new(translation_csvs_path = ".")
i18n$set_translation_language("en") # here you select the default translation to display

print("Data loaded")

# Define UI for application that draws a histogram
ui <- page_navbar(
  id = "nav",
  title = "Disability Statistics Database (DS-E)",
  theme = bs_theme(
    bootswatch = "flatly",
    primary = "#0072B5",
    secondary = "#E9ECEF"
  ) |>
    bs_add_rules(
      list(
        ".header {text-align: center; padding: 20px;}",
        ".filter-area {display: flex; justify-content: center; gap: 20px; margin-top: 20px;}",
        ".data-area {padding: 20px; max-width: 1200px; margin: auto;}",
        ".card {margin: 15px; padding: 20px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); border-radius: 8px;}",
        ".download-btn {background-color: #0072B5; color: white; border: none; margin-top: 10px; width: 200px;}"
      )
    ),

  # Landing page
  nav_item(a(
    href = "https://ds-e.disabilitydatainitiative.org",
    i18n$t("Home")
  )),

  #Selectors
  sidebar = sidebar(
    id = "sidebar",
    title = tagList(shiny.i18n::usei18n(i18n), ""),
    accordion(
      open = FALSE,
      accordion_panel(
        title = i18n$t("Language"),
        value = "Language",
        virtualSelectInput(
          "selected_language",
          NULL,
          choices = prepare_choices(df_lang, label, value),
          selected = i18n$get_key_translation(),
          keepAlwaysOpen = TRUE
        )
      ),
      conditionalPanel(
        condition = "input.nav == 'across'",
        accordion_panel(
          title = i18n$t("Countries (select multiple)"),
          value = "Countries (select multiple)",
          virtualSelectInput(
            "country",
            NULL,
            choices = prepare_choices(df_country, label, value, group),
            multiple = TRUE,
            search = TRUE,
            selected = c("South Africa", "Kenya", "Uganda"),
            keepAlwaysOpen = TRUE,
            popupDropboxBreakpoint = "500px"
          ),
          actionLink("selectall", i18n$t("Select all countries")),
          actionLink("reset", i18n$t("Reset countries"))
        ),
        ns = NS(NULL)
      ),
      conditionalPanel(
        condition = "input.nav == 'within'",
        accordion_panel(
          title = i18n$t("Country (select single)"),
          value = "Country (select single)",
          virtualSelectInput(
            "country_sin",
            NULL,
            choices = prepare_choices(df_country, label, value, group),
            search = TRUE,
            selected = "Guatemala",
            keepAlwaysOpen = TRUE,
            popupDropboxBreakpoint = "500px"
          )
        ),
        ns = NS(NULL)
      ),
      div(
        style = "text-align: right;",
        dropdownButton(
          i18n$t(
            "The Methods tab above has definitions and details about breakdowns"
          ),
          status = 'info',
          icon = icon('info')
        )
      ),
      conditionalPanel(
        condition = "input.nav == 'within' & input.h2 == 't4'",
        accordion_panel(
          title = i18n$t("Select the subnational level"),
          value = "Select the subnational level",
          virtualSelectInput(
            "admin",
            NULL,
            c(
              "Subnational division 1",
              "Subnational division 2",
              "Alternative subnational division"
            ),
            search = TRUE,
            selected = "Subnational division 1",
            keepAlwaysOpen = TRUE,
            popupDropboxBreakpoint = "500px"
          )
        ),
        ns = NS(NULL)
      ),
      conditionalPanel(
        condition = "input.nav != 'citation'",
        accordion_panel(
          title = i18n$t("Indicators"),
          value = "Indicators",
          virtualSelectInput(
            "indicator",
            NULL,
            prepare_choices(
              key_m,
              IndicatorName,
              IndicatorName,
              Group,
              alias = Original
            ),
            search = TRUE,
            selected = "Multidimensional poverty",
            position = "auto",
            keepAlwaysOpen = TRUE,
            popupDropboxBreakpoint = "500px"
          )
        ),
        ns = NS(NULL)
      ),
      conditionalPanel(
        condition = "input.nav != 'citation'",
        accordion_panel(
          title = i18n$t("Population Groups"),
          value = "Population Groups",
          virtualSelectInput(
            "group",
            NULL,
            choices = prepare_choices(df_group, label, value),
            selected = "All adults (ages 15 and older)",
            keepAlwaysOpen = TRUE,
            popupDropboxBreakpoint = "500px"
          )
        ),
        ns = NS(NULL)
      ),
      conditionalPanel(
        condition = "input.nav == 'across' | (input.nav == 'within' & input.h2 == 't4')",
        accordion_panel(
          title = i18n$t("Disability breakdown"),
          value = "Disability breakdown",
          virtualSelectInput(
            "disability",
            NULL,
            choices = prepare_choices(df_disability, label, value),
            selected = 1,
            keepAlwaysOpen = TRUE,
            popupDropboxBreakpoint = "500px"
          )
        ),
        ns = NS(NULL)
      ),
      conditionalPanel(
        condition = "input.nav == 'within' & input.h2 == 't3'",
        accordion_panel(
          title = i18n$t("Disability group"),
          value = "Disability group",
          virtualSelectInput(
            "disability2",
            NULL,
            choices = prepare_choices(df_disability2, label, value),
            selected = "Disability",
            keepAlwaysOpen = TRUE,
            popupDropboxBreakpoint = "500px"
          )
        ),
        ns = NS(NULL)
      ),
      #conditionalPanel(condition = "input.nav == 'within' & input.h2 == 't3'", accordion_panel(title = i18n$t("Other disability group"), value =  "Other disability group", virtualSelectInput("disability3", NULL, choices = prepare_choices(df_disability2, label, value), selected = "No disability", keepAlwaysOpen = TRUE, popupDropboxBreakpoint = "500px")), ns = NS(NULL)),
      conditionalPanel(
        condition = "input.nav == 'within' & input.h2 == 't3'",
        accordion_panel(
          title = i18n$t("Indicator scale"),
          value = "Indicator scale",
          noUiSliderInput("scale", NULL, min = 0, max = 100, c(0, 100))
        ),
        ns = NS(NULL)
      ),
      conditionalPanel(
        condition = "input.nav == 'across' & input.h1 == 't1'",
        accordion_panel(
          title = i18n$t("Pick a colour theme"),
          value = "Pick a colour theme",
          virtualSelectInput(
            "colour1",
            NULL,
            choices = c("Viridis" = 1, "Turbo" = 2, "Plasma" = 3),
            selected = 2,
            keepAlwaysOpen = TRUE,
            popupDropboxBreakpoint = "500px"
          )
        ),
        ns = NS(NULL)
      ),
      conditionalPanel(
        condition = paste(
          "input.nav == 'within' & input.h2 == 't3' & [",
          paste(
            paste(
              "'",
              key_m$IndicatorName[!is.na(key_m$Direction)],
              "'",
              sep = ""
            ),
            collapse = ","
          ),
          "].includes(input.indicator)",
          sep = ""
        ),
        accordion_panel(
          title = i18n$t("Pick a colour theme"),
          value = "Pick a colour theme",
          virtualSelectInput(
            "colour2",
            NULL,
            choices = c("Viridis" = 1, "Mako" = 2, "Rocket" = 3),
            selected = 3,
            keepAlwaysOpen = TRUE,
            popupDropboxBreakpoint = "500px"
          )
        ),
        ns = NS(NULL)
      ),
      conditionalPanel(
        condition = paste(
          "input.nav == 'within' & input.h2 == 't3' & [",
          paste(
            paste(
              "'",
              key_m$IndicatorName[is.na(key_m$Direction)],
              "'",
              sep = ""
            ),
            collapse = ","
          ),
          "].includes(input.indicator)",
          sep = ""
        ),
        accordion_panel(
          title = i18n$t("Pick a colour theme"),
          value = "Pick a colour theme",
          virtualSelectInput(
            "colour3",
            NULL,
            choices = c("Viridis" = 1, "Mako" = 2, "Rocket" = 3),
            selected = 2,
            keepAlwaysOpen = TRUE,
            popupDropboxBreakpoint = "500px"
          )
        ),
        ns = NS(NULL)
      )
    )
  ),
  nav_panel(
    i18n$t("Cross-country estimates"),
    value = "across",
    navset_card_underline(
      id = "h1",
      nav_panel(
        value = 't1',
        i18n$t("Graph"),
        h4(textOutput("title1")),
        h6(textOutput("key1")),
        h6(textOutput("ind1")),
        girafeOutput("stat_top_gra")
      ),
      nav_panel(
        value = 't2',
        i18n$t("Table"),
        h4(textOutput("title2")),
        h6(textOutput("key2")),
        h6(textOutput("ind2")),
        DTOutput("stat_top_tab")
      )
    )
  ),
  nav_panel(
    i18n$t("Estimates within countries"),
    value = "within",
    navset_card_underline(
      id = "h2",
      nav_panel(
        value = 't3',
        i18n$t("Map"),
        h4(textOutput("title3")),
        textOutput("ind3"),
        girafeOutput("stat_cou_map")
      ),
      nav_panel(
        value = 't4',
        i18n$t("Table"),
        h4(textOutput("title4")),
        textOutput("ind4"),
        DTOutput("stat_cou_tab")
      )
    )
  ),
  nav_item(a(
    href = "https://www.disabilitydatainitiative.org/ds-e-methods",
    i18n$t("Methods"),
    target = "_blank"
  )),
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
        "DDI. Disability Statistics – Estimates Database (DS-E Database). Disability Data Initiative collective. Fordham University: New York, USA. 2024."
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
    # This print is just for demonstration
    print(paste("Language change!", input$selected_language))
    # Here is where we update language in session
    update_lang(input$selected_language, session)
    # updateVirtualSelect("indicator", choices = key_m %>% mutate(label = i18n_r()$t(IndicatorName)) %>% prepare_choices(label, IndicatorName, Group, alias = Original), session = session)
    # updateVirtualSelect("admin", choices = i18n_r()$t(), session = session)
    # updateVirtualSelect("group", choices = i18n_r()$t(), session = session)
    # updateVirtualSelect("disability", choices = i18n_r()$t(), session = session)
    # updateVirtualSelect("disability2", choices = i18n_r()$t(), session = session)
    # updateVirtualSelect("disability3", choices = i18n_r()$t(), session = session)
  })

  #Select all countries
  observe({
    if (input$selectall == 0) {
      return(NULL)
    } else {
      updateVirtualSelect(
        "country",
        selected = df_country$value,
        session = session
      )
      updateActionLink(session, "selectall")
    }
  })

  #Reset countries
  observe({
    if (input$reset == 0) {
      return(NULL)
    } else {
      updateVirtualSelect(
        "country",
        selected = c("South Africa", "Kenya", "Uganda"),
        session = session
      )
    }
  })

  #Change country based on country_sin
  # observe({
  #   updateVirtualSelect("country", selected = input$country_sin, session = session)
  # })

  #Translate countries
  observe({
    temp = input$country
    temp2 = df_country %>%
      mutate(label = i18n_r()$t(label), group = i18n_r()$t(group))
    updateVirtualSelect(
      "country",
      choices = prepare_choices(temp2, label, value, group),
      selected = temp,
      session = session
    )
  })
  observe({
    temp = input$country_sin
    temp2 = df_country %>%
      mutate(label = i18n_r()$t(label), group = i18n_r()$t(group))
    updateVirtualSelect(
      "country_sin",
      choices = prepare_choices(temp2, label, value, group),
      selected = temp,
      session = session
    )
  })

  #Change categories for admin selector
  observe({
    temp = if_else(
      input$admin %in%
        df_country2$admin[df_country2$Country %in% input$country_sin],
      input$admin,
      i18n_r()$t("Subnational division 1")
    )
    temp2 = df_country2 %>%
      filter(Country %in% input$country_sin) %>%
      select(admin) %>%
      setNames("value") %>%
      mutate(label = i18n_r()$t(value))
    updateVirtualSelect(
      "admin",
      choices = prepare_choices(temp2, label, value),
      selected = temp,
      session = session
    )
  })

  #Change categories for indicator selector
  observe({
    temp = input$indicator
    updateVirtualSelect(
      "indicator",
      choices = key_m %>%
        mutate(label = i18n_r()$t(IndicatorName)) %>%
        prepare_choices(label, IndicatorName, Group, alias = Original),
      disabledChoices = df_static %>%
        filter(Country %in% input$country) %>%
        summarise(min = min(min), .by = IndicatorName) %>%
        filter(min == "Inf") %>%
        pull(IndicatorName),
      selected = temp,
      session = session
    )
  })

  #Change categories for grouping selector
  observe({
    temp = input$group
    if (grepl("higher", input$indicator)) {
      temp = sub("Adults ages 15 to 29", "Adults ages 25 to 29", temp)
      temp2 = df_group2
    } else if (
      input$disability == 4 & !input$indicator == "Adults with disabilities"
    ) {
      temp = df_group$value[1]
      temp2 = df_group[1, ]
    } else if (input$indicator == "Households with disabilities") {
      temp = if_else(grepl("Adults ages", temp), df_group$value[1], temp)
      temp2 = df_group[c(1, 4, 5), ]
    } else {
      temp = sub("Adults ages 25 to 29", "Adults ages 15 to 29", temp)
      temp2 = df_group
    }
    temp2 = temp2 %>% mutate(label = i18n_r()$t(label))
    updateVirtualSelect(
      "group",
      choices = prepare_choices(temp2, label, value),
      selected = temp,
      session = session
    )
  })

  #Change categories for disability selector
  observe({
    temp = input$disability
    if (input$indicator == "Households with disabilities") {
      temp = ifelse(temp == 4, 1, temp)
      temp2 = df_disability[1:3, ]
    } else {
      temp2 = df_disability
    }
    temp2 = temp2 %>% mutate(label = i18n_r()$t(label))
    updateVirtualSelect(
      "disability",
      choices = prepare_choices(temp2, label, value),
      selected = temp,
      session = session
    )
  })

  #Change categories for disability selector
  observe({
    temp = input$disability2
    if (input$indicator == "Households with disabilities") {
      temp = ifelse(temp %in% df_disability2[4:9, ], df_disability2[1, ], temp)
      temp2 = df_disability2[c(1:3, 10:11), ]
    } else {
      temp2 = df_disability2
    }
    temp2 = temp2 %>% mutate(label = i18n_r()$t(label))
    updateVirtualSelect(
      "disability2",
      choices = prepare_choices(temp2, label, value),
      selected = temp,
      session = session
    )
  })

  #Change categories for other disability selector
  observe({
    temp = input$disability3
    if (input$indicator == "Households with disabilities") {
      temp = ifelse(temp %in% df_disability2[4:9, ], df_disability2[10, ], temp)
      temp2 = df_disability2[c(1:3, 10:11), ]
    } else {
      temp2 = df_disability2
    }
    temp2 = temp2 %>% mutate(label = i18n_r()$t(label))
    updateVirtualSelect(
      "disability3",
      choices = prepare_choices(temp2, label, value),
      selected = temp,
      session = session
    )
  })

  #Change colour for figures ("Light", "Dark", "Accent")
  coloura = reactive({
    case_when(
      input$colour1 == 1 ~ "viridis",
      input$colour1 == 2 ~ "turbo",
      input$colour1 == 3 ~ "plasma"
    )
  })

  #Change colour for maps ("Red to blue" = 1, "Brown to blue" = 2, "Purple to green" = 3) or ("Blue", "Brown", "Green")
  colourb = reactive({
    case_when(
      input$colour2 == 1 &
        !is.na(key_m$Direction[key_m$IndicatorName == input$indicator]) ~
        "viridis",
      input$colour2 == 2 &
        !is.na(key_m$Direction[key_m$IndicatorName == input$indicator]) ~
        "mako",
      input$colour2 == 3 &
        !is.na(key_m$Direction[key_m$IndicatorName == input$indicator]) ~
        "rocket",
      input$colour3 == 1 &
        is.na(key_m$Direction[key_m$IndicatorName == input$indicator]) ~
        "viridis",
      input$colour3 == 2 &
        is.na(key_m$Direction[key_m$IndicatorName == input$indicator]) ~
        "mako",
      input$colour3 == 3 &
        is.na(key_m$Direction[key_m$IndicatorName == input$indicator]) ~
        "rocket"
    )
  })

  #Change direction for map colour
  directiona = reactive({
    if_else(
      isFALSE(key_m$Direction[key_m$IndicatorName == input$indicator]),
      1,
      -1
    )
  })

  #Change direction for map colour
  directionb = reactive({
    if_else(
      is.na(key_m$Direction[key_m$IndicatorName == input$indicator]),
      "seq",
      "div"
    )
  })

  # process inputs to filter data
  dis_grp = reactive({
    unlist(case_when(
      input$disability == 1 &
        grepl("disab", input$indicator, ignore.case = TRUE) ~
        list(c("Disability")),
      input$disability == 2 &
        grepl("disab", input$indicator, ignore.case = TRUE) ~
        list(c("Moderate disability", "Severe disability")),
      input$disability == 3 &
        grepl("disab", input$indicator, ignore.case = TRUE) ~
        list(c("Severe disability")),
      input$disability == 4 &
        grepl("disab", input$indicator, ignore.case = TRUE) ~
        list(c(
          "Seeing disability",
          "Hearing disability",
          "Mobility disability",
          "Cognition disability",
          "Self-care disability",
          "Communication disability"
        )),
      input$disability == 1 ~ list(c("No disability", "Disability")),
      input$disability == 2 ~
        list(c("No disability", "Moderate disability", "Severe disability")),
      input$disability == 3 ~
        list(c("No and moderate disability", "Severe disability")),
      input$disability == 4 ~
        list(c(
          "Seeing disability",
          "Hearing disability",
          "Mobility disability",
          "Cognition disability",
          "Self-care disability",
          "Communication disability",
          "No disability"
        ))
    ))
  })

  adm_grp = reactive({
    unlist(case_when(
      input$admin == "National" ~ list(c("National")),
      input$admin == "Subnational division 1" ~
        list(c("National", "Subnational division 1")),
      input$admin == "Subnational division 2" ~
        list(c("National", "Subnational division 2")),
      input$admin == "Alternative subnational division" ~
        list(c("National", "Alternative subnational division"))
    ))
  })

  data_sel0 = reactive({
    data0 %>%
      filter(
        Country %in% input$country,
        IndicatorName == input$indicator,
        PopulationName == input$group
      ) %>%
      collect() %>%
      filter(DifficultyName %in% dis_grp()) %>%
      mutate(DifficultyName = factor(DifficultyName, levels = dis_grp()))
  })
  data_sel1_p1 = reactive({
    data1 %>% filter(Country == input$country_sin, !is.na(level))
  })
  data_sel1_p2 = reactive({
    data_sel1_p1() %>% filter(PopulationName == input$group)
  })
  data_sel1 = reactive({
    data_sel1_p2() %>% filter(IndicatorName == input$indicator) %>% collect()
  })
  # data_sel1 = reactive({data1 %>% filter(Country == input$country_sin, IndicatorName == input$indicator, PopulationName == input$group, admin %in% adm_grp(), DifficultyName %in% dis_grp()) %>% select(-c(Country,admin))})
  # data_sel2 = reactive({data1 %>% filter(Country == input$country_sin, IndicatorName == input$indicator, PopulationName == input$group, admin == "Subnational division 1", DifficultyName == input$disability2)})

  output$title1 <- renderText({
    paste(
      i18n_r()$t("Graph showing"),
      i18n_r()$t(input$indicator),
      i18n_r()$t("for"),
      ifelse(
        length(input$country) == 1,
        i18n_r()$t(input$country),
        paste(length(i18n_r()$t(input$country)), i18n_r()$t("countries"))
      ),
      i18n_r()$t("by"),
      paste0(i18n_r()$t(dis_grp()), collapse = ", ")
    )
  })

  output$title2 <- renderText({
    paste(
      i18n_r()$t("Table showing"),
      i18n_r()$t(input$indicator),
      i18n_r()$t("for"),
      ifelse(
        length(input$country) == 1,
        i18n_r()$t(input$country),
        paste(length(i18n_r()$t(input$country)), i18n_r()$t("countries"))
      ),
      i18n_r()$t("by"),
      paste0(i18n_r()$t(dis_grp()), collapse = ", ")
    )
  })

  output$title3 <- renderText({
    paste(
      i18n_r()$t("Map showing"),
      i18n_r()$t(input$indicator),
      i18n_r()$t("for"),
      i18n_r()$t(input$country_sin),
      i18n_r()$t("for"),
      i18n_r()$t(input$disability2)
    )
  })

  output$title4 <- renderText({
    paste(
      i18n_r()$t("Table showing"),
      i18n_r()$t(input$indicator),
      i18n_r()$t("for"),
      i18n_r()$t(input$country_sin),
      i18n_r()$t("at"),
      i18n_r()$t(input$admin),
      i18n_r()$t("by"),
      paste0(i18n_r()$t(dis_grp()), collapse = ", ")
    )
  })

  output$key1 <- output$key2 <- renderText({
    key_m %>%
      filter(IndicatorName == input$indicator) %>%
      pull(`Key message`) %>%
      i18n_r()$t() %>%
      paste(i18n_r()$t("Key message:"), .)
  })

  output$ind1 <- output$ind2 <- output$ind3 <- output$ind4 <- renderText({
    key_m %>%
      filter(IndicatorName == input$indicator) %>%
      pull(Tooltip) %>%
      i18n_r()$t() %>%
      paste(i18n_r()$t("Indicator definition:"), .)
  })

  output$stat_top_gra <- renderGirafe({
    # draw the plot using data
    data_g = data_sel0() %>%
      mutate(
        Country = i18n_r()$t(Country),
        DifficultyName = factor(
          DifficultyName,
          levels(DifficultyName),
          i18n_r()$t(levels(DifficultyName))
        ),
        label = paste0(
          Country,
          "\n",
          DifficultyName,
          "\n",
          if_else(
            is.na(Value),
            i18n_r()$t("Insufficient Sample Size"),
            paste0(round(Value, 1), "%")
          )
        )
      )
    plot = ggplot(data = data_g) +
      geom_col_interactive(
        mapping = aes(
          y = Value,
          x = Country,
          fill = DifficultyName,
          tooltip = label,
          data_id = Country
        ),
        position = "dodge"
      ) +
      scale_y_continuous(
        name = NULL,
        labels = scales::label_percent(scale = 1),
        limits = c(0, 100)
      ) +
      labs(
        caption = ifelse(
          length(input$country) > 3,
          i18n_r()$t("Data source(s): See table for source list"),
          source_all()
        )
      ) +
      scale_fill_viridis_d(option = coloura(), end = 0.95) +
      theme(
        axis.title = element_blank(),
        legend.title = element_blank(),
        legend.position = "bottom",
        legend.key.size = unit(2, "cm"),
        legend.key.spacing = unit(5, "mm"),
        text = element_text(size = 60),
        axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
        plot.caption = element_text(size = 40, margin = margin(t = 20)),
        plot.caption.position = "plot"
      )
    girafe(
      ggobj = plot,
      width_svg = 2 * length(dis_grp()) + 18,
      height_svg = 20,
      options = list(
        opts_hover(css = ''),
        opts_sizing(rescale = TRUE),
        opts_hover_inv(css = "opacity:0.1;")
      )
    )
  })

  output$stat_top_tab <- renderDT({
    # draw the plot using data
    data_sel0() %>%
      mutate(Value = Value / 100, Country = i18n_r()$t(Country)) %>%
      pivot_wider(
        names_from = c(IndicatorName, DifficultyName, PopulationName),
        names_glue = "{DifficultyName}",
        values_from = Value
      ) %>%
      select(-c(admin, level)) %>%
      datatable(
        .,
        colnames = i18n_r()$t(names(.)),
        caption = htmltools::tags$caption(
          style = "caption-side: bottom; text-align: left;",
          HTML(paste0(
            source_all(),
            "<br/>",
            i18n_r()$t(
              "A blank cell indicates that the estimate is not available."
            )
          ))
        )
      ) %>%
      formatPercentage(columns = dis_grp(), digits = 1)
  })

  output$stat_cou_map <- renderGirafe({
    data_m = data_sel1() %>%
      filter(
        admin == "Subnational division 1",
        DifficultyName == input$disability2
      ) %>%
      mutate(
        level = gsub("'", "&#39;", level),
        label = paste0(
          level,
          "\n",
          if_else(
            is.na(Value),
            i18n_r()$t("Insufficient Sample Size"),
            paste0(round(Value, 1), "%")
          )
        )
      )
    map <- inner_join(map_df, data_m, by = join_by(iso_3166_2 == ISOCode))
    plot1 = ggplot(data = map) +
      geom_sf_interactive(
        aes(fill = Value, tooltip = label, data_id = level),
        colour = "black"
      ) +
      scale_fill_viridis_c(
        name = NULL,
        labels = scales::label_percent(scale = 1),
        limits = c(0, 100),
        values = c(input$scale[1] / 100, input$scale[2] / 100),
        option = colourb(),
        direction = directiona()
      ) +
      labs(caption = source_sin()) +
      theme(
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        legend.key.size = unit(3, "cm"),
        text = element_text(size = 60),
        plot.caption = element_text(size = 40, margin = margin(t = 20)),
        plot.caption.position = "plot"
      )
    girafe(
      ggobj = plot1,
      width_svg = 20,
      height_svg = 20,
      options = list(
        opts_hover(css = ''),
        opts_sizing(rescale = TRUE),
        opts_hover_inv(css = "opacity:0.1;"),
        opts_zoom(max = 10)
      )
    )
  })

  output$stat_cou_tab <- renderDT({
    data_t = data_sel1() %>%
      mutate(level = i18n_r()$t(level)) %>%
      filter(admin %in% adm_grp(), DifficultyName %in% dis_grp()) %>%
      select(-c(Country, admin))
    # draw the plot using data
    data_t %>%
      mutate(Value = Value / 100) %>%
      pivot_wider(
        names_from = c(IndicatorName, DifficultyName, PopulationName),
        names_glue = "{DifficultyName}",
        values_from = Value
      ) %>%
      datatable(
        .,
        colnames = i18n_r()$t(sub(
          "level",
          "Level",
          sub("ISOCode", "ISO Code", names(.))
        )),
        caption = htmltools::tags$caption(
          style = "caption-side: bottom; text-align: left;",
          HTML(paste0(
            source_sin(),
            "<br/>",
            i18n_r()$t(
              "A blank cell indicates that the estimate is not available."
            )
          ))
        )
      ) %>%
      formatPercentage(columns = dis_grp(), digits = 1)
  })

  observe({
    temp = df_static %>%
      filter(Country == input$country_sin, IndicatorName == input$indicator)
    updateNoUiSliderInput(
      session = session,
      "scale",
      value = c(temp$min, temp$max),
      range = c(0, 100)
    )
  })

  source_all = reactive({
    df_static %>%
      filter(Country %in% input$country, IndicatorName == input$indicator) %>%
      pull(source) %>%
      sub("_", " ", .) %>%
      sub("_", " ", .) %>%
      sub("_", "-", .) %>%
      i18n_r()$t() %>%
      paste0(collapse = ", ") %>%
      paste(i18n_r()$t("Data source(s):"), .)
  })

  source_sin = reactive({
    df_static %>%
      filter(Country == input$country_sin, IndicatorName == input$indicator) %>%
      pull(source) %>%
      sub("_", " ", .) %>%
      sub("_", " ", .) %>%
      sub("_", "-", .) %>%
      i18n_r()$t() %>%
      paste(i18n_r()$t("Data source:"), .)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
