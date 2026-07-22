#DS-E API

cen_dir <- ifelse(
  Sys.info()[1] == "Windows",
  paste0(
    stringr::str_extract(getwd(), "[c,C]:\\/Users\\/.+?\\/"),
    "OneDrive/R/DDI/DS-E/"
  ),
  "/opt/shiny-server/samples/DS-E/"
)

ddi_match <- function(x, y) {
  sapply(
    x,
    function(z) y[which.min(adist(z, y, partial = TRUE))],
    USE.NAMES = FALSE
  )
}

load(paste0(cen_dir, "Data2.RData"))

# Define API calls

#* Cross-country disability statistics
#*
#* Return cross-country disability-disaggregated  statistics for one or more countries, indicators, and population groups.
#* Use this endpoint for comparisons across countries or for national level data for a single country.
#*
#* Before calling this endpoint, retrieve valid codes from:
#* - /api/cou (country names)
#* - /api/ind (indicator names)
#* - /api/pop (population groups)
#* - /api/dis (disability groups)
#* - /api/est (summary statistic types)
#*
#* <p>Example:<br>
#* https://www.disabilitydatainitiative.org/api/cross?cou=Kenya&cou=Rwanda&ind=Water&pop=Women&dis=No%20difficulty&dis=Some%20difficulty&est=mean
#* </p>
#*
#* @tag "Main data"
#* @param cou:[str] Country name. Use /api/cou to retrieve valid values.
#* @param ind:[str] Indicator name. Use /api/ind to retrieve valid values.
#* @param pop:[str] Population group. Use /api/pop to retrieve valid values.
#* @param dis:[str] Disability disaggregation. Use /api/dis to retrieve valid values.
#* @param est:[str] Summary statistic type. Use /api/est to retrieve valid values.
#* @param cos:[str] The  countries (deprecated)
#* @serializer json
#* @get /cross
function(
  cou = c("Kenya", "South Africa", "Rwanda"),
  ind = c("Multidimensional poverty"),
  pop = c("All adults (ages 15 and older)"),
  dis = c(
    "No difficulty",
    "Some difficulty",
    "A lot of difficulty/Cannot do at all"
  ),
  est = c("mean"),
  cos = ""
) {
  library(tidyr)
  library(duckplyr)

  if (!all(cos == "")) {
    cosf <- ddi_match(cos, df_country$label)
  }
  couf <- ddi_match(cou, df_country$label)

  if (!all(cos == "") & all(cou == c("Kenya", "South Africa", "Rwanda"))) {
    couf <- cosf
  } else if (
    !all(cos == "") & !all(cou == c("Kenya", "South Africa", "Rwanda"))
  ) {
    cosf <- c(couf, cosf)
  }

  ind2 <- ddi_match(ind, key_m$IndicatorName)
  indf <- expand.grid(ind2, est) %>% apply(1, paste, collapse = "_")

  popf <- ddi_match(pop, df_group$label)

  dis2 <- gsub("disability", "Difficulty", dis, ignore.case = TRUE)
  disf <- ddi_match(dis2, df_disability2$label)

  estf <- ddi_match(est, df_est)

  temp <- read_parquet_duckdb(
    paste0(cen_dir, "data.parquet"),
    prudence = "stingy"
  ) %>%
    filter(
      Country %in% couf,
      PopulationName %in% popf,
      DifficultyName %in% disf,
      admin == "National"
    ) %>%
    select(
      Country,
      PopulationName,
      admin,
      level,
      DifficultyName,
      any_of(indf)
    ) %>%
    select(-c(admin, level)) %>%
    collect() %>%
    pivot_longer(
      cols = any_of(indf),
      names_to = c("IndicatorName", "Estimate"),
      names_pattern = "(.*)_(.*)",
      values_to = "Value"
    )
  return(temp)
  gc()
}

#* Within-country disability statistics
#*
#* Return within-country disability-disaggregated  statistics for one or more countries, indicators, population groups, and subnational admin levels.
#* Use this endpoint for understanding within-countries differences.
#*
#* Before calling this endpoint, retrieve valid codes from:
#* - /api/cou (country names)
#* - /api/ind (indicator names)
#* - /api/pop (population groups)
#* - /api/dis (disability groups)
#* - /api/adm (subnational admin levels)
#* - /api/est (summary statistic types)
#*
#* <p>Example:<br>
#* https://www.disabilitydatainitiative.org/api/within?cos=Guatemala&ind=Multidimensional%20poverty&pop=All%20adults%20%28ages%2015%20and%20older%29&dis=Disability&adm=Subnational%20division%201&est=mean
#* </p>
#*
#* @tag "Main data"
#* @param cou:[str] The selected countries
#* @param ind:[str] The selected indicator
#* @param pop:[str] The selected population group
#* @param dis:[str] The selected disability disaggregation
#* @param adm:[str] The selected admin level
#* @param est:[str] The selected data type
#* @param cos:[str] The selected countries (deprecated)
#* @serializer json
#* @get /within
function(
  cou = c("Guatemala"),
  ind = c("Multidimensional poverty"),
  pop = c("All adults (ages 15 and older)"),
  dis = c("Disability"),
  adm = c("Subnational division 1"),
  est = c("mean"),
  cos = "",
  req
) {
  library(tidyr)
  library(duckplyr)

  if (!all(cos == "")) {
    cosf <- ddi_match(cos, df_country$label)
  }
  couf <- ddi_match(cou, df_country$label)

  if (!all(cos == "") & all(cou == c("Guatemala"))) {
    couf <- cosf
  } else if (!all(cos == "") & !all(cou == c("Guatemala"))) {
    couf <- c(couf, cosf)
  }

  ind2 <- ddi_match(ind, key_m$IndicatorName)
  indf <- expand.grid(ind2, est) %>% apply(1, paste, collapse = "_")

  popf <- ddi_match(pop, df_group$label)

  dis2 <- gsub("disability", "Difficulty", dis, ignore.case = TRUE)
  disf <- ddi_match(dis2, df_disability2$label)

  admf <- ddi_match(
    adm,
    c(
      "National",
      "Subnational division 1",
      "Subnational division 2",
      "Alternative subnational division"
    )
  )

  estf <- ddi_match(est, df_est)

  temp <- read_parquet_duckdb(
    paste0(cen_dir, "data.parquet"),
    prudence = "stingy"
  ) %>%
    filter(
      Country %in% couf,
      !is.na(level),
      PopulationName %in% popf,
      admin %in% unique(c("National", admf)),
      DifficultyName %in% disf
    ) %>%
    select(
      Country,
      level,
      ISOCode,
      DifficultyName,
      PopulationName,
      any_of(indf)
    ) %>%
    collect() %>%
    mutate(ISOCode = tolower(ISOCode)) %>%
    pivot_longer(
      cols = any_of(indf),
      names_to = c("IndicatorName", "Estimate"),
      names_pattern = "(.*)_(.*)",
      values_to = "Value"
    )
  return(temp)
  gc()
}

# API info calls

#* Country metadata
#*
#* Returns the list of valid country names used by the DDI APIs.
#* Call this endpoint before /api/cross or /api/within if you need valid values for `cou`.
#*
#* @tag Metadata
#* @serializer json
#* @get /cou
#* @get /cos
function() {
  return(df_country[sort(df_country$group, index.return = T)$ix, c(3, 2)])
}

#* Indicator metadata
#*
#* Returns the list of valid indicator names used by the DDI APIs.
#* Call this endpoint before /api/cross or /api/within if you need valid values for `ind`.
#*
#* @tag Metadata
#* @serializer json
#* @get /ind
function() {
  return(key_m[, c(1, 2)])
}

#* Population group metadata
#*
#* Returns the list of valid population groups used by the DDI APIs.
#* Call this endpoint before /api/cross or /api/within if you need valid values for `pop`.
#*
#* @tag Metadata
#* @serializer json
#* @get /pop
function() {
  return(df_group$value)
}

#* Disability group metadata
#*
#* Returns the list of valid disability severity/type options used by the DDI APIs.
#* Call this endpoint before /api/cross or /api/within if you need valid values for `dis`.
#*
#* @tag Metadata
#* @serializer json
#* @get /dis
function() {
  return(df_disability2$value)
}

#* Estimate metadata
#*
#* Returns the list of valid summary statistic types used by the DDI APIs.
#* Call this endpoint before /api/cross or /api/within if you need valid values for `est`.
#*
#* @tag Metadata
#* @serializer json
#* @get /est
function() {
  return(c("mean", "se", "n"))
}

#* Subnational level metadata
#*
#* Returns the list of valid subnational level options used by the DDI APIs.
#* Call this endpoint before /api/within if you need valid values for `adm`.
#*
#* @tag Metadata
#* @serializer json
#* @get /adm
function() {
  return(c(
    "National",
    "Subnational division 1",
    "Subnational division 2",
    "Alternative subnational division"
  ))
}

#* Disability breakdown metadata
#*
#* Returns the list of valid disability breakdowns used by the DDI website.
#* This helper function is not used by the main API endpoints
#*
#* @tag Metadata
#* @serializer json
#* @get /bre
function() {
  return(df_disability$label)
}

#* @head /cross
#* @head /within
function(...) {
  return(NULL)
}

# # redirect base url requests
#* @get /
#* @head /
function(req, res) {
  res$status <- 301 # Set the HTTP status to 307 Temporary Redirect
  res$setHeader("Location", "/__docs__/") # Set the Location header with the new URL

  # Return a message (optional, as the browser will redirect)
  return(list(message = "Redirecting to /__docs__/"))
}

# # redirect other requests
#* @get /*
#* @head /*
function(req, res) {
  res$status <- 301 # Set the HTTP status to 307 Temporary Redirect
  res$setHeader("Location", "/__docs__/") # Set the Location header with the new URL

  # Return a message (optional, as the browser will redirect)
  return(list(message = "Redirecting to /__docs__/"))
}
