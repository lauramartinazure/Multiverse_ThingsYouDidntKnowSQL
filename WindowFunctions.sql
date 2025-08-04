-- Summary of Window Function Syntax

-- <function>() OVER (
--     PARTITION BY <optional grouping column>
--     ORDER BY <column that determines row order>
-- )
-- PARTITION BY: defines groups to calculate the window function separately.

-- ORDER BY: defines the order of rows within each partition.

-- You can omit PARTITION BY to calculate across the entire dataset.

-- (1)
-- Assign a sequential sale number per store, ordered by sale date.
-- Useful for tracking the order of sales events or identifying first/last sale in a store.
SELECT
  "StoreKey",
  "DateKey",
  "SalesKey",
  ROW_NUMBER() OVER (PARTITION BY "StoreKey" ORDER BY "DateKey") AS sale_sequence
FROM "Contoso_Sales";

-- (2)
-- Rank products by sales amount across the entire dataset (highest first).
-- Helps identify top-performing products overall.
SELECT
  "ProductKey",
  "SalesAmount",
  RANK() OVER (ORDER BY "SalesAmount" DESC) AS revenue_rank
FROM "Contoso_Sales";

-- Augmented version with product names for better reporting.
-- Makes the ranking more human-readable and useful for business users.
SELECT
  p."ProductKey",
  pr."ProductName",
  p."SalesAmount",
  RANK() OVER (ORDER BY p."SalesAmount" DESC) AS revenue_rank
FROM "Contoso_Sales" p
JOIN "Contoso_Products" pr ON p."ProductKey" = pr."ProductKey";

-- (3)
-- Show previous day's quantity sold for each product (per product).
-- LAG lets you compare current sales with previous sales to spot trends or drops.
SELECT
  "ProductKey",
  "DateKey",
  "SalesQuantity",
  LAG("SalesQuantity") OVER (PARTITION BY "ProductKey" ORDER BY "DateKey") AS prev_quantity
FROM "Contoso_Sales";

-- (4)
-- Show next recorded price per product (based on sale date).
-- LEAD is useful for price change tracking or forecasting.
SELECT
  "ProductKey",
  "DateKey",
  "UnitPrice",
  LEAD("UnitPrice") OVER (PARTITION BY "ProductKey" ORDER BY "DateKey") AS next_price
FROM "Contoso_Sales";

-- (5)
-- Calculate a running total of sales amount per product over time.
-- Great for cumulative sales analysis or growth monitoring.
SELECT
  "ProductKey",
  "DateKey",
  "SalesAmount",
  SUM("SalesAmount") OVER (PARTITION BY "ProductKey" ORDER BY "DateKey") AS running_total
FROM "Contoso_Sales";

-- (6)
-- Group sales by week and calculate a running total within each weekly window.
-- Combines date grouping with windowing to analyse trends within time periods.
SELECT
  "ProductKey",
  date_trunc('week', "DateKey") AS sales_week,
  "SalesAmount",
  SUM("SalesAmount") OVER (
    PARTITION BY "ProductKey", date_trunc('week', "DateKey")
    ORDER BY "DateKey"
  ) AS weekly_running_total
FROM "Contoso_Sales";

-- (1)
-- Aggregate monthly sales per product and rank products by revenue within each month.
-- Helps compare product performance **within** each calendar month.
SELECT
  "ProductKey",
  date_trunc('month', "DateKey") AS sales_month,
  SUM("SalesAmount") AS total_monthly_revenue,
  RANK() OVER (
    PARTITION BY date_trunc('month', "DateKey")
    ORDER BY SUM("SalesAmount") DESC
  ) AS monthly_revenue_rank
FROM "Contoso_Sales"
GROUP BY "ProductKey", date_trunc('month', "DateKey");
