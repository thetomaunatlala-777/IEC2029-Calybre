-- =============================================================================
-- SILVER LAYER (CLEAN + CONSISTENT SCHEMA)
-- =============================================================================

DROP TABLE IF EXISTS silver.election_results CASCADE;
DROP TABLE IF EXISTS silver.geo CASCADE;

-- =============================================================================
-- MAIN FACT PREP TABLE
-- =============================================================================

CREATE TABLE silver.election_results AS
SELECT
    province::TEXT,
    municipality::TEXT,
    voting_district::INTEGER,
    party_name::TEXT,
    registered_population::INTEGER,
    voter_turnout_percent::DOUBLE PRECISION,
    total_votes_cast::INTEGER AS party_votes,
    year::INTEGER,
    election_type::TEXT
FROM bronze."2004_npe"

UNION ALL

SELECT
    province::TEXT,
    municipality::TEXT,
    voting_district::INTEGER,
    party_name::TEXT,
    registered_population::INTEGER,
    voter_turnout_percent::DOUBLE PRECISION,
    total_votes_cast::INTEGER,
    year::INTEGER,
    election_type::TEXT
FROM bronze."2009_npe"

UNION ALL

SELECT
    province::TEXT,
    municipality::TEXT,
    voting_district::INTEGER,
    party_name::TEXT,
    registered_population::INTEGER,
    voter_turnout_percent::DOUBLE PRECISION,
    total_votes_cast::INTEGER,
    year::INTEGER,
    election_type::TEXT
FROM bronze."2014_npe"

UNION ALL

SELECT
    province::TEXT,
    municipality::TEXT,
    voting_district::INTEGER,
    party_name::TEXT,
    registered_population::INTEGER,
    NULL::DOUBLE PRECISION,
    total_votes_cast::INTEGER,
    year::INTEGER,
    election_type::TEXT
FROM bronze."2019_national"

UNION ALL

SELECT
    province::TEXT,
    municipality::TEXT,
    voting_district::INTEGER,
    party_name::TEXT,
    registered_population::INTEGER,
    NULL::DOUBLE PRECISION,
    total_votes_cast::INTEGER,
    year::INTEGER,
    election_type::TEXT
FROM bronze."2019_provincial"

UNION ALL

SELECT
    province::TEXT,
    municipality::TEXT,
    voting_district::INTEGER,
    party_name::TEXT,
    registered_population::INTEGER,
    NULL::DOUBLE PRECISION,
    total_votes_cast::INTEGER,
    year::INTEGER,
    election_type::TEXT
FROM bronze."2024_national"

UNION ALL

SELECT
    province::TEXT,
    municipality::TEXT,
    voting_district::INTEGER,
    party_name::TEXT,
    registered_population::INTEGER,
    NULL::DOUBLE PRECISION,
    total_votes_cast::INTEGER,
    year::INTEGER,
    election_type::TEXT
FROM bronze."2024_provincial";

-- =============================================================================
-- CLEAN OUT OF RANGE VALUES
-- =============================================================================

UPDATE silver.election_results
SET voter_turnout_percent = NULL
WHERE voter_turnout_percent < 0 OR voter_turnout_percent > 100;

-- =============================================================================
-- GEO TABLE (FIXED)
-- =============================================================================

CREATE TABLE silver.geo AS
SELECT
    vd_number::INTEGER AS voting_district,
    (api_response -> 'VotingStation' -> 0 ->> 'Latitude')::DOUBLE PRECISION AS station_latitude,
    (api_response -> 'VotingStation' -> 0 ->> 'Longitude')::DOUBLE PRECISION AS station_longitude
FROM bronze.voting_stations
WHERE api_response IS NOT NULL
  AND api_response -> 'VotingStation' IS NOT NULL;