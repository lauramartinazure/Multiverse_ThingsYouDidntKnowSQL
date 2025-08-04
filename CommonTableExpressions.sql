-- Common Table Expressions

-- A CTE is like a temporary, named result set that you can refer to later in your query — kind of like creating a subquery with a label.

-- When to Use a CTE
-- Use WITH when:
-- You need to run a subquery that you don’t want to repeat.
-- You want to make your query easier to read and debug.
-- You’re working with aggregated, filtered, or transformed data before further calculations.
-- You're preparing a base dataset for window functions, ranking, or joining to other tables.

-- (1)
-- Basic SELECT using a CTE
-- Creates a named temporary result set ("recent_sales") of all sales after 1 Jan 2009.
-- Useful for simplifying queries or reusing logic without subqueries.
WITH recent_sales AS (
  SELECT *
  FROM "Contoso_Sales"
  WHERE "DateKey" > '2009-01-01'
)
SELECT *
FROM recent_sales;

-- (2)
-- Aggregation using a CTE
-- Precomputes total revenue per product.
-- Makes the main SELECT cleaner and more readable when performing reporting or joining later.
WITH product_sales AS (
  SELECT
    "ProductKey",
    SUM("SalesAmount") AS total_revenue
  FROM "Contoso_Sales"
  GROUP BY "ProductKey"
)
SELECT *
FROM product_sales
ORDER BY total_revenue DESC;

-- (3)
-- CTE with a JOIN for more meaningful output
-- Joins revenue per product with product names for human-readable reporting.
-- Keeps logic modular: revenue calculation is done in the CTE, presentation handled in the main query.
WITH product_sales AS (
  SELECT
    "ProductKey",
    SUM("SalesAmount") AS total_revenue
  FROM "Contoso_Sales"
  GROUP BY "ProductKey"
)
SELECT
  ps."ProductKey",
  p."ProductName",
  ps.total_revenue
FROM product_sales ps
JOIN "Contoso_Products" p ON ps."ProductKey" = p."ProductKey"
ORDER BY ps.total_revenue DESC;

-- (4)
-- CTE with a window function in the main query
-- Calculates monthly revenue per product and then ranks them within each month.
-- Useful for identifying top products each month or creating leaderboards.
WITH monthly_sales AS (
  SELECT
    "ProductKey",
    date_trunc('month', "DateKey") AS sales_month,
    SUM("SalesAmount") AS monthly_revenue
  FROM "Contoso_Sales"
  GROUP BY "ProductKey", date_trunc('month', "DateKey")
)
SELECT
  *,
  RANK() OVER (
    PARTITION BY sales_month
    ORDER BY monthly_revenue DESC
  ) AS revenue_rank
FROM monthly_sales;

-- (5)
-- Multi-CTE chain with ranking and filtering
-- Step 1: Aggregate revenue per product per month.
-- Step 2: Rank products by revenue within each month.
-- Step 3: Return only the top 3 products for each month.
-- Great for top-N reports, performance tracking, or competitive analysis.
WITH monthly_sales AS (
  SELECT
    "ProductKey",
    date_trunc('month', "DateKey") AS sales_month,
    SUM("SalesAmount") AS total_revenue
  FROM "Contoso_Sales"
  GROUP BY "ProductKey", date_trunc('month', "DateKey")
),
ranked_sales AS (
  SELECT *,
         RANK() OVER (
           PARTITION BY sales_month
           ORDER BY total_revenue DESC
         ) AS revenue_rank
  FROM monthly_sales
)
SELECT *
FROM ranked_sales
WHERE revenue_rank <= 3;
