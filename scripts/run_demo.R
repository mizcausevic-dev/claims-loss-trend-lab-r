source(file.path("src", "claims_loss_trend_lab.R"))

result <- build_dashboard()
cat("Scenario:", result$scenario_title, "\n")
cat("Generated:", result$generated_on, "\n")
cat("Total incurred:", result$total_incurred_m, "M\n")
cat("Average loss ratio:", result$avg_loss_ratio_pct, "%\n")
cat("Reserve gap:", result$reserve_gap_m, "M\n")
escalated <- result$lane_results$program[result$lane_results$status == "red"]
if (length(escalated) == 0) {
  escalated <- "none"
}
cat("Escalated programs:", paste(escalated, collapse = ", "), "\n")
