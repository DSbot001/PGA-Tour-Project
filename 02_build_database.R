library(DBI)
library(RSQLite)

# R loads API responses; SQL performs the analysis transformations.
results <- readRDS("holes_2025_raw.rds")
parts <- lapply(seq_along(results), function(i) {
  x <- results[[i]]
  if (is.null(x) || nrow(x) == 0) return(NULL)
  x <- as.data.frame(x)
  x$event_query <- names(results)[i]
  x
})
parts <- Filter(Negate(is.null), parts)
if (length(parts) == 0) stop("No saved hole data found.")
columns <- unique(unlist(lapply(parts, names)))
parts <- lapply(parts, function(x) {
  for (column in setdiff(columns, names(x))) x[[column]] <- NA
  x[columns]
})
all_holes <- do.call(rbind, parts)

con <- dbConnect(SQLite(), "pga_2025.sqlite")
tryCatch({
  dbWithTransaction(con, {
    dbWriteTable(con, "all_holes", all_holes, overwrite = TRUE)
    sql <- paste(readLines("sql/analysis.sql", warn = FALSE), collapse = "\n")
    # Statements in this file have no semicolons inside SQL strings/comments.
    for (statement in strsplit(sql, ";", fixed = TRUE)[[1]]) {
      if (nzchar(trimws(statement))) dbExecute(con, statement)
    }
  })
  print(dbGetQuery(con, "SELECT COUNT(*) AS n_holes FROM analysis"))
}, finally = dbDisconnect(con))
