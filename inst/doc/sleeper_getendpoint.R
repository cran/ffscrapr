## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(ffscrapr)
library(dplyr)
library(purrr)
library(glue)

## -----------------------------------------------------------------------------

query <- glue::glue('players/nfl/trending/add')

query

response_trending <- sleeper_getendpoint(query)

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


