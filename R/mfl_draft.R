#### ff_draft (MFL) ####

#' Get Draft Results
#'
#' @param conn a conn object created by \code{ff_connect()}
#' @param custom_players MFL: TRUE or FALSE - retrieve custom players from the MFL database? (Allows for devy, placeholder picks, slightly slower)
#' @param ... args for other methods
#'
#' @examples
#' \donttest{
#' ssb_conn <- ff_connect(platform = "mfl", league_id = 54040, season = 2020)
#' ff_draft(ssb_conn)
#' }
#'
#' @describeIn ff_draft MFL: returns a table of drafts for the current year - can handle devy/startup-rookie-picks by specifying custom_players (slower!)
#'
#' @export
ff_draft.mfl_conn <- function(conn, custom_players = FALSE, ...) {

  # Notes on draft endpoint: "draft unit" can dictate handling of whether it's a "league" or "division" based draft

  stopifnot(is.logical(custom_players))

  players_endpoint <- if (custom_players) {
    mfl_players(conn)
  } else {
    mfl_players()
  }

  players_endpoint <- players_endpoint %>%
    dplyr::select("player_id", "player_name", "pos", "team", "age")

  raw_draftresults <- mfl_getendpoint(conn, "draftResults") %>%
    purrr::pluck("content", "draftResults", "draftUnit")

  if (!is.null(raw_draftresults$unit) && raw_draftresults$unit == "LEAGUE") {
    df_draftresults <- .mfl_parse_draftunit(raw_draftresults)

    if (is.null(df_draftresults)) {
      return(NULL)
    }

    df_draftresults <- df_draftresults %>%
      dplyr::left_join(
        ff_franchises(conn) %>%
          dplyr::select("franchise_id", "franchise_name"),
        by = c("franchise_id")
      ) %>%
      dplyr::left_join(
        players_endpoint,
        by = c("player_id")
      ) %>%
      dplyr::transmute(
        "timestamp" = lubridate::as_datetime(as.numeric(.data$timestamp)),
        .data$round,
        .data$pick,
        .data$franchise_id,
        .data$franchise_name,
        .data$player_id,
        .data$player_name,
        .data$pos,
        .data$age,
        .data$team
      )
  } else {
    df_draftresults <- purrr::map_df(raw_draftresults, .mfl_parse_draftunit)

    if (is.null(df_draftresults)) {
      return(NULL)
    }

    df_draftresults <- df_draftresults %>%
      dplyr::left_join(
        ff_franchises(conn) %>%
          dplyr::select("franchise_id", "division", "division_name", "franchise_name"),
        by = c("franchise_id")
      ) %>%
      dplyr::left_join(
        players_endpoint,
        by = c("player_id")
      ) %>%
      dplyr::transmute(
        "timestamp" = lubridate::as_datetime(as.numeric(.data$timestamp)),
        .data$division,
        .data$division_name,
        .data$round,
        .data$pick,
        .data$franchise_id,
        .data$franchise_name,
        .data$player_id,
        .data$player_name,
        .data$pos,
        .data$age,
        .data$team
      )
  }

  return(df_draftresults)
}

#' @noRd
.mfl_parse_draftunit <- function(raw_draftresults) {
  df_1 <- raw_draftresults %>%
    purrr::pluck("draftPick")

  if (is.null(df_1)) {
    return(NULL)
  }

  df_1 %>%
    tibble::tibble() %>%
    tidyr::unnest_wider(1) %>%
    dplyr::rename(
      "franchise_id" = .data$franchise,
      "player_id" = .data$player
    )
}
