## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(ffscrapr)

## -----------------------------------------------------------------------------
conn <- mfl_connect(season = 2020)

conn

## -----------------------------------------------------------------------------
sfb_search <- mfl_getendpoint(conn,endpoint = "leagueSearch", SEARCH = "sfbx conference")

## -----------------------------------------------------------------------------

search_results <- sfb_search %>% 
  purrr::pluck("content","leagues","league") %>% 
  tibble::tibble() %>% 
  tidyr::unnest_wider(1)

head(search_results)


## -----------------------------------------------------------------------------

fog <- mfl_connect(season = 2019, league_id = 12608)

fog_tradebait <- mfl_getendpoint(fog, "tradeBait", INCLUDE_DRAFT_PICKS = 1) %>% 
  purrr::pluck("content","tradeBaits","tradeBait") %>% 
  tibble::tibble() %>% 
  tidyr::unnest_wider(1) %>% 
  tidyr::separate_rows("willGiveUp",sep = ",") %>% 
  dplyr::mutate(timestamp = lubridate::as_datetime(as.numeric(timestamp))) %>% 
  dplyr::left_join(
    ff_franchises(fog) %>% dplyr::select("franchise_id","franchise_name"),
    by = c("franchise_id")
  ) %>% 
  dplyr::left_join(
    mfl_players() %>% dplyr::select("player_id","player_name","pos","age","team"),
    by = c("willGiveUp" = "player_id")
  )

head(fog_tradebait)

