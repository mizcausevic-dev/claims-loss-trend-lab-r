source(file.path("src", "claims_loss_trend_lab.R"))

result <- build_dashboard()
write_site(result)

required_paths <- c(
  "site/index.html",
  "site/loss-lane/index.html",
  "site/trend-matrix/index.html",
  "site/reserve-posture/index.html",
  "site/verification/index.html",
  "site/docs/index.html",
  "site/robots.txt",
  "site/sitemap.xml"
)

missing <- required_paths[!file.exists(required_paths)]
if (length(missing) > 0) {
  stop(sprintf("Missing generated paths: %s", paste(missing, collapse = ", ")))
}

root_html <- paste(readLines("site/index.html", warn = FALSE), collapse = "\n")
for (needle in c("Claims loss trend lab", "/reserve-posture/", "insurance / insurtech")) {
  if (!grepl(needle, root_html, fixed = TRUE)) {
    stop(sprintf("Expected keyword missing from root HTML: %s", needle))
  }
}

cat("Smoke check passed.\n")
