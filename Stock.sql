-- ============================================================================
-- VW Constantia Used Stock — Comprehensive Inventory Analysis
-- ============================================================================

-- Create a temp view for easy reference across all output statements
CREATE OR REPLACE TEMP VIEW stock AS
SELECT * FROM `casestudy`.`default`.`march_used_stock_3`;

-- === OUTPUT 1: Overall Inventory Summary ===
SELECT
  COUNT(*) AS total_vehicles,
  COUNT(DISTINCT Make) AS distinct_makes,
  COUNT(DISTINCT Model) AS distinct_models,
  COUNT(DISTINCT `Stock Colour`) AS distinct_colours,
  MIN(ModelYear) AS oldest_year,
  MAX(ModelYear) AS newest_year,
  ROUND(MIN(`Incl Vat `), 2) AS min_price_incl_vat,
  ROUND(MAX(`Incl Vat `), 2) AS max_price_incl_vat,
  ROUND(AVG(`Incl Vat `), 2) AS avg_price_incl_vat,
  ROUND(MIN(`Ex Vat`), 2) AS min_price_ex_vat,
  ROUND(MAX(`Ex Vat`), 2) AS max_price_ex_vat,
  ROUND(AVG(`Ex Vat`), 2) AS avg_price_ex_vat
FROM stock;

-- === OUTPUT 2: Breakdown by Make ===
SELECT
  Make,
  COUNT(*) AS vehicle_count,
  ROUND(AVG(`Incl Vat `), 2) AS avg_price_incl_vat,
  ROUND(MIN(`Incl Vat `), 2) AS min_price_incl_vat,
  ROUND(MAX(`Incl Vat `), 2) AS max_price_incl_vat,
  MIN(ModelYear) AS oldest_year,
  MAX(ModelYear) AS newest_year,
  COUNT(DISTINCT Model) AS model_variants,
  COUNT(DISTINCT `Stock Colour`) AS colour_variants
FROM stock
GROUP BY Make
ORDER BY vehicle_count DESC;

-- === OUTPUT 3: Breakdown by Model Year ===
SELECT
  ModelYear,
  COUNT(*) AS vehicle_count,
  ROUND(AVG(`Incl Vat `), 2) AS avg_price_incl_vat,
  ROUND(MIN(`Incl Vat `), 2) AS min_price_incl_vat,
  ROUND(MAX(`Incl Vat `), 2) AS max_price_incl_vat,
  COUNT(DISTINCT Make) AS distinct_makes
FROM stock
GROUP BY ModelYear
ORDER BY ModelYear DESC;

-- === OUTPUT 4: Breakdown by Stock Colour ===
SELECT
  `Stock Colour`,
  COUNT(*) AS vehicle_count,
  ROUND(AVG(`Incl Vat `), 2) AS avg_price_incl_vat,
  ROUND(MIN(`Incl Vat `), 2) AS min_price_incl_vat,
  ROUND(MAX(`Incl Vat `), 2) AS max_price_incl_vat,
  COUNT(DISTINCT Make) AS distinct_makes,
  COUNT(DISTINCT Model) AS distinct_models
FROM stock
GROUP BY `Stock Colour`
ORDER BY vehicle_count DESC;

-- === OUTPUT 5: Price Band Distribution ===
SELECT
  CASE
    WHEN `Incl Vat ` < 200000 THEN 'Under R200K'
    WHEN `Incl Vat ` < 400000 THEN 'R200K - R400K'
    WHEN `Incl Vat ` < 600000 THEN 'R400K - R600K'
    WHEN `Incl Vat ` < 800000 THEN 'R600K - R800K'
    WHEN `Incl Vat ` < 1000000 THEN 'R800K - R1M'
    ELSE 'Over R1M'
  END AS price_band,
  COUNT(*) AS vehicle_count,
  ROUND(AVG(`Incl Vat `), 2) AS avg_price,
  COUNT(DISTINCT Make) AS distinct_makes
FROM stock
GROUP BY price_band
ORDER BY MIN(`Incl Vat `);

-- === OUTPUT 6: Full Vehicle Detail with Price Rankings ===
SELECT
  Make,
  Model,
  ModelYear,
  `Stock Colour`,
  ROUND(`Incl Vat `, 2) AS price_incl_vat,
  ROUND(`Ex Vat`, 2) AS price_ex_vat,
  RANK() OVER (ORDER BY `Incl Vat ` DESC) AS price_rank_overall,
  RANK() OVER (PARTITION BY Make ORDER BY `Incl Vat ` DESC) AS price_rank_by_make
FROM stock
ORDER BY `Incl Vat ` DESC;

-- === OUTPUT 7: Top 5 Most Expensive Vehicles ===
SELECT
  Make,
  Model,
  ModelYear,
  `Stock Colour`,
  ROUND(`Incl Vat `, 2) AS price_incl_vat
FROM stock
ORDER BY `Incl Vat ` DESC
LIMIT 5;

-- === OUTPUT 8: Top 5 Least Expensive Vehicles ===
SELECT
  Make,
  Model,
  ModelYear,
  `Stock Colour`,
  ROUND(`Incl Vat `, 2) AS price_incl_vat
FROM stock
ORDER BY `Incl Vat ` ASC
LIMIT 5;

-- === OUTPUT 9: Average Price by Make (sorted, with variance) ===
SELECT
  Make,
  COUNT(*) AS vehicle_count,
  ROUND(AVG(`Incl Vat `), 2) AS avg_price_incl_vat,
  ROUND(STDDEV(`Incl Vat `), 2) AS price_stddev,
  ROUND((MAX(`Incl Vat `) - MIN(`Incl Vat `)), 2) AS price_range
FROM stock
GROUP BY Make
ORDER BY avg_price_incl_vat DESC;

-- === OUTPUT 10: Inventory Age Analysis ===
SELECT
  CASE
    WHEN ModelYear >= 2024 THEN 'Current (2024+)'
    WHEN ModelYear >= 2020 THEN 'Recent (2020-2023)'
    WHEN ModelYear >= 2015 THEN 'Older (2015-2019)'
    ELSE 'Vintage (pre-2015)'
  END AS age_category,
  COUNT(*) AS vehicle_count,
  COUNT(DISTINCT Make) AS distinct_makes,
  ROUND(AVG(`Incl Vat `), 2) AS avg_price_incl_vat
FROM stock
GROUP BY age_category
ORDER BY MIN(ModelYear) DESC;
