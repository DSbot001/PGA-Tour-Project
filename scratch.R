source("02_build_database.R")
con <- DBI::dbConnect(RSQLite::SQLite(), "pga_2025.sqlite")
tryCatch({
  print(DBI::dbGetQuery(con, "
    SELECT prev_birdie, COUNT(*) AS n, AVG(to_par) AS mean_next
    FROM analysis WHERE prev_birdie IS NOT NULL
    GROUP BY prev_birdie ORDER BY prev_birdie
  "))
}, finally = DBI::dbDisconnect(con))
