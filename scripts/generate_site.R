source(file.path("src", "claims_loss_trend_lab.R"))

result <- build_dashboard()
write_site(result)
cat("Generated site at", normalizePath("site", winslash = "/", mustWork = FALSE), "\n")
