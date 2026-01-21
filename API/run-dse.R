#!/usr/bin/env Rscript

library(plumber)

cen_dir = ifelse(
  Sys.info()[1] == "Windows",
  paste0(
    stringr::str_extract(getwd(), "[c,C]:\\/Users\\/.+?\\/"),
    "OneDrive/R/DDI/API/"
  ),
  "/usr/local/plumber/DS-E/"
)

host = ifelse(
  Sys.info()[1] == "Windows",
  "127.0.0.1",
  "127.0.0.1"
)

api = pr(paste0(cen_dir, "dse-api.R"))

print(api$endpoints)

pr() %>%
  pr_mount("/api", api) %>%
  pr_run(port = 4000, host = host)
