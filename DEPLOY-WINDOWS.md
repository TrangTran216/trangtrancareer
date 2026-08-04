# Repair and publish the portfolio from Windows Terminal

## Files to place in Downloads

1. `Trang_Tran_Portfolio_Fixed_Project2_GitHubPages.zip`
2. `Repair-TrangTranPortfolio.ps1`

## Run from Windows Terminal — PowerShell

```powershell
git --version
```

Configure the commit identity once when needed:

```powershell
git config --global user.name "Trang Tran"
git config --global user.email "trangtran.evc@gmail.com"
```

Run the repair deployment:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$HOME\Downloads\Repair-TrangTranPortfolio.ps1"
```

Authenticate with the GitHub account `TrangTran216` when Git prompts you.

## Expected live URLs

- Home: `https://trangtran216.github.io/trangtrancareer/`
- Resume: `https://trangtran216.github.io/trangtrancareer/resume.html`
- Project 1: `https://trangtran216.github.io/trangtrancareer/projects/open-fiscal-vendor-transaction-analysis.html`
- Project 2: `https://trangtran216.github.io/trangtrancareer/projects/california-procurement-intelligence-sqlite.html`
- Resume PDF: `https://trangtran216.github.io/trangtrancareer/assets/Trang_Tran_Resume.pdf`
- Project 2 ZIP: `https://trangtran216.github.io/trangtrancareer/assets/project-2/California_Procurement_SQLite_Project_Artifacts.zip`

In GitHub, **Settings → Pages** should remain set to **Deploy from a branch**, **main**, and **/(root)**.
