-- =============================================================================
-- SILVER → GOLD TRANSFORMATION SCRIPT
-- Election Results, Demographics & Geospatial Data
-- =============================================================================


-- =============================================================================
-- SECTION 1: SILVER LAYER — FINAL ADJUSTMENTS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1.1  Rename column to better reflect row-level (per-party) granularity
-- -----------------------------------------------------------------------------

ALTER TABLE silver."election_results"
    RENAME COLUMN "total_votes_cast" TO "party_votes";


-- -----------------------------------------------------------------------------
-- 1.2  Add total_votes column
--      Aggregates all party votes at the voting_district / year / election_type
--      level so each row carries the district-wide total alongside party_votes
-- -----------------------------------------------------------------------------

ALTER TABLE silver."election_results"
    ADD COLUMN total_votes INTEGER;

UPDATE silver."election_results" t
SET total_votes = sub.total_votes
FROM (
    SELECT
        voting_district,
        year,
        election_type,
        SUM(party_votes) AS total_votes
    FROM silver."election_results"
    GROUP BY voting_district, year, election_type
) sub
WHERE t.voting_district = sub.voting_district
  AND t.year            = sub.year
  AND t.election_type   = sub.election_type;


-- -----------------------------------------------------------------------------
-- 1.3  Backfill voter_turnout_percent for 2019 / 2024 rows
--      (those years had no turnout column; derived from total_votes / registered)
-- -----------------------------------------------------------------------------

UPDATE silver."election_results"
SET voter_turnout_percent =
    ROUND(
        (
            total_votes::DOUBLE PRECISION
            / NULLIF(registered_population, 0)
            * 100
        )::NUMERIC,
        2
    );


-- =============================================================================
-- SECTION 2: SILVER GEO TABLE
--      Clean voting station coordinates for spatial lookups
-- =============================================================================

-- Remove stations with no coordinates
CREATE TABLE silver."geo" ( ... );

INSERT INTO silver."geo" (vd_number, station_latitude, station_longitude)
SELECT vd_number, station_latitude::DOUBLE PRECISION, station_longitude::DOUBLE PRECISION
FROM bronze.voting_stations
WHERE station_latitude  IS NOT NULL AND station_latitude  != ''
  AND station_longitude IS NOT NULL AND station_longitude != '';
ALTER TABLE silver."geo"
    RENAME COLUMN "vd_number" TO "voting_district";


-- =============================================================================
-- SECTION 3: GOLD DIMENSION TABLES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 3.1  dim: party
-- -----------------------------------------------------------------------------

CREATE TABLE gold."party" (
    party_id   SERIAL PRIMARY KEY,
    party_name TEXT NOT NULL
);

INSERT INTO gold."party" (party_name)
SELECT DISTINCT party_name
FROM silver."election_results";


-- -----------------------------------------------------------------------------
-- 3.2  dim: demographic
--      Sourced from silver.population; ward_number is the natural key
-- -----------------------------------------------------------------------------

CREATE TABLE gold."demographic" (
    ward_number            INTEGER           PRIMARY KEY,
    -- Age bands
    "0-4"                  DOUBLE PRECISION,
    "5-9"                  DOUBLE PRECISION,
    "10-14"                DOUBLE PRECISION,
    "15-19"                DOUBLE PRECISION,
    "20-24"                DOUBLE PRECISION,
    "25-29"                DOUBLE PRECISION,
    "30-34"                DOUBLE PRECISION,
    "35-39"                DOUBLE PRECISION,
    "40-44"                DOUBLE PRECISION,
    "45-49"                DOUBLE PRECISION,
    "50-54"                DOUBLE PRECISION,
    "55-59"                DOUBLE PRECISION,
    "60-64"                DOUBLE PRECISION,
    "65-69"                DOUBLE PRECISION,
    "70-74"                DOUBLE PRECISION,
    "75-79"                DOUBLE PRECISION,
    "80-84"                DOUBLE PRECISION,
    "85+"                  DOUBLE PRECISION,
    total_age_population   DOUBLE PRECISION,
    -- Population groups
    "Black African"        DOUBLE PRECISION,
    "Coloured"             DOUBLE PRECISION,
    "Indian/Asian"         DOUBLE PRECISION,
    "White"                DOUBLE PRECISION,
    "Other"                DOUBLE PRECISION,
    total_group_population DOUBLE PRECISION,
    -- Sex
    "Male"                 DOUBLE PRECISION,
    "Female"               DOUBLE PRECISION,
    total_sex_population   DOUBLE PRECISION
);

INSERT INTO gold."demographic" (
    ward_number,
    "0-4", "5-9", "10-14", "15-19", "20-24", "25-29",
    "30-34", "35-39", "40-44", "45-49", "50-54", "55-59",
    "60-64", "65-69", "70-74", "75-79", "80-84", "85+",
    total_age_population,
    "Black African", "Coloured", "Indian/Asian", "White", "Other",
    total_group_population,
    "Male", "Female", total_sex_population
)
SELECT
    ward_number,
    "0-4"::DOUBLE PRECISION,  "5-9"::DOUBLE PRECISION,  "10-14"::DOUBLE PRECISION,
    "15-19"::DOUBLE PRECISION, "20-24"::DOUBLE PRECISION, "25-29"::DOUBLE PRECISION,
    "30-34"::DOUBLE PRECISION, "35-39"::DOUBLE PRECISION, "40-44"::DOUBLE PRECISION,
    "45-49"::DOUBLE PRECISION, "50-54"::DOUBLE PRECISION, "55-59"::DOUBLE PRECISION,
    "60-64"::DOUBLE PRECISION, "65-69"::DOUBLE PRECISION, "70-74"::DOUBLE PRECISION,
    "75-79"::DOUBLE PRECISION, "80-84"::DOUBLE PRECISION, "85+"::DOUBLE PRECISION,
    total_age_population::DOUBLE PRECISION,
    "Black African"::DOUBLE PRECISION, "Coloured"::DOUBLE PRECISION,
    "Indian/Asian"::DOUBLE PRECISION,  "White"::DOUBLE PRECISION,
    "Other"::DOUBLE PRECISION,
    total_group_population::DOUBLE PRECISION,
    "Male"::DOUBLE PRECISION, "Female"::DOUBLE PRECISION,
    total_sex_population::DOUBLE PRECISION
FROM silver."population";


-- -----------------------------------------------------------------------------
-- 3.3  dim: location
--      Province / ward / voting_district hierarchy
--      Scoped to 2019+ where ward data is reliable
--      FK to demographic ensures only known wards are included
-- -----------------------------------------------------------------------------

CREATE TABLE gold."location" (
    location_id     SERIAL  PRIMARY KEY,
    province        TEXT    NOT NULL,
    ward_number     INTEGER NOT NULL,
    voting_district INTEGER NOT NULL,
    FOREIGN KEY (ward_number) REFERENCES gold."demographic"(ward_number)
);

INSERT INTO gold."location" (province, ward_number, voting_district)
SELECT DISTINCT
    UPPER(e.province),
    e.ward AS ward_number,
    e.voting_district
FROM silver."election_results" e
WHERE e.ward IS NOT NULL
  AND e.year >= 2019;


-- -----------------------------------------------------------------------------
-- 3.4  dim: date
-- -----------------------------------------------------------------------------

CREATE TABLE gold."date" (
    date_id       SERIAL PRIMARY KEY,
    year          INTEGER NOT NULL,
    election_type TEXT    NOT NULL
);

INSERT INTO gold."date" (year, election_type)
SELECT DISTINCT
    year,
    election_type
FROM silver."election_results";


-- =============================================================================
-- SECTION 4: GOLD FACT TABLE
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 4.1  fact: vote
--      One row per party / voting_district / election event
--      voter_turnout_percent recalculated here for consistency
-- -----------------------------------------------------------------------------

CREATE TABLE gold."vote" (
    vote_id                SERIAL           PRIMARY KEY,
    registered_population  INTEGER          NOT NULL,
    voter_turnout_percent  DOUBLE PRECISION NOT NULL,
    party_votes            INTEGER          NOT NULL,
    total_votes            INTEGER          NOT NULL,
    location_id            INTEGER          NOT NULL,
    party_id               INTEGER          NOT NULL,
    date_id                INTEGER          NOT NULL,
    FOREIGN KEY (location_id) REFERENCES gold."location"(location_id),
    FOREIGN KEY (party_id)    REFERENCES gold."party"(party_id),
    FOREIGN KEY (date_id)     REFERENCES gold."date"(date_id)
);

INSERT INTO gold."vote" (
    registered_population,
    voter_turnout_percent,
    party_votes,
    total_votes,
    location_id,
    party_id,
    date_id
)
SELECT
    e.registered_population,
    CASE
        WHEN e.total_votes = 0 OR e.registered_population = 0 THEN 0
        ELSE ROUND(
                (e.total_votes::NUMERIC / e.registered_population::NUMERIC) * 100,
                2
             )::DOUBLE PRECISION
    END AS voter_turnout_percent,
    e.party_votes,
    e.total_votes,
    l.location_id,
    p.party_id,
    d.date_id
FROM silver."election_results" e
JOIN gold."location" l
    ON  e.voting_district = l.voting_district
    AND e.ward            = l.ward_number
JOIN gold."party" p
    ON  e.party_name = p.party_name
JOIN gold."date" d
    ON  e.year          = d.year
    AND e.election_type = d.election_type;

