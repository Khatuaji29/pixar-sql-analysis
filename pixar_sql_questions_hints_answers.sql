-- Pixar SQL Analysis
-- Questions + Hints + Answers
-- Database: pixar
-- MySQL syntax

USE pixar;

-- ============================================================
-- BASIC WARM-UP QUERIES
-- ============================================================

-- Total films
SELECT COUNT(film) AS total_films
FROM pixar_films;

-- Total worldwide revenue
SELECT SUM(box_office_worldwide) AS total_worldwide_revenue
FROM box_office;

-- Movies released per year
SELECT YEAR(STR_TO_DATE(release_date, '%d-%m-%Y')) AS release_year,
       COUNT(film) AS total_films
FROM pixar_films
GROUP BY release_year
ORDER BY release_year;


-- ============================================================
-- 1. ROI + SUCCESS CLASSIFICATION
-- Question:
-- Which films are actually successful?
-- Hint:
-- ROI = (Revenue - Budget) / Budget
-- Classify: Blockbuster > 2, Hit > 1 to 2, Average 0 to 1, Flop < 0.
-- Find count of films and average IMDb score by category.
-- ============================================================

WITH cte AS (
    SELECT pf.film,
           bo.budget,
           bo.box_office_worldwide,
           pr.imdb_score,
           CASE
               WHEN bo.budget = 0 THEN NULL
               ELSE (bo.box_office_worldwide - bo.budget) / bo.budget
           END AS ROI
    FROM pixar_films pf
    JOIN box_office bo ON pf.film = bo.film
    JOIN public_response pr ON pf.film = pr.film
),
cte2 AS (
    SELECT *,
           CASE
               WHEN ROI IS NULL THEN 'No data'
               WHEN ROI > 2 THEN 'Blockbuster'
               WHEN ROI > 1 THEN 'Hit'
               WHEN ROI >= 0 THEN 'Average'
               ELSE 'Flop'
           END AS classification
    FROM cte
)
SELECT classification,
       COUNT(*) AS total_films,
       ROUND(AVG(imdb_score), 2) AS avg_imdb
FROM cte2
GROUP BY classification;


-- ============================================================
-- 2. REVENUE VS RATINGS PARADOX
-- Question:
-- Do higher ratings always mean higher revenue?
-- Hint:
-- Use DENSE_RANK() twice: once for IMDb and once for revenue.
-- Compare the two ranks.
-- ============================================================

WITH cte AS (
    SELECT pf.film, pr.imdb_score, bo.box_office_worldwide
    FROM pixar_films pf
    JOIN public_response pr ON pf.film = pr.film
    JOIN box_office bo ON pf.film = bo.film
),
cte2 AS (
    SELECT *,
           DENSE_RANK() OVER (ORDER BY imdb_score DESC) AS rating_rank,
           DENSE_RANK() OVER (ORDER BY box_office_worldwide DESC) AS revenue_rank
    FROM cte
)
SELECT *,
       CASE
           WHEN rating_rank < revenue_rank THEN 'Underrated'
           WHEN rating_rank > revenue_rank THEN 'Overrated'
           ELSE 'Balanced'
       END AS movie_hyped
FROM cte2;


-- ============================================================
-- 3. GENRE PROFITABILITY
-- Question:
-- Which genre actually makes money?
-- Hint:
-- Genres are one-to-many. Count genres per film first so revenue
-- is not duplicated when joining to multiple genre rows.
-- ============================================================

WITH genre_count AS (
    SELECT film, COUNT(*) AS total_genres
    FROM genres
    WHERE category = 'Genre'
    GROUP BY film
),
film_data AS (
    SELECT bo.film,
           bo.box_office_worldwide / gc.total_genres AS adjusted_revenue,
           (bo.box_office_worldwide - bo.budget) / bo.budget AS ROI
    FROM box_office bo
    JOIN genre_count gc ON bo.film = gc.film
)
SELECT g.value AS genre,
       ROUND(AVG(fd.ROI), 2) AS avg_roi,
       ROUND(SUM(fd.adjusted_revenue), 2) AS total_revenue
FROM film_data fd
JOIN genres g ON fd.film = g.film
WHERE g.category = 'Genre'
  AND g.value IN ('Action','Comedy','Adventure','Animation')
GROUP BY g.value
ORDER BY avg_roi DESC;


-- ============================================================
-- 4. DIRECTOR IMPACT ANALYSIS
-- Question:
-- Do some directors guarantee success?
-- Hint:
-- Filter pixar_people to Director and group by director.
-- Calculate total films, average revenue and average IMDb.
-- ============================================================

WITH director_data AS (
    SELECT pf.film,
           pp.name AS director,
           pr.imdb_score,
           bo.box_office_worldwide
    FROM pixar_people pp
    JOIN pixar_films pf ON pp.film = pf.film
    JOIN box_office bo ON bo.film = pf.film
    JOIN public_response pr ON pf.film = pr.film
    WHERE pp.role_type = 'Director'
)
SELECT director,
       COUNT(film) AS total_films,
       ROUND(AVG(box_office_worldwide), 2) AS avg_revenue,
       ROUND(AVG(imdb_score), 2) AS avg_rating
FROM director_data
GROUP BY director;


-- ============================================================
-- 5. RUNTIME OPTIMIZATION
-- Question:
-- Is there an ideal movie length?
-- Hint:
-- Create runtime buckets using CASE.
-- Compare average revenue and IMDb score.
-- ============================================================

WITH cte AS (
    SELECT pf.film,
           bo.box_office_worldwide,
           pr.imdb_score,
           pf.run_time
    FROM pixar_films pf
    JOIN box_office bo ON pf.film = bo.film
    JOIN public_response pr ON pf.film = pr.film
)
SELECT CASE
           WHEN run_time < 90 THEN '<90'
           WHEN run_time BETWEEN 90 AND 100 THEN '90-100'
           WHEN run_time BETWEEN 100 AND 110 THEN '100-110'
           ELSE '110+'
       END AS runtime_bucket,
       ROUND(AVG(imdb_score), 2) AS avg_imdb,
       ROUND(AVG(box_office_worldwide), 2) AS avg_revenue,
       COUNT(film) AS total_films
FROM cte
GROUP BY runtime_bucket
ORDER BY avg_revenue DESC;


-- ============================================================
-- 6. AWARDS VS REVENUE REALITY CHECK
-- Question:
-- Do awards actually matter?
-- Hint:
-- Count only awards with status LIKE 'Won%'.
-- LEFT JOIN the award count so films with zero awards remain.
-- ============================================================

WITH award_count AS (
    SELECT film, COUNT(*) AS total_awards
    FROM academy
    WHERE status LIKE 'Won%'
    GROUP BY film
),
film_data AS (
    SELECT pf.film,
           bo.box_office_worldwide,
           pr.imdb_score,
           COALESCE(ac.total_awards, 0) AS awards
    FROM pixar_films pf
    JOIN box_office bo ON pf.film = bo.film
    JOIN public_response pr ON pf.film = pr.film
    LEFT JOIN award_count ac ON pf.film = ac.film
)
SELECT CASE
           WHEN awards = 0 THEN 'No Awards'
           WHEN awards = 1 THEN '1 Award'
           ELSE '2+ Awards'
       END AS award_category,
       ROUND(AVG(box_office_worldwide), 2) AS avg_revenue,
       ROUND(AVG(imdb_score), 2) AS avg_imdb,
       COUNT(*) AS total_films
FROM film_data
GROUP BY award_category
ORDER BY avg_revenue DESC;


-- ============================================================
-- 7. DOMESTIC VS INTERNATIONAL STRATEGY
-- Question:
-- Which films depend more on international audiences?
-- Hint:
-- Calculate domestic % and international % of worldwide revenue.
-- Find films with international revenue >= 60%.
-- ============================================================

WITH cte AS (
    SELECT pf.film,
           bo.box_office_us_canada,
           bo.box_office_other,
           bo.box_office_worldwide,
           CASE
               WHEN bo.box_office_worldwide = 0 THEN NULL
               ELSE ROUND((bo.box_office_us_canada / bo.box_office_worldwide) * 100, 2)
           END AS domestic_pct,
           CASE
               WHEN bo.box_office_worldwide = 0 THEN NULL
               ELSE ROUND((bo.box_office_other / bo.box_office_worldwide) * 100, 2)
           END AS international_pct
    FROM pixar_films pf
    LEFT JOIN box_office bo ON pf.film = bo.film
)
SELECT film,
       domestic_pct,
       international_pct,
       CASE
           WHEN international_pct >= 60 THEN 'Global hit'
           WHEN domestic_pct >= 60 THEN 'Local hit'
           ELSE 'Balanced'
       END AS audience_type
FROM cte;


-- ============================================================
-- 8. TIME TREND ANALYSIS
-- Question:
-- How has Pixar evolved over time?
-- Hint:
-- Aggregate revenue by release year, then use LAG() to compare
-- each year with the previous year.
-- ============================================================

WITH cte AS (
    SELECT YEAR(STR_TO_DATE(pf.release_date, '%d-%m-%Y')) AS release_year,
           SUM(bo.box_office_worldwide) AS total_revenue,
           AVG(pr.imdb_score) AS avg_imdb_score
    FROM pixar_films pf
    JOIN box_office bo ON pf.film = bo.film
    JOIN public_response pr ON pf.film = pr.film
    GROUP BY release_year
),
trend AS (
    SELECT release_year,
           total_revenue,
           avg_imdb_score,
           LAG(total_revenue) OVER (ORDER BY release_year) AS prev_total_revenue
    FROM cte
)
SELECT release_year,
       total_revenue,
       avg_imdb_score,
       prev_total_revenue,
       CASE
           WHEN prev_total_revenue IS NULL OR prev_total_revenue = 0 THEN NULL
           ELSE ROUND(
               ((total_revenue - prev_total_revenue) / prev_total_revenue) * 100,
               2
           )
       END AS yoy_growth
FROM trend
ORDER BY release_year;


-- ============================================================
-- 9. TOP PERFORMERS PER YEAR
-- Question:
-- What is the best-performing film each year?
-- Hint:
-- Use ROW_NUMBER(), partition by release year and order by revenue DESC.
-- ============================================================

WITH cte AS (
    SELECT YEAR(STR_TO_DATE(pf.release_date, '%d-%m-%Y')) AS release_year,
           pf.film,
           bo.box_office_worldwide,
           ROW_NUMBER() OVER (
               PARTITION BY YEAR(STR_TO_DATE(pf.release_date, '%d-%m-%Y'))
               ORDER BY bo.box_office_worldwide DESC
           ) AS rnk
    FROM pixar_films pf
    JOIN box_office bo ON pf.film = bo.film
)
SELECT release_year,
       film,
       box_office_worldwide
FROM cte
WHERE rnk = 1
ORDER BY release_year;


-- ============================================================
-- 10. HIDDEN GEMS DETECTION
-- Question:
-- Which films have low budgets but high returns?
-- Hint:
-- Calculate average budget and average worldwide revenue first.
-- Select films below average budget but above average revenue.
-- Rank by ROI.
-- ============================================================

WITH avg_values AS (
    SELECT AVG(budget) AS avg_budget,
           AVG(box_office_worldwide) AS avg_revenue
    FROM box_office
),
film_data AS (
    SELECT pf.film,
           bo.budget,
           bo.box_office_worldwide
    FROM pixar_films pf
    JOIN box_office bo ON pf.film = bo.film
)
SELECT fd.film,
       fd.budget,
       fd.box_office_worldwide,
       ROUND(
           (fd.box_office_worldwide - fd.budget) / fd.budget,
           2
       ) AS ROI
FROM film_data fd
CROSS JOIN avg_values av
WHERE fd.budget < av.avg_budget
  AND fd.box_office_worldwide > av.avg_revenue
ORDER BY ROI DESC;


-- ============================================================
-- END
-- ============================================================
