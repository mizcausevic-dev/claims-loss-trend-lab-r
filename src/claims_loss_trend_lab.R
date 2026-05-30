# SPDX-License-Identifier: AGPL-3.0-or-later

html_escape <- function(text) {
  text <- as.character(text)
  text <- gsub("&", "&amp;", text, fixed = TRUE)
  text <- gsub("<", "&lt;", text, fixed = TRUE)
  text <- gsub(">", "&gt;", text, fixed = TRUE)
  text <- gsub('"', "&quot;", text, fixed = TRUE)
  text
}

sample_scenario <- function() {
  data.frame(
    lane_id = c("CL-11", "CL-18", "CL-24", "CL-31"),
    program = c("Commercial auto", "Property catastrophe", "Group disability", "Cyber liability"),
    open_claims = c(184, 61, 93, 48),
    incurred_loss_m = c(12.6, 18.2, 7.9, 9.4),
    expected_ultimate_m = c(14.2, 23.7, 8.8, 11.6),
    current_reserve_m = c(12.9, 19.8, 8.1, 9.8),
    prior_q_loss_ratio_pct = c(71, 84, 67, 73),
    current_q_loss_ratio_pct = c(79, 96, 74, 88),
    appeals_backlog = c(9, 4, 12, 7),
    reopen_rate_pct = c(4.1, 6.9, 5.2, 7.4),
    stringsAsFactors = FALSE
  )
}

analyze_loss_trends <- function(scenario = sample_scenario()) {
  trend_delta <- scenario$current_q_loss_ratio_pct - scenario$prior_q_loss_ratio_pct
  reserve_gap_m <- round(scenario$expected_ultimate_m - scenario$current_reserve_m, 1)
  severity_pressure <- round((scenario$incurred_loss_m / pmax(scenario$open_claims, 1)) * 1000, 1)

  status <- ifelse(
    reserve_gap_m >= 2.5 | trend_delta >= 10 | scenario$reopen_rate_pct >= 7,
    "red",
    ifelse(reserve_gap_m >= 1 | trend_delta >= 5 | scenario$reopen_rate_pct >= 5, "yellow", "green")
  )

  recommendation <- ifelse(
    status == "red",
    "Escalate reserve review, tighten vendor evidence, and re-forecast severity immediately.",
    ifelse(
      status == "yellow",
      "Increase adjuster review cadence and validate reserve assumptions before quarter close.",
      "Maintain cadence and preserve clean evidence on appeals and reopeners."
    )
  )

  lane_results <- data.frame(
    lane_id = scenario$lane_id,
    program = scenario$program,
    claims_count = scenario$open_claims,
    incurred_loss_m = round(scenario$incurred_loss_m, 1),
    expected_ultimate_m = round(scenario$expected_ultimate_m, 1),
    reserve_gap_m = reserve_gap_m,
    prior_loss_ratio_pct = scenario$prior_q_loss_ratio_pct,
    loss_ratio_pct = scenario$current_q_loss_ratio_pct,
    trend_delta_pct = trend_delta,
    severity_pressure_k = severity_pressure,
    appeals_backlog = scenario$appeals_backlog,
    reopen_rate_pct = scenario$reopen_rate_pct,
    status = status,
    recommendation = recommendation,
    stringsAsFactors = FALSE
  )

  reserve_actions <- lane_results[, c("program", "reserve_gap_m", "recommendation")]
  reserve_actions <- reserve_actions[order(-reserve_actions$reserve_gap_m), ]

  list(
    scenario_title = "Claims loss trend lab for reserve, severity, and reopen posture",
    generated_on = "2026-05-28",
    total_incurred_m = round(sum(lane_results$incurred_loss_m), 1),
    total_expected_m = round(sum(lane_results$expected_ultimate_m), 1),
    reserve_gap_m = round(sum(lane_results$reserve_gap_m), 1),
    avg_loss_ratio_pct = round(mean(lane_results$loss_ratio_pct), 1),
    avg_reopen_rate_pct = round(mean(lane_results$reopen_rate_pct), 1),
    escalated_programs = sum(lane_results$status == "red"),
    lane_results = lane_results,
    reserve_actions = reserve_actions
  )
}

build_dashboard <- function() {
  analyze_loss_trends(sample_scenario())
}

base_css <- function() {
  paste0(
    ":root{--bg:#070a0f;--panel:#0b1220;--line:rgba(120,255,170,.18);--line2:rgba(120,255,170,.10);",
    "--text:#e9f3ff;--muted:rgba(233,243,255,.72);--muted2:rgba(233,243,255,.55);--bert:#37ff8b;--bert2:#19c7ff;",
    "--warn:#ffcc66;--bad:#ff5c7a;--plum:#b88cff;--shadow:0 18px 60px rgba(0,0,0,.55);",
    "--mono:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,'Courier New',monospace;",
    "--sans:ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif}",
    "*{box-sizing:border-box}html,body{height:100%}body{margin:0;font-family:var(--sans);color:var(--text);",
    "background:radial-gradient(1200px 600px at 20% -10%, rgba(55,255,139,.18), transparent 60%),",
    "radial-gradient(900px 520px at 90% 0%, rgba(25,199,255,.16), transparent 55%),",
    "radial-gradient(1000px 600px at 50% 110%, rgba(55,255,139,.10), transparent 60%),",
    "linear-gradient(180deg,#05070c 0%,#070a0f 35%,#05070c 100%)}",
    ".grid-bg{position:fixed;inset:0;pointer-events:none;opacity:.12;z-index:-1;background-image:",
    "linear-gradient(to right, rgba(55,255,139,.14) 1px, transparent 1px),",
    "linear-gradient(to bottom, rgba(55,255,139,.10) 1px, transparent 1px);background-size:46px 46px;",
    "mask-image:radial-gradient(900px 600px at 40% 10%, #000 60%, transparent 100%)}",
    ".wrap{max-width:1280px;margin:0 auto;padding:24px 22px 80px}.topbar{display:flex;justify-content:space-between;",
    "align-items:flex-start;gap:14px;border-bottom:1px solid var(--line2);padding-bottom:14px;margin-bottom:22px;",
    "font-family:var(--mono);font-size:11px;letter-spacing:.16em;color:var(--muted);text-transform:uppercase}",
    ".topbar .left{color:var(--bert)}.topbar .right{text-align:right}.herorow{display:grid;grid-template-columns:1.45fr .85fr;gap:18px}",
    "@media (max-width:1000px){.herorow{grid-template-columns:1fr}}",
    ".hero,.panel,.mini,.tablewrap{background:linear-gradient(180deg, rgba(11,18,32,.95), rgba(8,14,26,.92));",
    "border:1px solid var(--line);border-radius:22px;box-shadow:var(--shadow)}.hero{padding:28px 28px 24px;border-top:2px solid var(--bert2)}",
    ".hero h1{font-size:60px;line-height:.97;margin:0 0 18px;font-weight:800;letter-spacing:-.5px}",
    "@media (max-width:700px){.hero h1{font-size:40px}}.hero p,.panel p,.mini p,.tablewrap p{color:var(--muted);font-size:15px;line-height:1.55}",
    ".chiprow{display:flex;flex-wrap:wrap;gap:8px}.meta-chip,.pill{font-family:var(--mono);font-size:11px;padding:7px 12px;border-radius:999px;",
    "border:1px solid var(--line);background:rgba(6,10,18,.4);color:var(--muted)}.side{display:flex;flex-direction:column;gap:14px}",
    ".mini{padding:18px}.mini .lbl,.section-note{font-family:var(--mono);font-size:10px;letter-spacing:.18em;text-transform:uppercase;color:var(--bert2)}",
    ".mini h3{margin:8px 0 6px;font-size:28px;line-height:1.02}.section{margin-top:34px}.sh{display:flex;justify-content:space-between;align-items:baseline;gap:14px;",
    "padding-bottom:10px;border-bottom:1px solid var(--line2);margin-bottom:14px}.sh h2{margin:0;font-size:24px;font-weight:600}",
    ".sh .note{font-family:var(--mono);font-size:11px;color:var(--muted2);letter-spacing:.16em;text-transform:uppercase}",
    ".kpis{display:grid;grid-template-columns:repeat(4,1fr);gap:12px}@media (max-width:900px){.kpis{grid-template-columns:repeat(2,1fr)}}@media (max-width:640px){.kpis{grid-template-columns:1fr}}",
    ".kpi,.card{border:1px solid var(--line);border-radius:16px;padding:16px;background:linear-gradient(180deg, rgba(11,18,32,.85), rgba(8,14,26,.65))}",
    ".kpi .v{font-family:var(--mono);font-size:28px;font-weight:700}.kpi .lbl{font-family:var(--mono);font-size:10px;letter-spacing:.18em;text-transform:uppercase;color:var(--muted);margin-top:6px}",
    ".kpi .h{font-size:12px;color:var(--muted);line-height:1.45;margin-top:8px}.green{color:var(--bert)}.cyan{color:var(--bert2)}.warn{color:var(--warn)}.plum{color:var(--plum)}.bad{color:var(--bad)}",
    ".cards{display:grid;grid-template-columns:repeat(3,1fr);gap:14px}@media (max-width:1000px){.cards{grid-template-columns:1fr}}",
    ".card h3{margin:8px 0 8px;font-size:22px}.card .eyebrow{font-family:var(--mono);font-size:10px;letter-spacing:.18em;text-transform:uppercase;color:var(--bert)}",
    "table{width:100%;border-collapse:collapse}th,td{padding:13px 14px;text-align:left;font-size:13.5px;vertical-align:top}",
    "thead th{font-family:var(--mono);font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:var(--muted2);border-bottom:1px solid var(--line);background:rgba(11,18,32,.5)}",
    "tbody tr:hover{background:rgba(55,255,139,.03)}tbody td{color:var(--muted);border-bottom:1px solid var(--line2)}",
    ".tablewrap{padding:0;overflow:hidden}.status{display:inline-block;padding:4px 9px;border-radius:6px;border:1px solid currentColor;font-family:var(--mono);font-size:10px;letter-spacing:.1em;text-transform:uppercase}",
    ".quote{margin-top:34px;border:1px solid rgba(55,255,139,.22);background:radial-gradient(700px 200px at 0% 0%, rgba(55,255,139,.10), transparent 60%),linear-gradient(180deg, rgba(11,18,32,.92), rgba(8,14,26,.88));border-radius:18px;padding:24px 26px}",
    ".quote .lbl{font-family:var(--mono);font-size:11px;color:var(--bert);letter-spacing:.22em;text-transform:uppercase}.quote .q{margin-top:12px;font-size:32px;line-height:1.25;font-weight:600;max-width:1000px}",
    "footer{margin-top:30px;padding-top:14px;border-top:1px dashed var(--line2);display:flex;justify-content:space-between;gap:10px;flex-wrap:wrap;font-family:var(--mono);font-size:11px;color:var(--muted2);letter-spacing:.08em}",
    "a{color:var(--bert2);text-decoration:none}"
  )
}

status_badge <- function(status) {
  accent <- ifelse(status == "green", "green", ifelse(status == "yellow", "warn", "bad"))
  sprintf("<span class=\"status %s\">%s</span>", accent, toupper(status))
}

row_html <- function(df) {
  pieces <- apply(df, 1, function(row) {
    sprintf(
      "<tr><td><b>%s</b><br><span class=\"section-note\">%s</span></td><td>%s</td><td>%s%%</td><td>$%sM</td><td>%s%%</td><td>%s</td></tr>",
      html_escape(row[["program"]]),
      html_escape(row[["lane_id"]]),
      html_escape(row[["claims_count"]]),
      html_escape(row[["loss_ratio_pct"]]),
      html_escape(row[["reserve_gap_m"]]),
      html_escape(row[["reopen_rate_pct"]]),
      status_badge(row[["status"]])
    )
  })
  paste(pieces, collapse = "\n")
}

html_page <- function(title, description, content, canonical) {
  paste0(
    "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">",
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",
    "<title>", html_escape(title), "</title>",
    "<meta name=\"description\" content=\"", html_escape(description), "\">",
    "<meta name=\"robots\" content=\"index,follow\">",
    "<meta property=\"og:title\" content=\"", html_escape(title), "\">",
    "<meta property=\"og:description\" content=\"", html_escape(description), "\">",
    "<meta property=\"og:type\" content=\"website\">",
    "<meta property=\"og:url\" content=\"", canonical, "\">",
    "<link rel=\"canonical\" href=\"", canonical, "\">",
    "<style>", base_css(), "</style></head><body><div class=\"grid-bg\"></div><div class=\"wrap\">",
    content,
    "</div></body></html>"
  )
}

overview_content <- function(result) {
  cards <- paste(mapply(function(lane_id, program, claims_count, loss_ratio_pct, reserve_gap_m, status) {
    sprintf("<div class=\"card\"><div class=\"eyebrow\">%s</div><h3>%s</h3><p>%s open claims, %s%% loss ratio, and $%sM reserve gap.</p><p>%s</p></div>",
            html_escape(lane_id),
            html_escape(program),
            claims_count,
            loss_ratio_pct,
            reserve_gap_m,
            status_badge(status))
  },
  result$lane_results$lane_id,
  result$lane_results$program,
  result$lane_results$claims_count,
  result$lane_results$loss_ratio_pct,
  result$lane_results$reserve_gap_m,
  result$lane_results$status,
  USE.NAMES = FALSE), collapse = "")

  paste0(
    "<div class=\"topbar\"><div class=\"left\">language atlas · r statistical reporting surface</div>",
    "<div class=\"right\"><div>loss.kineticgain.com</div><div>generated ", html_escape(result$generated_on), " · insurance / insurtech</div></div></div>",
    "<div class=\"herorow\"><section class=\"hero\">",
    "<div class=\"chiprow\"><span class=\"meta-chip\">R trend analysis</span><span class=\"meta-chip\">claims reserves</span><span class=\"meta-chip\">insurance operations</span><span class=\"meta-chip\">actuarial proof</span></div>",
    "<h1>Claims loss trend lab for reserve drift, severity pressure, and reopen posture.</h1>",
    "<p>A base-R operator surface for Insurance / InsurTech teams: quantify loss-ratio change, reserve adequacy, reopen pressure, and appeals friction in one buyer-readable proof set.</p>",
    "<div class=\"chiprow\"><span class=\"pill\">Route: /loss-lane/</span><span class=\"pill\">Route: /trend-matrix/</span><span class=\"pill\">Route: /reserve-posture/</span></div>",
    "</section><aside class=\"side\">",
    sprintf("<div class=\"mini\"><div class=\"lbl\">Average loss ratio</div><h3>%s%%</h3><p>Current-quarter blended loss ratio across the modeled claim programs.</p></div>", result$avg_loss_ratio_pct),
    sprintf("<div class=\"mini\"><div class=\"lbl\">Reserve gap</div><h3>$%sM</h3><p>Difference between expected ultimate loss and current booked reserve.</p></div>", result$reserve_gap_m),
    sprintf("<div class=\"mini\"><div class=\"lbl\">Escalated programs</div><h3>%s</h3><p>Programs where reserve or reopen pressure already needs action.</p></div>", result$escalated_programs),
    "</aside></div>",
    "<section class=\"section\"><div class=\"sh\"><h2>Control-plane summary</h2><div class=\"note\">Four KPIs from one R analysis path</div></div>",
    "<div class=\"kpis\">",
    sprintf("<div class=\"kpi\"><div class=\"v cyan\">$%sM</div><div class=\"lbl\">Incurred Loss</div><div class=\"h\">Booked incurred loss across the modeled portfolio.</div></div>", result$total_incurred_m),
    sprintf("<div class=\"kpi\"><div class=\"v warn\">$%sM</div><div class=\"lbl\">Expected Ultimate</div><div class=\"h\">Expected ultimate loss used for reserve posture.</div></div>", result$total_expected_m),
    sprintf("<div class=\"kpi\"><div class=\"v plum\">%s%%</div><div class=\"lbl\">Average Reopen Rate</div><div class=\"h\">How often claims are coming back after closure.</div></div>", result$avg_reopen_rate_pct),
    sprintf("<div class=\"kpi\"><div class=\"v bad\">%s</div><div class=\"lbl\">Escalated Programs</div><div class=\"h\">Programs with red reserve or reopen pressure.</div></div>", result$escalated_programs),
    "</div></section>",
    "<section class=\"section\"><div class=\"sh\"><h2>Program trend matrix</h2><div class=\"note\">Loss ratio, reserve gap, reopen rate</div></div>",
    "<div class=\"tablewrap\"><table><thead><tr><th>Program</th><th>Claims</th><th>Loss Ratio</th><th>Reserve Gap</th><th>Reopen Rate</th><th>Status</th></tr></thead><tbody>",
    row_html(result$lane_results),
    "</tbody></table></div></section>",
    "<section class=\"section\"><div class=\"sh\"><h2>Programs to review first</h2><div class=\"note\">Buyer-readable remediation sequence</div></div><div class=\"cards\">",
    cards,
    "</div></section>",
    "<div class=\"quote\"><div class=\"lbl\">Why this matters</div><div class=\"q\">A claims trend lab is monetizable when the same R model supports reserve reviews, carrier evidence packets, and consulting-grade quarter-close briefings.</div></div>",
    "<footer><div>discipline · insurance trend analysis</div><div>focus · loss ratio / reserve gap / reopen pressure</div><div>overview snapshot</div><div><a href=\"https://github.com/mizcausevic-dev/\">GitHub</a> · <a href=\"https://www.linkedin.com/in/mirzacausevic/\">LinkedIn</a> · <a href=\"https://kineticgain.com/\">Kinetic Gain</a></div></footer>"
  )
}

loss_lane_content <- function(result) {
  paste0(
    "<div class=\"topbar\"><div class=\"left\">claims loss trend lab · loss lane</div><div class=\"right\"><div>Insurance / InsurTech</div><div>program review board</div></div></div>",
    "<section class=\"hero\"><h1>Program-by-program loss development stays visible.</h1><p>The loss lane keeps claims count, loss ratio change, reserve gap, and appeals backlog on one route so operator teams can triage deteriorating books before quarter close.</p></section>",
    "<section class=\"section\"><div class=\"tablewrap\"><table><thead><tr><th>Program</th><th>Trend Delta</th><th>Appeals Backlog</th><th>Severity Pressure</th><th>Status</th></tr></thead><tbody>",
    paste(apply(result$lane_results, 1, function(row) {
      sprintf("<tr><td><b>%s</b><br><span class=\"section-note\">%s</span></td><td>%s pts</td><td>%s</td><td>%s</td><td>%s</td></tr>",
              html_escape(row[["program"]]),
              html_escape(row[["lane_id"]]),
              html_escape(row[["trend_delta_pct"]]),
              html_escape(row[["appeals_backlog"]]),
              html_escape(row[["severity_pressure_k"]]),
              status_badge(row[["status"]]))
    }), collapse = ""),
    "</tbody></table></div></section>"
  )
}

trend_matrix_content <- function(result) {
  lines <- paste(apply(result$lane_results, 1, function(row) {
    sprintf("<div class=\"card\"><div class=\"eyebrow\">%s</div><h3>%s</h3><p>Loss ratio moved from %s%% to %s%% with reopen rate at %s%%.</p><p>%s</p></div>",
            html_escape(row[["lane_id"]]),
            html_escape(row[["program"]]),
            html_escape(row[["prior_loss_ratio_pct"]]),
            html_escape(row[["loss_ratio_pct"]]),
            html_escape(row[["reopen_rate_pct"]]),
            html_escape(row[["recommendation"]]))
  }), collapse = "")

  paste0(
    "<div class=\"topbar\"><div class=\"left\">claims loss trend lab · trend matrix</div><div class=\"right\"><div>trend. reserve. reopen.</div></div></div>",
    "<section class=\"hero\"><h1>Trend shifts stay tied to operational action.</h1><p>This route turns raw statistical deltas into program-specific review guidance teams can use for reserve committees and carrier evidence packets.</p></section>",
    "<section class=\"section\"><div class=\"cards\">", lines, "</div></section>"
  )
}

reserve_posture_content <- function(result) {
  rows <- paste(apply(result$reserve_actions, 1, function(row) {
    sprintf("<tr><td><b>%s</b></td><td>$%sM</td><td>%s</td></tr>",
            html_escape(row[["program"]]),
            html_escape(row[["reserve_gap_m"]]),
            html_escape(row[["recommendation"]]))
  }), collapse = "")

  paste0(
    "<div class=\"topbar\"><div class=\"left\">claims loss trend lab · reserve posture</div><div class=\"right\"><div>reserve committee packet</div></div></div>",
    "<section class=\"hero\"><h1>Reserve adequacy and reopen pressure stay auditable.</h1><p>The reserve posture route shows which books need immediate reserve review and where evidence routing should tighten before quarter-close reporting.</p></section>",
    "<section class=\"section\"><div class=\"tablewrap\"><table><thead><tr><th>Program</th><th>Reserve Gap</th><th>Recommendation</th></tr></thead><tbody>", rows, "</tbody></table></div></section>"
  )
}

verification_content <- function(result) {
  paste0(
    "<div class=\"topbar\"><div class=\"left\">claims loss trend lab · verification</div><div class=\"right\"><div>base R only</div></div></div>",
    "<section class=\"hero\"><h1>One analysis path, one static proof surface.</h1><p>The same base-R functions produce the lane analysis, reserve review board, site pages, smoke checks, and README proof assets.</p></section>",
    "<section class=\"section\"><div class=\"cards\">",
    "<div class=\"card\"><div class=\"eyebrow\">Validation</div><h3>R runtime</h3><p>Validated with Rscript demo, tests, site generation, and smoke checks.</p></div>",
    "<div class=\"card\"><div class=\"eyebrow\">Routes</div><h3>Static proof surface</h3><p>/ · /loss-lane/ · /trend-matrix/ · /reserve-posture/ · /verification/ · /docs/</p></div>",
    "<div class=\"card\"><div class=\"eyebrow\">Commercial path</div><h3>Templates and consulting</h3><p>Paid templates now, with embedded reserve reviews and evidence routing by engagement.</p></div>",
    "</div></section>"
  )
}

docs_content <- function() {
  paste0(
    "<div class=\"topbar\"><div class=\"left\">claims loss trend lab · docs</div><div class=\"right\"><div>kinetic gain embedded</div></div></div>",
    "<section class=\"hero\"><h1>Insurance trend proof for reserve and evidence operations.</h1><p>This repo sits in the Language Atlas and Industry Atlas at once: real R, Insurance / InsurTech framing, and a monetizable path into reserve review templates, quarterly loss packets, and embedded evidence routing work.</p></section>",
    "<section class=\"section\"><div class=\"cards\">",
    "<div class=\"card\"><div class=\"eyebrow\">Tier 1</div><h3>Public proof</h3><p>Open-source dashboard route and claims trend model with buyer-readable outputs.</p></div>",
    "<div class=\"card\"><div class=\"eyebrow\">Tier 2</div><h3>Paid templates now</h3><p>Carrier packet templates, loss-trend decks, and reserve review starter kits.</p></div>",
    "<div class=\"card\"><div class=\"eyebrow\">Tier 4</div><h3>Embedded by engagement</h3><p>Kinetic Gain can adapt the trend lab for a carrier, MGA, or broker operations team.</p></div>",
    "</div></section>"
  )
}

write_file <- function(path, text) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(text, path, useBytes = TRUE)
}

write_site <- function(result = build_dashboard()) {
  base <- "https://loss.kineticgain.com"
  dir.create("site", recursive = TRUE, showWarnings = FALSE)

  page_paths <- c(
    "index.html",
    file.path("loss-lane", "index.html"),
    file.path("trend-matrix", "index.html"),
    file.path("reserve-posture", "index.html"),
    file.path("verification", "index.html"),
    file.path("docs", "index.html")
  )

  pages <- setNames(list(
    html_page("Claims loss trend lab R", "Base-R insurance operator surface for loss trend, reserve drift, and reopen posture.", overview_content(result), base),
    html_page("Loss lane · Claims loss trend lab", "Program-by-program claims loss development and triage.", loss_lane_content(result), paste0(base, "/loss-lane/")),
    html_page("Trend matrix · Claims loss trend lab", "Trend deltas and program recommendations.", trend_matrix_content(result), paste0(base, "/trend-matrix/")),
    html_page("Reserve posture · Claims loss trend lab", "Reserve adequacy and reopen posture routing.", reserve_posture_content(result), paste0(base, "/reserve-posture/")),
    html_page("Verification · Claims loss trend lab", "Validation and commercial path for the R trend surface.", verification_content(result), paste0(base, "/verification/")),
    html_page("Docs · Claims loss trend lab", "Insurance / InsurTech documentation and monetization path.", docs_content(), paste0(base, "/docs/"))
  ), page_paths)

  for (relative in names(pages)) {
    write_file(file.path("site", relative), pages[[relative]])
  }

  write_file("site/robots.txt", paste(
    "User-agent: *",
    "Allow: /",
    paste0("Sitemap: ", base, "/sitemap.xml"),
    sep = "\n"
  ))

  sitemap <- paste0(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n",
    "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n",
    paste(
      sprintf("  <url><loc>%s%s</loc><lastmod>2026-05-28</lastmod></url>",
              base,
              c("", "/loss-lane/", "/trend-matrix/", "/reserve-posture/", "/verification/", "/docs/")),
      collapse = "\n"
    ),
    "\n</urlset>\n"
  )
  write_file("site/sitemap.xml", sitemap)
  invisible(normalizePath("site", winslash = "/", mustWork = FALSE))
}
