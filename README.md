# Trang Tran Career — GitHub Pages Website

This is the deployment-ready static portfolio for:

- GitHub repository: `TrangTran216/trangtrancareer`
- Published site: `https://trangtran216.github.io/trangtrancareer/`
- GitHub Pages source: `main` branch, repository root (`/(root)`)

The site has no build step. GitHub Pages serves the HTML, CSS, JavaScript, PDF, Excel workbook, SQL, CSV, PNG, and ZIP files directly.

## Required repository structure

The directory structure must be preserved exactly:

```text
trangtrancareer/
├── index.html
├── about.html
├── resume.html
├── projects.html
├── contact.html
├── 404.html
├── styles.css
├── script.js
├── .nojekyll
├── projects/
│   ├── open-fiscal-vendor-transaction-analysis.html
│   └── california-procurement-intelligence-sqlite.html
└── assets/
    ├── Trang_Tran_Resume.pdf
    ├── Open_Fiscal_Vendor_Transaction_Analysis.xlsx
    └── project-2/
        ├── California_Procurement_SQLite_Project_Artifacts.zip
        ├── california_procurement_sqlite_analysis.sql
        ├── README.md
        ├── outputs/
        └── screenshots/
```

Do not move the contents of `projects/`, `assets/project-2/outputs/`, or `assets/project-2/screenshots/` into the repository root. The website links intentionally reference those folders.

## Included pages

- `index.html` — Home and featured Project 2
- `about.html` — Professional background and current skill set
- `resume.html` — Resume with embedded preview and PDF download
- `projects.html` — Completed project index
- `projects/open-fiscal-vendor-transaction-analysis.html` — Project 1 detail page
- `projects/california-procurement-intelligence-sqlite.html` — Project 2 detail page
- `contact.html` — Email, LinkedIn, and phone
- `404.html` — Friendly error page with redirects for old misplaced project URLs

## Project 2 assets

The `assets/project-2/` folder contains:

- Reproducible SQLite SQL workflow
- Six selected CSV result and validation exports
- Seven database and query-result screenshots
- Project README
- Complete downloadable evidence bundle

The 164 MB raw source CSV is intentionally not bundled with the website package. The project page links to the official California Open Data source.

## Recommended Windows deployment

Use the supplied `Repair-TrangTranPortfolio.ps1` script. It clones `TrangTran216/trangtrancareer`, removes the incorrectly flattened website files, copies this package while preserving all folders, force-stages static assets, validates tracked paths, commits, and pushes to `main`.

See `DEPLOY-WINDOWS.md` for the terminal commands.
