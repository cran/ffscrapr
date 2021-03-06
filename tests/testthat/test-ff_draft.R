with_mock_api({
  test_that("ff_draft returns a tibble for each platform currently programmed", {
    sfb_conn <- ff_connect("mfl", 65443, season = 2020)
    sfb_draftresults <- ff_draft(sfb_conn)

    expect_tibble(sfb_draftresults, min.rows = 100)

    ssb_conn <- ff_connect("mfl", 54040, season = 2020)
    ssb_draftresults <- ff_draft(ssb_conn)

    expect_tibble(ssb_draftresults, min.rows = 40)

    jml_conn <- ff_connect(platform = "sleeper", league_id = "522458773317046272", season = 2020)
    jml_draftresults <- ff_draft(jml_conn)

    expect_tibble(jml_draftresults, min.rows = 40)

    joe_conn <- fleaflicker_connect(season = 2020, league_id = 206154)
    joe_draftresults <- ff_draft(joe_conn)

    expect_tibble(joe_draftresults)
  })
})
