# data_engineering_zoomcamp
# Final project - Employee Data Pipeline

An end-to-end data engineering project built with a modern data stack. The pipeline ingests HR data from AWS S3, loads it into Snowflake, transforms it into a star schema using dbt, orchestrates everything with Apache Airflow, and visualizes the results in Tableau.

---

## Architecture

```
AWS S3 (Raw CSV Files)
    ↓
Apache Airflow (Daily Batch Orchestration)
    ↓
Snowflake RAW Schema (4 Raw Tables)
    ↓
dbt (Staging + Mart Transformations)
    ↓
Snowflake STAGING Schema (Star Schema)
    ↓
Tableau (Performance Dashboard)
```

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| **AWS S3** | Raw data storage |
| **Terraform** | Infrastructure as code |
| **Apache Airflow** | Pipeline orchestration |
| **Snowflake** | Cloud data warehouse |
| **dbt** | Data transformation |
| **Jupyter Notebook** | Exploratory data analysis |
| **Tableau** | Data visualization |
| **Docker** | Containerized development environment |

---

## Dataset

[Employee/HR Dataset (All in One)](https://www.kaggle.com/datasets/ravindrasinghrana/employeedataset) from Kaggle consisting of 4 CSV files:

| File | Description |
|------|-------------|
| `employee_data.csv` | Core employee info — demographics, job, tenure, performance |
| `employee_engagement_survey_data.csv` | Engagement, satisfaction and work-life balance scores |
| `recruitment_data.csv` | Applicant info, education, experience, hiring status |
| `training_and_development_data.csv` | Training programs, outcomes, costs and duration |

---

## Project Structure

```
employee_data_project/
├── airflow/
│   └── dags/
│       └── employee_pipeline_dag.py      # Airflow DAG
├── employee_data_transformation/          # dbt project
│   ├── models/
│   │   ├── staging/                       # Staging models
│   │   │   ├── sources.yml
│   │   │   ├── stg_employee.sql
│   │   │   ├── stg_engagement.sql
│   │   │   ├── stg_recruitment.sql
│   │   │   └── stg_training.sql
│   │   ├── marts/                         # Mart models
│   │   │   ├── dim_employee.sql
│   │   │   ├── dim_department.sql
│   │   │   ├── dim_job.sql
│   │   │   ├── dim_date.sql
│   │   │   ├── dim_training_program.sql
│   │   │   ├── fct_employee_snapshot.sql
│   │   │   ├── fct_engagement.sql
│   │   │   ├── fct_recruitment.sql
│   │   │   └── fct_training.sql
│   │   └── schema.yml
│   ├── dbt_project.yml
│   └── packages.yml
├── Terraform/                             # Infrastructure as code
│   ├── main.tf
│   └── variables.tf
├── EDA.ipynb                              # Exploratory data analysis
├── docker-compose.yml
└── README.md
```

---

## Star Schema

```
                    dim_date
                       │
fct_employee_snapshot ─┼─ dim_employee
                       ├─ dim_department
                       └─ dim_job

fct_engagement ──────── dim_employee
                         dim_date

fct_training ─────────── dim_employee
                          dim_training_program
                          dim_date

fct_recruitment ─────── dim_date
```

### Fact Tables

| Table | Grain | Key Metrics |
|-------|-------|-------------|
| `fct_employee_snapshot` | One row per employee | Performance tier, tenure, attrition flag |
| `fct_engagement` | One row per employee per survey | Engagement, satisfaction, work-life balance scores |
| `fct_training` | One row per employee per training | Training cost, duration, pass/fail |
| `fct_recruitment` | One row per applicant | Desired salary, experience, hiring status |

### Dimension Tables

| Table | Description |
|-------|-------------|
| `dim_employee` | Employee profile, demographics, employment details |
| `dim_department` | Department, division, business unit |
| `dim_job` | Job title and function |
| `dim_date` | Date spine from 2000 to 2030 |
| `dim_training_program` | Training program, type, location |

---

## Pipeline

The Airflow DAG `employee_data_pipeline_v2` runs on a daily schedule:

```
load_employee_info ──┐
load_engagement      ├──► run_dbt_transformations
load_recruitment     │
load_training    ────┘
```

The 4 load tasks run in parallel, truncating and reloading each raw table from S3. Once all loads complete, dbt builds and tests all staging and mart models.

---

## dbt Transformations

### Staging Layer
- Casts all columns to correct data types
- Renames columns to snake_case
- Trims whitespace and standardizes text
- Handles nulls safely with `try_cast`
- Derives simple flags like `is_active` and `is_passed`

### Mart Layer
- Builds star schema with surrogate keys via `dbt_utils.generate_surrogate_key`
- Generates date spine via `dbt_utils.date_spine`
- Derives business metrics: performance tier, tenure years, attrition flag
- All models include dbt tests: `not_null`, `unique`, `relationships`, `accepted_values`

---

## Dashboard

The Tableau performance dashboard connects directly to Snowflake and includes:

- **Performance Tier Breakdown** — distribution of High / Medium / Low performers
- **Average Rating by Department** — department-level performance comparison
- **Performance Tier by Job Title** — stacked bar showing performance mix per role
- **Tenure vs Rating** — scatter plot correlating tenure with employee rating

---

## Setup

### Prerequisites
- Docker Desktop
- AWS account with S3 bucket
- Snowflake account
- Terraform

### Steps

1. **Clone the repo**
```bash
git clone https://github.com/JadeYoung16/data_engineering_zoomcamp.git
cd data_engineering_zoomcamp/employee_data_project
```

2. **Start the containers**
```bash
docker-compose up -d
```

3. **Set up Snowflake** — run the SQL in Snowflake to create warehouse, database, schemas, file formats, stage and load raw tables

4. **Configure Airflow connection** — add `snowflake_conn` in Airflow UI under Admin → Connections

5. **Run the pipeline** — trigger `employee_data_pipeline_v2` in the Airflow UI

6. **Connect Tableau** — connect to Snowflake `EMPLOYEE_DATA_DB.STAGING` and open `Tableau-dashboard.twb`

---

## Author

Jade Yang
