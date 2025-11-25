# CFA Data Pipelines Workshop - Setup

## Python Environment Setup

### For R/Quarto Development (recommended for this project)

This project uses `renv` to manage both R and Python dependencies.

1. **Tell renv where Python is:**
   ```r
   # In R console
   renv::use_python("C:/Users/u0092104/AppData/Local/Python/pythoncore-3.14-64/python.exe")
   ```

2. **Install Python packages:**
   ```r
   # renv will create a virtual environment and install from requirements.txt
   renv::restore()
   ```

### Alternative: Manual Python venv Setup

If you prefer traditional Python workflow:

```powershell
# Create virtual environment
python -m venv .venv

# Activate
.venv\Scripts\Activate.ps1

# Install packages
pip install -r requirements.txt
```

Then set the Python path in your R session:
```r
Sys.setenv(RETICULATE_PYTHON = ".venv/Scripts/python.exe")
```

## R Package Setup

```r
# Install required R packages
install.packages(c("httr", "jsonlite", "dplyr", "DBI", "RSQLite", "ggplot2"))

# Or use renv
renv::restore()
```

## Verifying Setup

**R:**
```r
library(httr)
library(dplyr)
library(ggplot2)
```

**Python (in R via reticulate):**
```r
library(reticulate)
py_config()  # Should show your Python path
```

## Rendering Slides

```powershell
quarto render slides/01-introduction.qmd
```

Or preview:
```powershell
quarto preview slides/01-introduction.qmd
```
