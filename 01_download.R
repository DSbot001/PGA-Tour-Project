library(golfastr)

lb <- load_leaderboard(2025)
events <- unique(lb$tournament_name)

results <- lapply(events, function(e) {
  tryCatch(load_holes(2025, e),
           error = function(err) { message("skip: ", e); NULL })
})
names(results) <- events
saveRDS(results, "holes_2025_raw.rds")
