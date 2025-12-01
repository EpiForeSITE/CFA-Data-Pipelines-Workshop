# R Healthcare Pipeline Clients

This directory contains two versions of R clients for the healthcare data pipeline, demonstrating different approaches to data processing in R.

## Files

### `healthcare_pipeline.R` - Traditional R Approach
- Uses base R and traditional dplyr operations
- Direct SQL queries with `dbGetQuery()`
- Simple error handling
- Good for beginners or when you need direct SQL control

**Features:**
- Traditional R data processing patterns
- Direct SQL query execution
- Basic error handling
- Compatible with older R environments

### `healthcare_pipeline_tidyverse.R` - Modern Tidyverse Approach  
- Uses modern tidyverse patterns with dbplyr
- Lazy evaluation with table references
- Structured logging with the `logger` package
- Modern data manipulation patterns
- Uses `rows_upsert()` for database operations

**Features:**
- **dbplyr**: Lazy evaluation, write R code that translates to SQL
- **logger**: Structured logging with different log levels
- **Functional programming**: Modular functions for each operation
- **Modern tidyverse patterns**: Consistent data manipulation syntax
- **rows_upsert()**: Modern approach to database updates
- **Better error handling**: More sophisticated error management
- **Advanced analytics**: Insurance analysis and high-utilization patient detection

## Requirements

### Traditional Version
```r
install.packages(c('httr', 'jsonlite', 'DBI', 'RPostgres', 'dplyr', 'tidyr'))
```

### Tidyverse Version
```r
install.packages(c('httr', 'jsonlite', 'DBI', 'RPostgres', 'dplyr', 'tidyr', 'dbplyr', 'logger'))
```

## Usage

### Traditional Approach
```bash
Rscript healthcare_pipeline.R
```

### Tidyverse Approach
```bash
Rscript healthcare_pipeline_tidyverse.R
```

## Key Differences

| Feature | Traditional | Tidyverse |
|---------|------------|-----------|
| SQL Queries | Direct `dbGetQuery()` | dbplyr table references |
| Logging | `cat()` statements | Structured logging with `logger` |
| Error Handling | Basic `tryCatch()` | Functional error handling |
| Code Organization | Linear script | Modular functions |
| Database Updates | `dbWriteTable()` overwrite | `rows_upsert()` |
| Data Manipulation | Mixed R/SQL | Consistent tidyverse syntax |
| Performance | Eager evaluation | Lazy evaluation where possible |
| Analytics | Basic summaries | Advanced analytics patterns |

## Learning Objectives

- **Traditional Version**: Learn basic R data pipeline patterns
- **Tidyverse Version**: Learn modern R data science workflows

Both approaches demonstrate:
- API data retrieval
- Database connectivity and querying  
- Data joining and transformation
- Writing results back to database
- Error handling and logging

Choose the approach that best fits your team's R knowledge level and coding standards.