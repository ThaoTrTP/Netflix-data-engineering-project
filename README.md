# Netflix Data Engineering Project
End - to end data engineering and analytics project using the Netflix_titles_dataset covering data profiling, cleaning, database modeling, SQL analysis, and dashboarding.
---
## Overview
This project simulated a real-world data engineering workflow: starting from a raw, messy CSV file and ending with a clean relational database, analytical SQL queires, an interactive dashboard, and a written business report.

**Goals:**
- Practice data proliling and cleaning on a real-world messy dataset
- Design a relational schema (with constraints) from flat tabular data
- Write analytical and window-function SQL queries to answer business questions
- Build a BI dashboard to visualize insights
- Document findings in a s structured report
---

## Dataset
- Source: https://www.kaggle.com/code/karanbhatia01/netflix-dataset/input
- File: netflix_title.csv
- Description: Metadata for movies and TV shows available on Netflix, including titlt, director, casr, country, release year, rating, duration, genre, and description.
---

## Pipeline Architecture
Insert later

---
## Project Structure
```
netflix-data-engineering-project/
│
├── README.md
│
├── data/
│   ├── raw/                       # Original, untouched dataset
│   │   └── netflix_titles.csv
│   └── processed/                 # Cleaned, analysis-ready dataset
│       └── cleaned_netflix.csv
│
├── notebooks/
│   ├── 01_profiling.ipynb         # EDA: nulls, dtypes, duplicates, distributions
│   ├── 02_cleaning.ipynb          # Cleaning & standardization
│   └── 03_feature_engineering.ipynb # New derived features
│
├── database/
│   ├── erd.png                    # Entity-Relationship Diagram
│   ├── schema.sql                 # Table definitions
│   ├── constraints.sql            # PK/FK, CHECK constraints
│   └── migration.py               # Loads cleaned CSV into the database
│
├── sql/
│   ├── 01_views.sql                # Reusable views
│   ├── 02_analysis.sql             # Descriptive analysis queries
│   ├── 03_window_functions.sql     # Ranking, running totals, etc.
│   └── 04_business_questions.sql   # Queries answering specific business questions
│
├── dashboard/
│   ├── netflix.pbix                # Power BI dashboard file
│   └── dashboard.png               # Dashboard screenshot/preview
│
├── reports/
│   └── analysis_report.pdf         # Final written report with insights
│
└── requirements.txt
```

---
## Tech Stack
- Data wrangling: Python, Pandas, Numpy
- Notebooks: Jupyter
- Database: MySQL
- Querying: SQL (views, window function, CTEs)
- Visualization: Power BI
- Reporting: PDF
---
## Key Business Questions
- Which countries produce the most Netflix content, and how has this changed over time?
- What is the distribution of Movies vs TV Shows by year and genre?
- Which genres.directors/actors appear most frequently?
- How has content duration (movie length/ number of seasons) evolved over time?
- What are the top contributing countries genre by decade?
---
## Getting started
1. Clone the repository
```bash
git clone <repo-url>
cd netflix-data-engineering-project
```
2. Set up the environment
```bash
python -m venv  venv
source venv/bin/activate
pip install -r requirements.txt
```
3. Run the pipeline
    1. Place `neflix_title.csv` in `data/raw/`
    2. Run notebooks in order: `01_profiling` - `02_cleaning` - `03_feature_engineering`.
    3. Run `database/migration.py` to load `cleaned_netflix.csv` into the database
    4. Execute SQL scripts in `sql/` against the database
    5. Open `dashboard/netflix.pbix` in Power BI to explore visuals

    ---

    ## Results and Insights
    *Later on*

    ---

    ## Future improvements
   * Add `src/` module for reusable cleaning/ETL functions
   * Add `'gitgnore` and `config/` for environment variables and DB credentials
   * Add automated tests for cleaning pipelibe
   * Consider a code-based dashboard (Streamlit/Plotly Dash) as an open-source alternative to Power BI
   ---
   ## Author
   - Thao Tran - Data Engineering/Analytics Portfolio Project
   ---
   ## License
   This project is for educational/portfolio purposes. Dataset belongs to its original Kaggle author/source.