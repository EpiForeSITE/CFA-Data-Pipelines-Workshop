# CFA-Data-Pipelines-Workshop

Website for CFA Data Pipelines Class

## Overview

This is a Quarto-based website for a workshop on data pipelines, data acquisition from databases and APIs, and data cleaning. The website includes:

- Course schedule
- Syllabus with learning objectives
- Lecture slides for each session
- Resources and materials

## Building the Website

### Prerequisites

1. Install [Quarto](https://quarto.org/docs/get-started/)
2. (Optional) Install R or Python for executing code examples

### Building

To build the website locally:

```bash
quarto render
```

This will generate the website in the `_site` directory.

### Preview

To preview the website with live reload:

```bash
quarto preview
```

This will start a local server (typically at http://localhost:4200) and open the website in your browser.

## Website Structure

```
.
├── _quarto.yml          # Quarto configuration
├── index.qmd            # Home page
├── syllabus.qmd         # Course syllabus
├── schedule.qmd         # Class schedule
├── styles.css           # Custom styling
└── slides/              # Lecture slides
    ├── 01-introduction.qmd
    ├── 02-apis.qmd
    ├── 03-databases.qmd
    └── 04-data-cleaning.qmd
```

## Course Content

### Session 1: Introduction to Data Pipelines

- Pipeline design patterns
- Best practices
- Tools and frameworks

### Session 2: Data Acquisition from APIs

- RESTful APIs
- Authentication
- Pagination and rate limiting

### Session 3: Database Queries

- SQL fundamentals
- ORMs
- Query optimization

### Session 4: Data Cleaning

- Data quality issues
- Missing data handling
- Validation and transformation

## Contributing

To add or modify content:

1. Edit the relevant `.qmd` file
2. Run `quarto preview` to see changes
3. Commit and push changes

## License

Educational materials for CFA workshop participants.
