-- =============================================================================
-- GOLD LAYER — QUALITY CHECKS & FINAL FIXES
-- =============================================================================


-- =============================================================================
-- SECTION 1: SPOT CHECKS
-- =============================================================================

SELECT * FROM gold."demographic";
SELECT * FROM gold."location";
SELECT * FROM gold."party";
SELECT * FROM gold."date";
SELECT * FROM gold."vote";

-- Verify distinct provinces loaded correctly
SELECT DISTINCT province
FROM gold."location"
ORDER BY province;


-- =============================================================================
-- SECTION 2: DATA QUALITY FIXES — gold.vote
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 2.1  Remove rows where voter turnout is outside valid range (0–100%)
-- -----------------------------------------------------------------------------

DELETE FROM gold."vote"
WHERE voter_turnout_percent > 100
   OR voter_turnout_percent < 0;


-- -----------------------------------------------------------------------------
-- 2.2  Remove rows where total votes exceed registered population
-- -----------------------------------------------------------------------------

DELETE FROM gold."vote"
WHERE total_votes > registered_population;


-- -----------------------------------------------------------------------------
-- 2.3  Scope analysis to 2019 and 2024 only
-- -----------------------------------------------------------------------------

DELETE FROM gold."vote"
WHERE date_id IN (2, 3, 5, 6, 8, 10);


-- =============================================================================
-- SECTION 3: ADD COORDINATES TO gold.location
--      Joins station lat/lon from silver.geo via voting_district
-- =============================================================================

ALTER TABLE gold."location"
    ADD COLUMN station_latitude  DOUBLE PRECISION,
    ADD COLUMN station_longitude DOUBLE PRECISION;

UPDATE gold."location"
SET
    station_latitude  = g.station_latitude,
    station_longitude = g.station_longitude
FROM silver."geo" g
WHERE gold."location".voting_district = g.voting_district;