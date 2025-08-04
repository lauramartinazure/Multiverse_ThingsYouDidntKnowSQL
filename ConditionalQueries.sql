-- (1)

-- Count total customers and break them down by marital status using FILTER.
-- FILTER allows conditional aggregation directly inside the COUNT() function 
-- important: FILTER aggregates only non-NULL values.
-- Useful for understanding the composition of your customer base.
SELECT
  COUNT(*) AS total_customers,
  COUNT(*) FILTER (WHERE "MaritalStatus" = 'M') AS married_customers,
  COUNT(*) FILTER (WHERE "MaritalStatus" = 'S') AS single_customers
FROM "Contoso_Customers";

-- Alternative Method: Equivalent query using CASE [..] WHEN syntax.
-- CASE WHEN creates conditional values that COUNT() includes only if not NULL.
-- Both queries return exactly the same result.
-- FILTER is more concise and readable, especially when multiple conditions are used.
-- CASE WHEN is more widely supported across SQL engines (e.g., MySQL doesn't support FILTER but does support CASE WHEN).

SELECT
  COUNT(*) AS total_customers,
  COUNT(CASE WHEN "MaritalStatus" = 'M' THEN 1 END) AS married_customers,
  COUNT(CASE WHEN "MaritalStatus" = 'S' THEN 1 END) AS single_customers
FROM "Contoso_Customers";

-- (2)
-- Group customers by gender and count how many are homeowners vs renters using FILTER.
-- This helps segment customers by gender and housing status—valuable for targeted marketing or risk modelling.
SELECT
  "Gender",
  COUNT(*) FILTER (WHERE "HouseOwnerFlag" = '1') AS homeowners,
  COUNT(*) FILTER (WHERE "HouseOwnerFlag" = '0') AS renters
FROM "Contoso_Customers"
GROUP BY "Gender";

-- (3)
-- Calculate average price and total product count for each stock type.
-- GROUP BY groups data by product category, allowing business to analyse product pricing trends.
SELECT
  "StockTypeName",
  COUNT(*) AS product_count,
  AVG("UnitPrice") AS avg_price
FROM "Contoso_Products"
GROUP BY "StockTypeName";

-- (4)
-- Compare average quantity sold for discounted vs full-price items.
-- FILTER separates rows with and without discounts—useful for discount impact analysis.
SELECT
  AVG("SalesQuantity") FILTER (WHERE "DiscountAmount" > 0) AS avg_discounted_sales,
  AVG("SalesQuantity") FILTER (WHERE "DiscountAmount" = 0) AS avg_full_price_sales
FROM "Contoso_Sales";

-- (5)
-- Compare total revenue from sales with and without returns.
-- Helps assess how much of your revenue is potentially at risk from product returns.
SELECT
  SUM("SalesAmount") FILTER (WHERE "ReturnQuantity" = 0) AS revenue_no_returns,
  SUM("SalesAmount") FILTER (WHERE "ReturnQuantity" > 0) AS revenue_with_returns
FROM "Contoso_Sales";

-- (6)
-- Show cost of returned vs non-returned items per product.
-- GROUP BY and FILTER combined provide granular view of product-level return impact.
SELECT
  "ProductKey",
  SUM("TotalCost") FILTER (WHERE "ReturnQuantity" > 0) AS returned_cost,
  SUM("TotalCost") FILTER (WHERE "ReturnQuantity" = 0) AS non_returned_cost
FROM "Contoso_Sales"
GROUP BY "ProductKey"
ORDER BY "ProductKey";

-- (7)
-- Segment customer counts by gender, with counts for those who have children and who are homeowners.
-- Multiple FILTER clauses in one query allow multidimensional demographic analysis.
SELECT
  "Gender",
  COUNT(*) AS total,
  COUNT(*) FILTER (WHERE "NumberChildrenAtHome" > 0) AS with_kids,
  COUNT(*) FILTER (WHERE "HouseOwnerFlag" = 1) AS homeowners
FROM "Contoso_Customers"
GROUP BY "Gender";
