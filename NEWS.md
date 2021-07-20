# ffscrapr (development version)

The main goal of v1.4.4 is to patch minor bugs and to add some minor extensions such as an HTML cleaning function. v1.4.4 is also served from a different github organization and website domain.

## Minor changes

- `mfl_getendpoint()` and similar get_endpoint functions have an improved print method that tells you whether the request was successful.
- Added errorhandling for ESPN methods of `ff_starters()`, `ff_transactions()`, `ff_rosters()`, `espn_potentialpoints()`, `ff_draft()`. Fixes #297, thanks for the report @jpiburn!
- Added message to warn if memoise is turned off, onAttach.
- `ff_transactions()` now correctly handles leagues using waiver priority, fixes #299 - thanks for the report @BarkovMVP!
- `ff_league()` for Sleeper now identifies best ball leagues, fixes #300
- `ff_scoring()` for MFL now has a `points_type` column that is either "each" or "once" - this helps delineate fantasy points awarded for meeting thresholds/bonuses from points awarded per-stat, fixes #301 
- `ff_scoringhistory()` for MFL applies the new `ff_scoring()` `points_type` column to calculate scoring history. This should result in more sensible results for leagues with bonus scoring! Fixes #301. 
- Add more mismatch names (Michael -> Mike Vick, Chris Wells -> Beanie Wells) 
- Add `dp_clean_html()` to clean html from names (cough MFL cough) 
- `ff_starter_positions()` now handles a "range" inside of the total_starters column for MFL, resolves #304
- Cutover to ffverse.com domain and github organization

---

# ffscrapr 1.4.3

The main goal of v1.4.3 is to patch some minor bugs.

## Minor changes

- `ff_league()` now has a column that returns the platform's season - this is most useful when running ff_league in batch. Thank you to @joeflan for the contribution!  (Fixes #287)
- Added helper script in dev/ for switching between test cache versions.
- Added helper script in dev/ for rebuilding test cache.
- `ff_schedule()` for Sleeper now should extend into playoff weeks. (Fixes #289) 
- `ff_draft()` for Sleeper now has an auction_amount column if it is an auction draft. (Fixes #291)
- `dp_cleannames()` now can flip names originally presented in LastName, FirstName order into First Last, and also has a custom name database to convert common alternate names to a unified one.
- `nflfastr_stat_mapping` and `dp_name_mapping` are namespaced within the package, so that they can be used internally and externally a little more robustly.
- Rebuilt test cache in ffscrapr-tests.

---

# ffscrapr 1.4.2

The main goal of v1.4.2 is to patch some minor bugs.

## Minor changes

- `espn_rosters` now has a `week` argument to return a specific week of data. (Fixes #276, thanks @scottfrechette!)
- `ff_scoringhistory` now tries to return a platform-specific player ID, where available. (Fixes #275)
- Roxygen configured to use markdown (with the roxygen2md package) - hopefully fixes the lifecycle badge issues?
- `sleeper_players()` - gsis_id gets `str_squish` applied to it to resolve some stowaway whitespaces.
- `mfl_players()` - add `any_of` handling for columns to handle column name changes.
- `sleeper_transactions` now handles offseason transactions correctly

---

# ffscrapr 1.4.1

The main goal of v1.4.1 is to patch some issues raised by CRAN checks and also correct some bugs in the new experimental `ff_scoringhistory` and `ff_starter_positions` functions released in v1.4.0. 

## New features

- `nflfastr_stat_mapping` is a dataframe that maps nflfastr columns to fantasy scoring rules, and is now exported for end-user usage. It is primarily used inside of `ff_scoringhistory()`.

## Minor changes

- Added `release_questions` to help remind me to maintain test infrastructure
- `mfl_starter_positions` now correctly calculates offensive starters (first via "iop_starters" if defined and then otherwise by subtracting idp starters) as well as kdst_starters (Resolves #264)
- Redirected nflfastr download functions to the new nflverse/ repository locations. (Resolves #268)
- `.ffscrapr_env` relocated from being a child of the base environment to being a child of the empty environment (Resolves #269)
- `ff_scoringhistory` refactored and adds better support for MFL's fumbles and firstdowns. (Resolves #265)

---

# ffscrapr 1.4.0

The main goal of v1.4.0 is to add preliminary support for connecting ffscrapr to nflfastR weekly data, and to clean up bugs from v1.3.0. Huge thanks goes to [Joe Sydlowski](https://twitter.com/JoeSydlowskiFF) for his contributions on scoring history (and everything else DynastyProcess!)

## New Features
- `nflfastr_weekly()` imports weekly offensive statistics from nflfastR's [data repository](https://github.com/nflverse/nflfastR-data).
- `nflfastr_rosters()` imports team rosters from nflfastR's [roster repository](https://github.com/nflverse/nflfastR-roster).
- `ff_scoringhistory()` connects your league's scoring settings to the nflfastr data (c/o the functions above), and allows you to reconstruct historical scoring for your league!
- `ff_starter_positions()` describes the starter rules for each player/position, including min and max starters at each position accounting for flex spots. This should be useful for calculating things like value over replacement!

## Breaking Changes
- `ff_scoring` for ESPN loses the "override_pos" which only had a value of 16 for D/ST specific rules
- `ff_scoring` rules for ESPN and Sleeper have been expanded from one line per rule to one line per position per rule

## Minor Changes

- Force `mfl_playerscores` to use season + league specific players call where possible (#239)
- Reduce minimum rows for `flea_rosters` test to 200, which fixes an API check issue (#242)
- Switching memoise backend to cachem package, fixes CRAN check issue where digest is no longer imported by memoise. Cachem also apparently more performant! (#244)
- `sleeper_transactions` now correctly handles multiple dropped players in one transaction. (#246).
- `mfl_transactions` - adds numeric string parsing to fix bug in auction bid amount (#)
-  `mfl_draft` now calculates age as of timestamp and also adds an overall column. (#259, #260)

---

# ffscrapr 1.3.0

The main goal of ffscrapr 1.3.0 is to add support for the ESPN platform. It also includes several bug fixes, code quality improvements, and a major refactor of tests to reduce overall package size. 

A huge thank-you goes to [Tony ElHabr](https://twitter.com/TonyElHabr) for his contributions to the package for the ESPN methods.

### Breaking Changes

- `custom_players` arguments are deprecated for MFL - it will now return them by default. 

### ESPN Details
 
ESPN is a tricky and undocumented API. Private leagues are accessible if you use the SWID/ESPN_S2 authentication arguments, which are a lot like API keys - see the ESPN authentication vignette.

Unsupported functions: 

- `ff_draftpicks()` - this does not apply to ESPN primarily because it does not support draft pick trades. 
- `ff_userleagues()` - ESPN does not support looking up user's leagues, even when authenticated
- Username and password features - ESPN used to have a way to authenticate via username/password, but this has been recently [made more difficult](https://github.com/cwendt94/espn-api/discussions/128). It is an area that can be revisited if/when the Python package manages it, but at this time will only be accessible with the SWID/ESPN_S2 keys. 

### New Functions

- `dp_cleannames()` is a utility function for cleaning player names that removes common suffixes, periods, and apostrophes.
- `espn_potentialpoints()` calculates the optimal lineup for each week. This is 

### Minor patches

- Converted GET requests to use `httr::RETRY` instead - this adds some robustness for server-side issues. As suggested by Maelle Salmon's blog post on [not reinventing the wheel](https://blog.r-hub.io/2020/04/07/retry-wheel/).
- Added some type conversions and renaming for snake_case consistency to mfl_rosters and mfl_playerscores
- Fixed bug in MFL's `ff_playerscores()` function so that it correctly pulls older names. (Resolves #196)
- Refactored all tests to move test cache files to a separate/non-package location (https://github.com/ffverse/ffscrapr-tests) - so that it is not included in CRAN's package sizing
- Fixed bugs in MFL's `ff_starters()` function - bad default arg, bad players call. (Fixes #202)
- Resolve MFL's playerscores to handle vectorized request (Fixes #206)
- Resolve bugs related to .fn_choose_season for tests (Fixes #217, #219)
- Resolved bug in MFL's `ff_rosters()` by adding a week parameter (Fixes #215)
- Coerced `ff_transactions()` bid_amount into a numeric (Fixes #210)
- Removed bye franchises from `ff_starters()` (Fixes #212)

---

# ffscrapr 1.2.2

Minor patches to dp_import functions to address issues discovered by CRAN checks. 

~~Also adds minor helper function, `dp_cleannames()`, which is a utility function for cleaning player names that removes common suffixes, periods, and apostrophes.~~ 

Messed up the export here, whoops. Fixing for next release.

### Minor patches
-  Refactored `dp_values()` and `dp_playerids()` functions to use httr backend for compat with httptest, preventing CRAN errors.
- Added inst-level redactor for httptest. 

---

# ffscrapr 1.2.1

### Minor patches

-   Caching vignette outputs in tests/testthat to making vignette-rebuilding less internet reliant
-   Changing the league_id output of `sleeper_userleagues` to be a character column (because of cran no-longdouble support)

---

# ffscrapr 1.2.0

The main goal of ffscrapr 1.2.0 is to add a full set of methods for Fleaflicker. This release also adds improved caching options, including writing to your filesystem for persistent caching (see the vignette!), and one hotfix for sleeper_getendpoint.

### BREAKING CHANGES

-   `sleeper_getendpoint()` now behaves more like the other getendpoint functions - first argument is the endpoint and any further args are passed as query parameters.

### Other tweaks to existing platforms/methods

-   Small copyedits to existing vignettes.
-   Added filesystem cache capabilities and a vignette to detailing how to use it.

### Fleaflicker notes

All functions now have Fleaflicker methods! Here are notes about what ***isn't*** the same:

-   `fleaflicker_players()` requires a connection/leagueID by default - acts a little oddly on game days as of right now.
-   `ff_playerscores()` - Fleaflicker's API returns season level data easily, week-level is not readily available yet without some workarounds. Everything else seems to be okay.

---

# ffscrapr 1.1.0

The main goal of ffscrapr 1.1.0 is to add a full set of methods for Sleeper. Also adds two new generics: `ff_userleagues()` and `ff_starters()`.

### New generic functions

Here is a list of new functions available at the top level (ie for all platforms)

-   `ff_userleagues()` returns a list of user leagues. This is deployed slightly differently for MFL and Sleeper - MFL requires authentication to access user's leagues, while Sleeper doesn't have authentication so you can look up any user you like.
-   `ff_starters()` returns a list of players started/not-started each week. MFL will return the actual score of each player each week and calculate whether they were optimal, while Sleeper just returns the player themselves.

### Sleeper notes

Almost all functions now have Sleeper methods - implemented in what hopes to be relatively familiar manner to MFL. Outlining the specifics of what ***isn't*** the same:

-   `sleeper_userleagues()` is a wrapper on `ff_userleagues()` that makes it easier to look up user leagues without first creating a connection object.
-   `ff_playerscores()` is not available for Sleeper because Sleeper removed the player stats endpoint - it will generate a warning (rather than an error). Thinking about creating some functions to calculate scoring based on [nflfastr](https://www.nflfastr.com/).
-   `sleeper_getendpoint()` is a little more simple than MFL's equivalent - just pass a string url (minus api.sleeper.app/v1) or pass in chunks of code, the function will automatically paste them together with "/".
-   Added generic and method for `ff_userleagues()` - Sleeper league IDs are more annoying than MFL to handle, so the more intuitive way is to look up the user's league_ids by username first. MFL does have a parallel feature even if used for different purposes.
-   Added two vignettes, showing "Getting Started" as well as one for custom API calls

### MFL changes

-   Added method for `ff_userleagues()`
-   Added handling for offensive_points and defensive_points in `ff_standings()` (\#69, nice.)
-   Added `ff_starters()` as requested by \#76 (thanks, Mike!)
-   Added an `httr::handle_reset()` call to fix login-caching bug.
-   Polished vignettes a little.

### Other release tweaks in 1.1.0

-   Now uses {checkmate} for testing.
-   Silently swallowing up unused args in mfl_connect and sleeper_connect.
-   Uses describeIn instead of rdname for method documentation.
-   Wrap all documentation examples in donttest - ratelimiting AND running in under 5 seconds each is pretty challenging!

---

# ffscrapr 1.0.0

This is the first (major) version of ffscrapr and it is intended to build out the full set of functions for the first API platform: MFL.

Future versions will add more platforms via methods mapped to the same functions.

Functions include: 

- `ff_connect` (and sibling `mfl_connect`) to establish connection parameters and ratelimiting 
- `mfl_getendpoint` as a low-level function for making GET requests from MFL 
- `ff_draft` gets draft results 
- `ff_draftpicks` gets current and future draft picks that have not yet been selected 
- `ff_franchises` gets franchise-level identifiers and divisions 
- `ff_league` gets league-level summaries of rules, players, and franchises 
- `ff_playerscores` gets playerweek-level scores 
- `ff_rosters` gets franchise-level rosters complete with naming 
- `ff_schedule` gets weekly fantasy schedules 
- `ff_scoring` gets scoring rules 
- `ff_standings` gets league-level season summaries 
- `ff_transactions` gets a list of all transactions and cleans them into a data frame.
