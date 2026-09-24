
library(dplyr)

results <- readRDS("holes_2025_raw.rds")
all_holes <- bind_rows(results, .id = "event_query")

exclude <- c("Zurich Classic of New Orleans",
             "PGA TOUR Q-School presented by Korn Ferry",
             "Hero World Challenge")

clean <- all_holes |> filter(!event_query %in% exclude)

par_seq <- clean |>
  arrange(player_id, tournament_id, round, hole) |>
  group_by(event_query, round, player_id) |>
  summarise(seq = paste(par, collapse = ""), .groups = "drop")

multi <- par_seq |>
  group_by(event_query, round) |>
  summarise(n_courses = n_distinct(seq), .groups = "drop") |>
  filter(n_courses > 1)

print(multi, n = Inf)
nrow(multi)

clean |>
  count(event_query, round, player_id, name = "n_holes") |>
  count(n_holes, name = "n_player_rounds") |>
  arrange(desc(n_player_rounds)) |>
  print(n = 20)

clean |>
  filter(round == 5) |>
  count(event_query, round, name = "n_rows")

complete_rounds <- clean |>
  filter(round <= 4) |>
  group_by(event_query, round, player_id) |>
  filter(n() == 18) |>
  ungroup()

nrow(complete_rounds)

complete_rounds |>
  arrange(player_id, tournament_id, round, hole) |>
  group_by(event_query, round, player_id) |>
  summarise(seq = paste(par, collapse = ""), .groups = "drop") |>
  group_by(event_query, round) |>
  summarise(n_courses = n_distinct(seq), .groups = "drop") |>
  filter(n_courses > 1) |>
  print(n = Inf)


complete_rounds <- complete_rounds |>
  group_by(event_query, round, player_id) |>
  mutate(course_key = paste(par, collapse = "")) |>
  ungroup()


library(dplyr)

analysis <- complete_rounds |>
  group_by(event_query, round, player_id) |>
  mutate(course_key = paste(par, collapse = "")) |>
  ungroup() |>
  mutate(to_par = score - par,
         nine = if_else(hole <= 9, 1L, 2L))

analysis <- analysis |>
  arrange(player_id, tournament_id, round, hole) |>
  group_by(player_id, tournament_id, round, nine) |>
  mutate(prev_to_par = lag(to_par, order_by = hole),
         prev_birdie = as.integer(prev_to_par <= -1)) |>
  ungroup()

sum(is.na(analysis$prev_to_par))
nrow(analysis)

analysis <- analysis |>
  group_by(event_query, round, course_key, hole) |>
  mutate(n_field = n(),
         hole_diff = (sum(to_par) - to_par) / (n_field - 1)) |>
  ungroup()

analysis <- analysis |>
  group_by(player_id) |>
  mutate(tot_sum = sum(to_par), tot_n = n()) |>
  group_by(player_id, event_query) |>
  mutate(player_skill = (tot_sum - sum(to_par)) / (tot_n - n())) |>
  ungroup()


summary(analysis$hole_diff)
summary(analysis$player_skill)
sum(is.infinite(analysis$player_skill) | is.nan(analysis$player_skill))


analysis |>
  filter(!is.na(prev_birdie)) |>
  group_by(prev_birdie) |>
  summarise(n = n(), mean_next = mean(to_par))
