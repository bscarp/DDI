#!/usr/bin/env Rscript

library(plumber)

options_plumber(trailingSlash = TRUE)

cen_dir <- ifelse(
  Sys.info()[1] == "Windows",
  paste0(
    stringr::str_extract(getwd(), "[c,C]:\\/Users\\/.+?\\/"),
    "OneDrive/R/DDI/API/"
  ),
  "/usr/local/plumber/DS-E/"
)

api <- pr(paste0(cen_dir, "dse-api.R"))

pr() %>%
  pr_mount("/api", api) %>%
  pr_set_api_spec(function(spec) {
    spec$info <- list(
      title = "Disability Statistics – Estimates (DS-E) API",
      description = "This database includes national and subnational descriptive statistics based on the analysis and disaggregation of national population and housing censuses and household surveys.",
      termsOfService = "https://www.disabilitydatainitiative.org/citation/",
      contact = list(
        name = "DDI support",
        url = "https://www.disabilitydatainitiative.org/contact/",
        email = "disabilitydatainitiative.help@gmail.com"
      )
    )
    spec$tags <- list(
      list(name = "Main data", description = "API endpoints to retrieve data"),
      list(name = "Metadata", description = "Helper functions to use the API")
    )
    spec$paths[["/api/"]] <- NULL
    spec$paths[["/api/*"]] <- NULL
    spec$paths[["/api/cos"]] <- NULL
    spec$paths[["/api/bre"]] <- NULL
    spec$paths$`/api/cross`[["head"]] <- NULL
    spec$paths$`/api/within`[["head"]] <- NULL
    spec
  }) %>%
  pr_run(port = 4000, host = "127.0.0.1")
