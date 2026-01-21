
# DS-E Plumber

cen_dir = ifelse(
  Sys.info()[1] == "Windows",
  paste0(
    stringr::str_extract(getwd(), "[c,C]:\\/Users\\/.+?\\/"),
    "OneDrive/R/DDI/DS-E/"
  ),
  "/opt/shiny-server/samples/DS-E/"
)

# data0 = read_parquet(paste0(cen_dir, "data0.parquet"), as_data_frame = TRUE)
# data1 = read_parquet(paste0(cen_dir, "data1.parquet"), as_data_frame = TRUE)
# load(paste0(cen_dir, "Data.RData"))

# Define API calls

#* Return the cross country data
#* @param cos:[str] The selected countries
#* @param ind:[str] The selected indicator
#* @param pop:[str] The selected population group
#* @param dis:[str] The selected disability disaggregation
#* @get /cross
function(
  cos = c("Kenya", "South Africa", "Rwanda"),
  ind = c("Multidimensional poverty"),
  pop = c("All adults (ages 15 and older)"),
  dis = c("Disability", "No disability")
) {
  library(tidyr)
  library(duckplyr)
  temp = read_parquet_duckdb(
    paste0(cen_dir, "data0.parquet"),
    prudence = "stingy"
  ) %>%
    filter(
      Country %in% cos,
      IndicatorName %in% ind,
      PopulationName %in% pop,
      DifficultyName %in% dis
    ) %>%
    mutate(Value = Value / 100, Country = Country) %>%
    collect() %>%
    pivot_wider(
      names_from = c(DifficultyName),
      names_glue = "{DifficultyName}",
      values_from = Value
    ) %>%
    select(-c(admin, level))
  return(temp)
  gc()
}

#* Return the within country data
#* @param cou:[str] The selected countries
#* @param ind:[str] The selected indicator
#* @param pop:[str] The selected population group
#* @param dis:[str] The selected disability disaggregation
#* @param adm:[str] The selected admin level
#* @get /within
function(
  cou = c("Guatemala"),
  ind = c("Multidimensional poverty"),
  pop = c("All adults (ages 15 and older)"),
  dis = c("Disability"),
  adm = c("Subnational division 1")
) {
  library(tidyr)
  library(duckplyr)
  temp = read_parquet_duckdb(
    paste0(cen_dir, "data1.parquet"),
    prudence = "stingy"
  ) %>%
    filter(
      Country %in% cou,
      !is.na(level),
      PopulationName %in% pop,
      IndicatorName %in% ind,
      admin %in% unique(c("National", adm)),
      DifficultyName %in% dis
    ) %>%
    select(-c(Country, admin)) %>%
    mutate(Value = Value / 100) %>%
    collect() %>%
    pivot_wider(
      names_from = c(DifficultyName),
      names_glue = "{DifficultyName}",
      values_from = Value
    )
  return(temp)
  gc()
}

# redirect other requests
#* @get /*
#* @exclude
function(req, res) {
  res$status <- 307 # Set the HTTP status to 307 Temporary Redirect
  res$setHeader("Location", "/__docs__/") # Set the Location header with the new URL

  # Return a message (optional, as the browser will redirect)
  return(list(message = "Redirecting to /__docs__/"))
}
