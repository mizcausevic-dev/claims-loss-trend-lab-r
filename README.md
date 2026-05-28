# claims-loss-trend-lab-r

Base-R operator surface for Insurance / InsurTech teams reviewing claims trend drift, reserve adequacy, reopen pressure, and buyer-readable quarter-close posture.

## What it shows

- real `R` added to the public Kinetic Gain language atlas
- an insurance vertical proof that is statistical, not just dashboard-wrapped
- monetizable reserve review, carrier packet, and claims-evidence consulting hooks

## Screenshots

![Overview](./screenshots/01-overview.svg)
![Loss lane](./screenshots/02-loss-lane.svg)
![Reserve posture](./screenshots/03-reserve-posture.svg)
![Verification](./screenshots/04-verification.svg)

## Routes

- `/`
- `/loss-lane/`
- `/trend-matrix/`
- `/reserve-posture/`
- `/verification/`
- `/docs/`

## Local development

```powershell
& 'C:\Program Files\R\R-4.6.0\bin\Rscript.exe' scripts\run_demo.R
& 'C:\Program Files\R\R-4.6.0\bin\Rscript.exe' scripts\generate_site.R
```

## Validation

```powershell
& 'C:\Program Files\R\R-4.6.0\bin\Rscript.exe' test\runtests.R
& 'C:\Program Files\R\R-4.6.0\bin\Rscript.exe' scripts\smoke_check.R
& 'C:\Program Files\R\R-4.6.0\bin\Rscript.exe' scripts\render_readme_assets.R
```

## Why this matters

Kinetic Gain Embedded tie-back:

This repo proves Kinetic Gain can ship statistical insurance operator surfaces in `R`, not just generic BI wrappers. The same base-R analysis drives reserve-review routes, trend matrices, smoke checks, and proof assets, which makes the language-atlas signal real.

## Commercial path

- `Paid templates now`
- `Consulting hook`

This can ladder into carrier packet templates, reserve review decks, adverse development diagnostics, and embedded claims-evidence work for insurers, MGAs, and broker operations teams.

---

Part of the [Kinetic Gain operator portfolio](https://kineticgain.com/) · docs: [suite.kineticgain.com](https://suite.kineticgain.com/) · live: [loss.kineticgain.com](https://loss.kineticgain.com/)
