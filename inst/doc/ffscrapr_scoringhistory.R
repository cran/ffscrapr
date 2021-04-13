## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

options(dplyr.summarise.inform = FALSE,
        rmarkdown.html_vignette.check_title = FALSE)

eval <- TRUE

tryCatch(expr = {
  
  download.file("https://github.com/dynastyprocess/ffscrapr-tests/archive/1.4.0.zip","f.zip")
  unzip('f.zip', exdir = ".")
  
  httptest::.mockPaths(new = "ffscrapr-tests-1.4.0")},
  warning = function(e) eval <<- FALSE,
  error = function(e) eval <<- FALSE)

httptest::use_mock_api()

