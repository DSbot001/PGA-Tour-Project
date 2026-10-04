# PGA Tour Momentum

The 2025 hole data is downloaded with R/golfastr, transformed with SQLite SQL,
and prepared for later Python modeling.

## Run

Open the RStudio project and install `DBI` and `RSQLite` if needed. From the
project directory, run:

```r
source("02_build_database.R")
```

This loads `holes_2025_raw.rds` into `pga_2025.sqlite` and rebuilds the views in
`sql/analysis.sql`. Render `PGA Tour Project.qmd` to review SQL diagnostics.
The saved raw data is sufficient; downloading again is optional.

Python can read the features using:

```python
import sqlite3
import pandas as pd
with sqlite3.connect("pga_2025.sqlite") as con:
    analysis = pd.read_sql_query("SELECT * FROM analysis", con)
```

The eligibility rule and lag reset at each nine match the original pipeline.
`prev_birdie` includes birdie or better. Course keys use hole-ordered par
sequences, which may not uniquely identify courses. Hole-number order does not
establish actual playing order. Undefined difficulty/skill values are NULL.
