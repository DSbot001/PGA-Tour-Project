library(golfastr)

# Try each year: does a schedule exist, and can we get hole-by-hole data
# for at least one event? Uses top_n = 5 so each check is fast.
check_year <- function(yr) {
  sched <- tryCatch(load_schedule(yr), error = function(e) NULL)
  if (is.null(sched) || nrow(sched) == 0) {
    return(data.frame(season = yr, n_events = 0, holes_ok = FALSE))
  }

  lb     <- tryCatch(load_leaderboard(yr), error = function(e) NULL)
  events <- if (!is.null(lb)) unique(lb$tournament_name) else character(0)

  holes_ok <- FALSE
  for (e in head(events, 3)) {           # try up to 3 events
    h <- tryCatch(load_holes(yr, e, top_n = 5), error = function(err) NULL)
    if (!is.null(h) && nrow(h) > 0) { holes_ok <- TRUE; break }
  }

  data.frame(season = yr, n_events = length(events), holes_ok = holes_ok)
}

availability <- do.call(rbind, lapply(2015:2026, check_year))
print(availability)

