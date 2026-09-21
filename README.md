# 🎬 Pixar SQL Business Analysis

A SQL-based business analysis project using Pixar movie data to answer real-world business questions around **revenue, profitability, ratings, genres, directors, awards, runtime, audience geography, and yearly performance**.

This project focuses on using SQL to convert raw movie data into meaningful business insights through **CTEs, joins, aggregation, CASE statements, window functions, ranking, and analytical calculations**.

---

## 📌 Project Overview

The objective of this project is to analyze Pixar films from different business perspectives and answer questions such as:

* Which films generated the highest returns?
* Does a high IMDb rating always mean high revenue?
* Which genres generate better returns?
* How does director performance vary?
* Is there an ideal movie runtime?
* Do award-winning films generate more revenue?
* Which films depend more on international audiences?
* How has Pixar's revenue changed over time?
* What was the highest-grossing film in each year?
* Which low-budget films generated high returns?

The project contains **10 business-oriented SQL problems**, along with hints and SQL solutions.

---

## 🗂️ Repository Structure

```text
pixar-sql-analysis/
│
├── data/
│   └── pixar_csv_files/
│       ├── pixar_films.csv
│       ├── box_office.csv
│       ├── public_response.csv
│       ├── genres.csv
│       ├── pixar_people.csv
│       └── academy.csv
│
├── sql/
│   └── pixar_sql_questions_hints_answers.sql
│
├── docs/
│   └── Pixar_SQL_Interview_Questions.pdf
│
└── README.md
```

---

# 📊 Dataset

The analysis uses multiple CSV tables containing information about Pixar films.

### Main Tables

| Table             | Purpose                                                       |
| ----------------- | ------------------------------------------------------------- |
| `pixar_films`     | Movie information such as film name, release date and runtime |
| `box_office`      | Budget and worldwide/domestic/international revenue           |
| `public_response` | IMDb and other public response information                    |
| `genres`          | Genre/category information for films                          |
| `pixar_people`    | People associated with films, including directors             |
| `academy`         | Academy award information                                     |

These tables are connected using the **film** field.

---

# 🧠 SQL Business Questions

The project contains the following 10 analytical problems.

### 1. ROI + Success Classification

**Business Question:**
Which films are actually successful?

Calculate:

```text
ROI = (Revenue - Budget) / Budget
```

Classify films into:

* Blockbuster
* Hit
* Average
* Flop

Then calculate:

* Number of films in each category
* Average IMDb score for each category

---

### 2. Revenue vs Ratings Paradox

**Business Question:**
Do higher ratings always mean higher revenue?

The analysis:

* Ranks films by IMDb score
* Ranks films by worldwide revenue
* Compares the two rankings
* Identifies differences between rating performance and revenue performance

SQL concepts used:

```text
DENSE_RANK()
Window Functions
CTEs
CASE
```

---

### 3. Genre Profitability

**Business Question:**
Which genre actually makes money?

The analysis calculates:

* Average ROI by genre
* Total revenue by genre

It also handles the **one-to-many relationship** between films and genres to avoid incorrectly duplicating revenue.

---

### 4. Director Impact Analysis

**Business Question:**
Do some directors consistently perform well?

The analysis calculates for each director:

* Total films
* Average revenue
* Average IMDb score

SQL concepts:

```text
JOIN
GROUP BY
AVG()
COUNT()
```

---

### 5. Runtime Optimization

**Business Question:**
Is there an ideal movie length?

Movies are grouped into runtime buckets:

```text
<90
90–100
100–110
110+
```

For each bucket, the analysis calculates:

* Average revenue
* Average IMDb score
* Number of films

---

### 6. Awards vs Revenue Reality Check

**Business Question:**
Do awards actually matter?

Films are classified into:

```text
No Awards
1 Award
2+ Awards
```

The analysis compares:

* Average revenue
* Average IMDb score
* Number of films

This uses award information where the award status indicates a win.

---

### 7. Domestic vs International Strategy

**Business Question:**
Which films depend more on international audiences?

The analysis calculates:

```text
Domestic % = Domestic Revenue / Worldwide Revenue × 100

International % = International Revenue / Worldwide Revenue × 100
```

Films are then classified based on their audience revenue mix.

A film with at least **60% international revenue** is identified as having a strongly international revenue mix.

---

### 8. Time Trend Analysis

**Business Question:**
How has Pixar evolved over time?

The analysis calculates:

* Year-wise total revenue
* Average IMDb score
* Previous year's revenue
* Year-over-year revenue growth

SQL concepts used:

```text
LAG()
CTE
GROUP BY
Window Functions
```

---

### 9. Top Performer per Year

**Business Question:**
What was the highest-grossing film each year?

The analysis uses:

```text
ROW_NUMBER()
PARTITION BY
ORDER BY
```

This identifies the film with the highest worldwide revenue for each release year.

---

### 10. Hidden Gems Detection

**Business Question:**
Which films had relatively low budgets but generated relatively high revenue?

The analysis identifies films where:

```text
Budget < Average Budget
AND
Revenue > Average Revenue
```

These films are then ranked by ROI to identify highly efficient performers.

---

# 🛠️ SQL Concepts Demonstrated

This project demonstrates several important SQL concepts used in real-world data analysis.

### Basic SQL

* `SELECT`
* `WHERE`
* `GROUP BY`
* `ORDER BY`
* `COUNT()`
* `SUM()`
* `AVG()`

### Joins

* `INNER JOIN`
* `LEFT JOIN`

### Data Transformation

* `CASE`
* `COALESCE()`
* `ROUND()`
* `YEAR()`
* `STR_TO_DATE()`

### Advanced SQL

* Common Table Expressions (`WITH`)
* Window Functions
* `LAG()`
* `ROW_NUMBER()`
* `DENSE_RANK()`
* `PARTITION BY`

### Analytical Techniques

* ROI calculation
* Ranking
* Classification
* Percentage analysis
* Year-over-year growth
* Performance segmentation
* Benchmark comparison

---

# 💡 Key Analytical Ideas

The main purpose of this project is not simply to write SQL queries.

The queries are designed around **business questions**.

For example:

```text
Raw Data
   ↓
Business Question
   ↓
SQL Analysis
   ↓
Calculated Metrics
   ↓
Comparison
   ↓
Business Insight
```

This approach demonstrates how SQL can be used as an analytical and decision-support tool.

---

# 📄 Files in This Repository

### SQL File

`pixar_sql_questions_hints_answers.sql`

Contains:

* Business questions
* SQL hints
* SQL solutions
* Comments explaining the logic

### Interview Questions PDF

`Pixar_SQL_Interview_Questions.pdf`

Contains only the **10 questions**, without hints or solutions.

This can be used separately for:

* SQL interview practice
* Self-assessment
* Mock interviews
* SQL problem-solving practice

---

# 🎯 Skills Demonstrated

Through this project, the following skills are demonstrated:

* SQL Data Analysis
* Business Problem Solving
* Data Aggregation
* Relational Data Analysis
* Multi-table Joins
* CTEs
* Window Functions
* Ranking Analysis
* Revenue Analysis
* Profitability Analysis
* Performance Segmentation
* Trend Analysis
* Analytical Thinking

---

# 🚀 How to Use

Clone the repository:

```bash
git clone <your-github-repository-url>
```

Open the SQL file:

```text
sql/pixar_sql_questions_hints_answers.sql
```

Load the CSV files into your MySQL database and create/use the database:

```sql
USE pixar;
```

Then execute the queries individually.

> The SQL file is written using MySQL syntax.

---

# 🧪 Recommended Practice Method

For interview preparation, first use:

```text
Pixar_SQL_Interview_Questions.pdf
```

Try solving the questions without looking at the solution.

Then open:

```text
pixar_sql_questions_hints_answers.sql
```

Use the hints if you get stuck, and finally compare your solution with the provided SQL approach.

---

# 📌 Project Type

**Domain:** Entertainment / Movie Analytics
**Project Type:** SQL Business Analysis
**Database:** MySQL
**Data Source:** Pixar movie-related datasets
**Level:** Intermediate → Advanced SQL

---



A SQL-focused analytical project created to demonstrate practical business problem solving using relational data and advanced SQL techniques.
