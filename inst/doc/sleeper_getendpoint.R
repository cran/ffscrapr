## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
options(dplyr.summarise.inform = FALSE)
httptest::.mockPaths("../tests/testthat")
httptest::use_mock_api()


## ----setup, message = FALSE---------------------------------------------------
library(ffscrapr)
library(dplyr)
library(purrr)
library(glue)

## -----------------------------------------------------------------------------

type <- "add"

query <- glue::glue('players/nfl/trending/{type}')

query

response_trending <- sleeper_getendpoint(query,lookback_hours = 48, limit = 10)

str(response_trending, max.level = 1)

## -----------------------------------------------------------------------------

df_trending <- response_trending %>% 
  purrr::pluck("content") %>% 
  dplyr::bind_rows()

head(df_trending)

## -----------------------------------------------------------------------------

players <- sleeper_players() %>% 
  select(player_id, player_name, pos, team, age)

trending <- df_trending %>% 
  left_join(players, by = "player_id")

trending

## ----include = FALSE----------------------------------------------------------
httptest::stop_mocking()

