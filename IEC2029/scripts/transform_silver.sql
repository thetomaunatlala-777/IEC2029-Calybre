-- ============================================================
-- SILVER LAYER TRANSFORMS
-- ============================================================

-- ── Create election_results table ────────────────────────────
CREATE TABLE silver."election_results" AS
SELECT "province"::TEXT, "municipality"::TEXT, "voting_district"::INTEGER, "party_name"::TEXT,
       "registered_population"::INTEGER, "voter_turnout_percent"::DOUBLE PRECISION,
       "total_votes_cast"::INTEGER, "year"::INTEGER, "election_type"::TEXT
FROM bronze."2004_npe"

UNION ALL
SELECT "province"::TEXT, "municipality"::TEXT, "voting_district"::INTEGER, "party_name"::TEXT,
       "registered_population"::INTEGER, "voter_turnout_percent"::DOUBLE PRECISION,
       "total_votes_cast"::INTEGER, "year"::INTEGER, "election_type"::TEXT
FROM bronze."2009_npe"

UNION ALL
SELECT "province"::TEXT, "municipality"::TEXT, "voting_district"::INTEGER, "party_name"::TEXT,
       "registered_population"::INTEGER, "voter_turnout_percent"::DOUBLE PRECISION,
       "total_votes_cast"::INTEGER, "year"::INTEGER, "election_type"::TEXT
FROM bronze."2014_npe"

UNION ALL
SELECT "province"::TEXT, "municipality"::TEXT, "voting_district"::INTEGER, "party_name"::TEXT,
       "registered_population"::INTEGER, NULL::DOUBLE PRECISION AS voter_turnout_percent,
       "total_votes_cast"::INTEGER, "year"::INTEGER, "election_type"::TEXT
FROM bronze."2019_national"

UNION ALL
SELECT "province"::TEXT, "municipality"::TEXT, "voting_district"::INTEGER, "party_name"::TEXT,
       "registered_population"::INTEGER, NULL::DOUBLE PRECISION AS voter_turnout_percent,
       "total_votes_cast"::INTEGER, "year"::INTEGER, "election_type"::TEXT
FROM bronze."2019_provincial"

UNION ALL
SELECT "province"::TEXT, "municipality"::TEXT, "voting_district"::INTEGER, "party_name"::TEXT,
       "registered_population"::INTEGER, NULL::DOUBLE PRECISION AS voter_turnout_percent,
       "total_votes_cast"::INTEGER, "year"::INTEGER, "election_type"::TEXT
FROM bronze."2024_national"

UNION ALL
SELECT "province"::TEXT, "municipality"::TEXT, "voting_district"::INTEGER, "party_name"::TEXT,
       "registered_population"::INTEGER, NULL::DOUBLE PRECISION AS voter_turnout_percent,
       "total_votes_cast"::INTEGER, "year"::INTEGER, "election_type"::TEXT
FROM bronze."2024_provincial";


-- ── Rename party_votes column ─────────────────────────────────
ALTER TABLE silver.election_results RENAME COLUMN "total_votes_cast" TO "party_votes";


-- ── Add total_votes column ────────────────────────────────────
ALTER TABLE silver."election_results" ADD COLUMN total_votes INTEGER;

UPDATE silver."election_results" t
SET total_votes = sub.total_votes
FROM (
    SELECT voting_district, year, election_type, SUM(party_votes) AS total_votes
    FROM silver."election_results"
    GROUP BY voting_district, year, election_type
) sub
WHERE t.voting_district = sub.voting_district
  AND t.year = sub.year
  AND t.election_type = sub.election_type;


-- ── Recalculate voter_turnout_percent ─────────────────────────
UPDATE silver."election_results"
SET voter_turnout_percent = ROUND(
    (total_votes::DOUBLE PRECISION / NULLIF(registered_population, 0) * 100)::NUMERIC, 2
);


-- ── Add ward column from voting_stations ──────────────────────
ALTER TABLE silver."election_results" ADD COLUMN IF NOT EXISTS ward INTEGER;

UPDATE silver."election_results" e
SET ward = NULLIF(v.ward, '')::INTEGER
FROM bronze."voting_stations" v
WHERE e.voting_district = v.vd_number;


-- ── Create population table ───────────────────────────────────
CREATE TABLE silver."population" AS
SELECT
    a."Ward_Code",
    a."0-4", a."5-9", a."10-14", a."15-19", a."20-24", a."25-29",
    a."30-34", a."35-39", a."40-44", a."45-49", a."50-54", a."55-59",
    a."60-64", a."65-69", a."70-74", a."75-79", a."80-84", a."85+",
    a."Total" AS total_age_population,
    g."Black African", g."Coloured", g."Indian/Asian", g."White", g."Other",
    g."Total" AS total_group_population,
    s."Male", s."Female",
    s."Total" AS total_sex_population
FROM bronze.pp_age_group_27_10_2025 a
INNER JOIN bronze.pp_population_group_27_10_2025 g ON a."Ward_Code" = g."Ward_Code"
INNER JOIN bronze.pp_sex_27_10_2025 s ON a."Ward_Code" = s."WARD_CODE";

ALTER TABLE silver.population RENAME COLUMN "Ward_Code" TO "ward_number";

ALTER TABLE silver."population"
ALTER COLUMN "ward_number" TYPE INTEGER
USING CASE WHEN "ward_number" ~ '^\d+$' THEN "ward_number"::INTEGER ELSE NULL END;

DELETE FROM silver.population WHERE "ward_number" IS NULL;


-- ── Create geo table ──────────────────────────────────────────
DELETE FROM bronze.voting_stations WHERE station_latitude IS NULL;

CREATE TABLE silver."geo" (
    vd_number INTEGER NOT NULL,
    station_latitude DOUBLE PRECISION NOT NULL,
    station_longitude DOUBLE PRECISION NOT NULL
);

INSERT INTO silver.geo (vd_number, station_latitude, station_longitude)
SELECT vd_number, station_latitude::DOUBLE PRECISION, station_longitude::DOUBLE PRECISION
FROM bronze.voting_stations
WHERE station_latitude != '' AND station_longitude != '';

ALTER TABLE silver.geo RENAME COLUMN "vd_number" TO "voting_district";