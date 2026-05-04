-- =============================================================================
-- GOLD LAYER (FINAL STAR SCHEMA - CLEAN & RE-RUN SAFE)
-- =============================================================================

-- =============================================================================
-- RESET GOLD
-- =============================================================================

DROP TABLE IF EXISTS gold.vote CASCADE;
DROP TABLE IF EXISTS gold.location CASCADE;
DROP TABLE IF EXISTS gold.party CASCADE;
DROP TABLE IF EXISTS gold.date CASCADE;
DROP TABLE IF EXISTS gold.demographic CASCADE;

-- =============================================================================
-- DIMENSIONS
-- =============================================================================

CREATE TABLE gold.party (
    party_id SERIAL PRIMARY KEY,
    party_name TEXT
);

INSERT INTO gold.party (party_name)
SELECT DISTINCT party_name FROM silver.election_results;

CREATE TABLE gold.date (
    date_id SERIAL PRIMARY KEY,
    year INTEGER,
    election_type TEXT
);

INSERT INTO gold.date (year, election_type)
SELECT DISTINCT year, election_type FROM silver.election_results;

CREATE TABLE gold.demographic AS
SELECT * FROM silver.population;

-- =============================================================================
-- LOCATION DIMENSION
-- =============================================================================

CREATE TABLE gold.location (
    location_id SERIAL PRIMARY KEY,
    province TEXT,
    ward_number INTEGER,
    voting_district INTEGER
);

INSERT INTO gold.location (province, ward_number, voting_district)
SELECT DISTINCT
    province,
    ward,
    voting_district
FROM silver.election_results
WHERE ward IS NOT NULL;

-- =============================================================================
-- GEO JOIN
-- =============================================================================

UPDATE gold.location l
SET
    station_latitude = g.station_latitude,
    station_longitude = g.station_longitude
FROM silver.geo g
WHERE l.voting_district = g.voting_district;

-- =============================================================================
-- FACT TABLE (FIXED TOTAL VOTES LOGIC)
-- =============================================================================

WITH totals AS (
    SELECT
        voting_district,
        year,
        election_type,
        SUM(party_votes) AS total_votes
    FROM silver.election_results
    GROUP BY voting_district, year, election_type
)

CREATE TABLE gold.vote AS
SELECT
    e.registered_population,
    CASE
        WHEN e.registered_population = 0 THEN 0
        ELSE ROUND((e.party_votes::NUMERIC / e.registered_population) * 100, 2)
    END AS voter_turnout_percent,
    e.party_votes,
    t.total_votes,
    l.location_id,
    p.party_id,
    d.date_id
FROM silver.election_results e
JOIN totals t
    ON e.voting_district = t.voting_district
   AND e.year = t.year
   AND e.election_type = t.election_type
JOIN gold.location l
    ON e.voting_district = l.voting_district
JOIN gold.party p
    ON e.party_name = p.party_name
JOIN gold.date d
    ON e.year = d.year
   AND e.election_type = d.election_type;

-- =============================================================================
-- DATA QUALITY CLEANUP
-- =============================================================================

DELETE FROM gold.vote
WHERE voter_turnout_percent > 100
   OR voter_turnout_percent < 0;