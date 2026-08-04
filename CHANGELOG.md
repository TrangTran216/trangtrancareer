# Website Changelog

## 2026-08-04 — GitHub Pages path and asset repair

### Fixed

- Corrected deployment target to `TrangTran216/trangtrancareer`.
- Corrected published site URL to `https://trangtran216.github.io/trangtrancareer/`.
- Restored the required `projects/` folder so both project detail pages resolve.
- Restored the required `assets/` hierarchy so the resume preview, resume download, Excel workbook, Project 2 artifact ZIP, SQL file, CSV exports, and screenshots resolve.
- Added deployment validation for nested paths and binary assets.
- Added a custom `404.html` with redirects for old root-level project URLs.

### Root cause addressed

Files that belonged in nested folders had been uploaded as root-level files. The HTML links were already written for the intended folder hierarchy, so GitHub Pages returned 404 responses for the expected nested URLs.

## 2026-08-04 — Project 2 update

### Added

- Project 2: **California Procurement Intelligence: SQLite Analysis and Data-Quality Audit of Public Purchase Orders, FY 2012–2015**
- Dedicated project detail page with methodology, metrics, findings, validation, and evidence gallery
- SQL workflow download
- CSV output downloads
- Project evidence ZIP
- Official dataset attribution

### Updated

- Home page hero, skills, featured project, and selected projects
- About page technical-development language
- Resume page online competency tags
- Projects index with two completed projects
- Project 1 page with a link to Project 2
- Responsive styling, tables, download cards, and screenshot gallery
