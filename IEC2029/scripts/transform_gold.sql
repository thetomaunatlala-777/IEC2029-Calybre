-- ============================================================
-- GOLD LAYER TRANSFORMS
-- ============================================================

-- ── Dimension: party ──────────────────────────────────────────
CREATE TABLE gold."party" (
    party_id SERIAL PRIMARY KEY,
    party_name TEXT NOT NULL
);

INSERT INTO gold."party" (party_name)
SELECT DISTINCT party_name FROM silver."election_results";


-- ── Dimension: demographic ────────────────────────────────────
CREATE TABLE gold."demographic" (
    ward_number SERIAL PRIMARY KEY,
    "0-4" DOUBLE PRECISION, "5-9" DOUBLE PRECISION, "10-14" DOUBLE PRECISION,
    "15-19" DOUBLE PRECISION, "20-24" DOUBLE PRECISION, "25-29" DOUBLE PRECISION,
    "30-34" DOUBLE PRECISION, "35-39" DOUBLE PRECISION, "40-44" DOUBLE PRECISION,
    "45-49" DOUBLE PRECISION, "50-54" DOUBLE PRECISION, "55-59" DOUBLE PRECISION,
    "60-64" DOUBLE PRECISION, "65-69" DOUBLE PRECISION, "70-74" DOUBLE PRECISION,
    "75-79" DOUBLE PRECISION, "80-84" DOUBLE PRECISION, "85+" DOUBLE PRECISION,
    total_age_population DOUBLE PRECISION,
    "Black African" DOUBLE PRECISION, "Coloured" DOUBLE PRECISION,
    "Indian/Asian" DOUBLE PRECISION, "White" DOUBLE PRECISION, "Other" DOUBLE PRECISION,
    total_group_population DOUBLE PRECISION,
    "Male" DOUBLE PRECISION, "Female" DOUBLE PRECISION,
    total_sex_population DOUBLE PRECISION
);

INSERT INTO gold."demographic" (
    ward_number,
    "0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39",
    "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79",
    "80-84", "85+", total_age_population,
    "Black African", "Coloured", "Indian/Asian", "White", "Other",
    total_group_population, "Male", "Female", total_sex_population
)
SELECT
    ward_number,
    "0-4"::DOUBLE PRECISION, "5-9"::DOUBLE PRECISION, "10-14"::DOUBLE PRECISION,
    "15-19"::DOUBLE PRECISION, "20-24"::DOUBLE PRECISION, "25-29"::DOUBLE PRECISION,
    "30-34"::DOUBLE PRECISION, "35-39"::DOUBLE PRECISION, "40-44"::DOUBLE PRECISION,
    "45-49"::DOUBLE PRECISION, "50-54"::DOUBLE PRECISION, "55-59"::DOUBLE PRECISION,
    "60-64"::DOUBLE PRECISION, "65-69"::DOUBLE PRECISION, "70-74"::DOUBLE PRECISION,
    "75-79"::DOUBLE PRECISION, "80-84"::DOUBLE PRECISION, "85+"::DOUBLE PRECISION,
    total_age_population::DOUBLE PRECISION,
    "Black African"::DOUBLE PRECISION, "Coloured"::DOUBLE PRECISION,
    "Indian/Asian"::DOUBLE PRECISION, "White"::DOUBLE PRECISION, "Other"::DOUBLE PRECISION,
    total_group_population::DOUBLE PRECISION,
    "Male"::DOUBLE PRECISION, "Female"::DOUBLE PRECISION, total_sex_population::DOUBLE PRECISION
FROM silver."population";


-- ── Dimension: location ───────────────────────────────────────
CREATE TABLE gold."location" (
    location_id SERIAL PRIMARY KEY,
    province TEXT NOT NULL,
    municipality TEXT NOT NULL,
    ward_number INTEGER NOT NULL,
    voting_district INTEGER NOT NULL,
    FOREIGN KEY (ward_number) REFERENCES gold."demographic"(ward_number)
);

INSERT INTO gold."location" (province, municipality, ward_number, voting_district)
SELECT DISTINCT e.province, e.municipality, e.ward AS ward_number, e.voting_district
FROM silver."election_results" e
WHERE e.ward IS NOT NULL;


-- ── Dimension: date ───────────────────────────────────────────
CREATE TABLE gold."date" (
    date_id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    election_type TEXT NOT NULL
);

INSERT INTO gold."date" (year, election_type)
SELECT DISTINCT year, election_type FROM silver."election_results";


-- ── Fact: vote ────────────────────────────────────────────────
CREATE TABLE gold."vote" (
    vote_id SERIAL PRIMARY KEY,
    registered_population INTEGER NOT NULL,
    voter_turnout_percent DOUBLE PRECISION NOT NULL,
    party_votes INTEGER NOT NULL,
    total_votes INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    party_id INTEGER NOT NULL,
    date_id INTEGER NOT NULL,
    FOREIGN KEY (location_id) REFERENCES gold."location"(location_id),
    FOREIGN KEY (party_id) REFERENCES gold."party"(party_id),
    FOREIGN KEY (date_id) REFERENCES gold."date"(date_id)
);

INSERT INTO gold."vote" (
    registered_population, voter_turnout_percent, party_votes, total_votes,
    location_id, party_id, date_id
)
SELECT
    e.registered_population,
    CASE
        WHEN e.total_votes = 0 OR e.registered_population = 0 THEN 0
        ELSE ROUND((e.total_votes::NUMERIC / e.registered_population::NUMERIC) * 100, 2)::DOUBLE PRECISION
    END AS voter_turnout_percent,
    e.party_votes,
    e.total_votes,
    l.location_id,
    p.party_id,
    d.date_id
FROM silver."election_results" e
JOIN gold."location" l ON e.voting_district = l.voting_district AND e.ward = l.ward_number
JOIN gold."party"    p ON e.party_name = p.party_name
JOIN gold."date"     d ON e.year = d.year AND e.election_type = d.election_type;


-- ── Data quality checks and fixes ────────────────────────────
UPDATE gold.location SET province = UPPER(province);

DELETE FROM gold.vote WHERE voter_turnout_percent > 100 OR voter_turnout_percent < 0;
DELETE FROM gold.vote WHERE date_id IN (2, 3, 5, 6, 8, 10);


-- ── Add lat/long to location ──────────────────────────────────
ALTER TABLE gold.location
ADD COLUMN station_latitude DOUBLE PRECISION,
ADD COLUMN station_longitude DOUBLE PRECISION;

UPDATE gold.location
SET
    station_latitude  = silver.geo.station_latitude,
    station_longitude = silver.geo.station_longitude
FROM silver.geo
WHERE gold.location.voting_district = silver.geo.voting_district;


-- ── Final checks ──────────────────────────────────────────────
SELECT * FROM gold.demographic;
SELECT * FROM gold.location;
SELECT * FROM gold.party;
SELECT * FROM gold.date;
SELECT * FROM gold.vote;
SELECT DISTINCT province FROM gold.location ORDER BY province;