-- Query to create a simple table with a JSON friendly_name
-- Note the jsonb (json binary) data type

CREATE TABLE products_json (
  ProductID serial PRIMARY KEY,
  ProductName text,
  Attributes jsonb
);

INSERT INTO products_json (ProductName, Attributes)
VALUES
  (
    'Smartphone X100',
    '{"colour": "Black", "warranty": "2 years", "features": ["5G", "OLED display", "Dual SIM"]}'
  ),
  (
    'Laptop Z200',
    '{"colour": "Silver", "warranty": "1 year", "features": ["Touchscreen", "SSD", "Backlit keyboard"]}'
  ),
  (
    'Headphones A50',
    '{"colour": "Blue", "warranty": "6 months", "features": ["Noise cancelling", "Bluetooth"]}'
  ),
  (
    'Smartwatch W10',
    '{"colour": "Black", "warranty": "1 year", "features": ["Heart rate", "GPS", "Waterproof"]}'
  ),
  (
    'Tablet M7',
    '{"colour": "White", "warranty": "2 years", "features": ["Stylus support", "Wi-Fi + LTE"]}'
  ),
  (
    'Camera ProShot',
    '{"colour": "Black", "warranty": "1 year", "features": ["4K video", "Wi-Fi", "Interchangeable lens"]}'
  ),
  (
    'Gaming Console GX',
    '{"colour": "White", "warranty": "3 years", "features": ["4K gaming", "HDR", "Wireless controller"]}'
  ),
  (
    'Bluetooth Speaker Boom',
    '{"colour": "Red", "warranty": "1 year", "features": ["Water resistant", "12h battery", "Voice control"]}'
  ),
  (
    'E-Reader Lite',
    '{"colour": "Gray", "warranty": "2 years", "features": ["Backlit display", "Long battery life"]}'
  ),
  (
    'Wireless Charger Pad',
    '{"colour": "Black", "warranty": "6 months", "features": ["Fast charging", "LED indicator"]}'
  );


-- Selecting a single attribute from JSON field
-- ->> extracts the text value of a JSON key
SELECT 
  ProductName, 
  Attributes->>'colour' AS colour 
FROM products_json;

-- Applying a filter using the elements of a JSON field
SELECT 
  ProductName, 
  Attributes->>'colour' AS colour
FROM products_json
WHERE Attributes->>'colour' = 'Black';

-- Using an array search to count items with a specific feature
-- @> means "contains".
-- This query returns products where features includes "4K video".
-- '["4K video"]'::jsonb must be cast explicitly as JSONB.

SELECT 
  ProductName, 
  Attributes->'features' AS features
FROM products_json
WHERE Attributes->'features' @> '["4K video"]'::jsonb;

-- Filtering using the 'in' syntax
SELECT 
  ProductName, 
  Attributes->>'warranty' AS warranty
FROM products_json
WHERE Attributes->>'warranty' IN ('2 years', '3 years');

-- Extract all distinct values from a JSON field (similar to a typical column)
SELECT DISTINCT Attributes->>'warranty' AS warranty
FROM products_json;

-- Function jsonb_array_elements_text() expands a JSON array into multiple rows.
-- Each feature gets its own row → perfect for filtering, grouping, or analysis.

SELECT 
  ProductName, 
  jsonb_array_elements_text(Attributes->'features') AS feature
FROM products_json;

-- Extracting a number from a JSON field 
SELECT 
  ProductName,
  (regexp_match(Attributes->>'warranty', '\d+'))[1]::INT AS warranty_years
FROM products_json;
