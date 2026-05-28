source(file.path("src", "claims_loss_trend_lab.R"))

result <- build_dashboard()

stopifnot(result$total_incurred_m > 0)
stopifnot(result$reserve_gap_m > 0)
stopifnot(nrow(result$lane_results) == 4)
stopifnot(any(result$lane_results$status == "red"))
stopifnot(all(c("program", "loss_ratio_pct", "reserve_gap_m") %in% names(result$lane_results)))

cat("All tests passed.\n")
