library(DBI)
library(RSQLite)
library(dplyr)

results <- readRDS("holes_2025_raw.rds")

# Events that failed to download (NULL or 0 rows)
failed <- names(results)[sapply(results, function(x) is.null(x) || nrow(x) == 0)]
message("Events with no data: ", if (length(failed)) paste(failed, collapse = ", ") else "none")

# Stack all events into one table; failed events are skipped automatically
all_holes <- bind_rows(results, .id = "event_query")

con <- dbConnect(SQLite(), "pga_2025.sqlite")
dbWriteTable(con, "all_holes", all_holes, overwrite = TRUE)

# dbExecute runs one statement at a time, so split the SQL file on semicolons
sql <- paste(readLines("sql/analysis.sql"), collapse = "\n")
for (statement in strsplit(sql, ";")[[1]]) {
  if (nzchar(trimws(statement))) dbExecute(con, statement)
}

dbGetQuery(con, "SELECT COUNT(*) AS n_holes FROM analysis")
dbDisconnect(con)