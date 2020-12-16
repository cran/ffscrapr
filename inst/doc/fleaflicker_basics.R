## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
options(dplyr.summarise.inform = FALSE)

httptest::.mockPaths("../tests/testthat")
httptest::use_mock_api()

## ----setup, message=FALSE-----------------------------------------------------
  library(ffscrapr)
  library(dplyr)
  library(tidyr)

## -----------------------------------------------------------------------------
aaa <- fleaflicker_connect(season = 2020, league_id = 312861)

aaa

## -----------------------------------------------------------------------------

aaa_summary <- ff_league(aaa)

str(aaa_summary)

## -----------------------------------------------------------------------------
aaa_rosters <- ff_rosters(aaa)

head(aaa_rosters)

## -----------------------------------------------------------------------------
player_values <- dp_values("values-players.csv")

# The values are stored by fantasypros ID since that's where the data comes from. 
# To join it to our rosters, we'll need playerID mappings.

player_ids <- dp_playerids() %>% 
  select(sportradar_id,fantasypros_id) %>% 
  filter(!is.na(sportradar_id),!is.na(fantasypros_id))

# We'll be joining it onto rosters, so we can trim down the values dataframe
# to just IDs, age, and values

player_values <- player_values %>% 
  left_join(player_ids, by = c("fp_id" = "fantasypros_id")) %>% 
  select(sportradar_id,age,ecr_1qb,ecr_pos,value_1qb)

# ff_rosters() will return the sportradar_id, which we can then match to our player values!

aaa_values <- aaa_rosters %>% 
  left_join(player_values, by = c("sportradar_id"="sportradar_id")) %>% 
  arrange(franchise_id,desc(value_1qb))

head(aaa_values)

## -----------------------------------------------------------------------------
value_summary <- aaa_values %>% 
  group_by(franchise_id,franchise_name,pos) %>% 
  summarise(total_value = sum(value_1qb,na.rm = TRUE)) %>%
  ungroup() %>% 
  group_by(franchise_id,franchise_name) %>% 
  mutate(team_value = sum(total_value)) %>% 
  ungroup() %>% 
  pivot_wider(names_from = pos, values_from = total_value) %>% 
  arrange(desc(team_value)) %>% 
  select(franchise_id,franchise_name,team_value,QB,RB,WR,TE)

value_summary

## -----------------------------------------------------------------------------
value_summary_pct <- value_summary %>% 
  mutate_at(c("team_value","QB","RB","WR","TE"),~.x/sum(.x)) %>% 
  mutate_at(c("team_value","QB","RB","WR","TE"),round, 3)

value_summary_pct

## -----------------------------------------------------------------------------
age_summary <- aaa_values %>% 
  filter(pos %in% c("QB","RB","WR","TE")) %>% 
  group_by(franchise_id,pos) %>% 
  mutate(position_value = sum(value_1qb,na.rm=TRUE)) %>% 
  ungroup() %>% 
  mutate(weighted_age = age*value_1qb/position_value,
         weighted_age = round(weighted_age, 1)) %>% 
  group_by(franchise_id,franchise_name,pos) %>% 
  summarise(count = n(),
            age = sum(weighted_age,na.rm = TRUE)) %>% 
  pivot_wider(names_from = pos,
              values_from = c(age,count))

age_summary

## ----include = FALSE----------------------------------------------------------
httptest::stop_mocking()

