-- =============================================================================
-- BRONZE → SILVER TRANSFORMATION SCRIPT
-- Election Results & Demographic Data
-- =============================================================================


-- =============================================================================
-- SECTION 1: COLUMN RENAMING (BRONZE TABLES)
-- Standardises column names: lowercase, no special chars, spaces → underscores
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1.1  2004_npe
-- -----------------------------------------------------------------------------
DO $$
DECLARE
    r        RECORD;
    new_name TEXT;
BEGIN
    FOR r IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '2004_npe'
    LOOP
        new_name := LOWER(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(r.column_name, E'\r', ''),
                    E'\n', ' '),
                ' ', '_'),
            '%', '')
        );

        IF r.column_name <> new_name THEN
            EXECUTE 'ALTER TABLE bronze."2004_npe" RENAME COLUMN "' || r.column_name || '" TO ' || new_name;
        END IF;
    END LOOP;
END $$;

ALTER TABLE bronze."2004_npe"
    RENAME COLUMN "_voter_turnout" TO "voter_turnout_percent";

select * from bronze."2004_npe";


-- -----------------------------------------------------------------------------
-- 1.2  2009_npe
-- -----------------------------------------------------------------------------
DO $$
DECLARE
    r        RECORD;
    new_name TEXT;
BEGIN
    FOR r IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '2009_npe'
    LOOP
        new_name := LOWER(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(r.column_name, E'\r', ''),
                    E'\n', ' '),
                ' ', '_'),
            '%', '')
        );

        IF r.column_name <> new_name THEN
            EXECUTE 'ALTER TABLE bronze."2009_npe" RENAME COLUMN "' || r.column_name || '" TO ' || new_name;
        END IF;
    END LOOP;
END $$;

ALTER TABLE bronze."2009_npe"
    RENAME COLUMN "_voter_turnout" TO "voter_turnout_percent";

select * from bronze."2009_npe";


-- -----------------------------------------------------------------------------
-- 1.3  2014_npe
-- -----------------------------------------------------------------------------
DO $$
DECLARE
    r        RECORD;
    new_name TEXT;
BEGIN
    FOR r IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '2014_npe'
    LOOP
        new_name := LOWER(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(r.column_name, E'\r', ''),
                    E'\n', ' '),
                ' ', '_'),
            '%', '')
        );

        IF r.column_name <> new_name THEN
            EXECUTE 'ALTER TABLE bronze."2014_npe" RENAME COLUMN "' || r.column_name || '" TO ' || new_name;
        END IF;
    END LOOP;
END $$;

ALTER TABLE bronze."2014_npe"
    RENAME COLUMN "_voter_turnout" TO "voter_turnout_percent";

select * from bronze."2014_npe";


-- -----------------------------------------------------------------------------
-- 1.4  2019_national
-- -----------------------------------------------------------------------------
DO $$
DECLARE
    r        RECORD;
    new_name TEXT;
BEGIN
    FOR r IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '2019_national'
    LOOP
        new_name := LOWER(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(r.column_name, E'\r', ''),
                    E'\n', ' '),
                ' ', '_'),
            '%', '')
        );

        IF r.column_name <> new_name THEN
            EXECUTE 'ALTER TABLE bronze."2019_national" RENAME COLUMN "' || r.column_name || '" TO ' || quote_ident(new_name);
        END IF;
    END LOOP;
END $$;

ALTER TABLE bronze."2019_national"
    RENAME COLUMN "spartname" TO "party_name";

select * from bronze."2019_national";

ALTER TABLE bronze."2019_national"
    RENAME COLUMN "total_valid_votes" TO "total_votes_cast";


-- -----------------------------------------------------------------------------
-- 1.5  2019_provincial
-- -----------------------------------------------------------------------------
DO $$
DECLARE
    r        RECORD;
    new_name TEXT;
BEGIN
    FOR r IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '2019_provincial'
    LOOP
        new_name := LOWER(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(r.column_name, E'\r', ''),
                    E'\n', ' '),
                ' ', '_'),
            '%', '')
        );

        IF r.column_name <> new_name THEN
            EXECUTE 'ALTER TABLE bronze."2019_provincial" RENAME COLUMN "' || r.column_name || '" TO ' || quote_ident(new_name);
        END IF;
    END LOOP;
END $$;

ALTER TABLE bronze."2019_provincial"
    RENAME COLUMN "spartyname" TO "party_name";

select * from bronze."2019_provincial";

-- Drop columns with no data
ALTER TABLE bronze."2019_provincial"
    DROP COLUMN "generated_datetime:_30_jun_2020_13:19:48";

ALTER TABLE bronze."2019_provincial"
    DROP COLUMN "unnamed:_10";

ALTER TABLE bronze."2019_provincial"
    RENAME COLUMN "total_valid_votes" TO "total_votes_cast";




-- -----------------------------------------------------------------------------
-- 1.6  2024_national
-- -----------------------------------------------------------------------------
DO $$
DECLARE
    r        RECORD;
    new_name TEXT;
BEGIN
    FOR r IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '2024_national'
    LOOP
        new_name := LOWER(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(r.column_name, E'\r', ''),
                    E'\n', ' '),
                ' ', '_'),
            '%', '')
        );

        IF r.column_name <> new_name THEN
            EXECUTE 'ALTER TABLE bronze."2024_national" RENAME COLUMN "' || r.column_name || '" TO ' || quote_ident(new_name);
        END IF;
    END LOOP;
END $$;

ALTER TABLE bronze."2024_national"
    RENAME COLUMN "spartyname" TO "party_name";

ALTER TABLE bronze."2024_national"
    DROP COLUMN "generated_datetime";

ALTER TABLE bronze."2024_national"
    RENAME COLUMN "ï»¿province" TO "province";


ALTER TABLE bronze."2024_national"
    RENAME COLUMN "total_valid_votes" TO "total_votes_cast";

select * from bronze."2024_national";


-- -----------------------------------------------------------------------------
-- 1.7  2024_provincial
-- -----------------------------------------------------------------------------
DO $$
DECLARE
    r        RECORD;
    new_name TEXT;
BEGIN
    FOR r IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '2024_provincial'
    LOOP
        new_name := LOWER(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(r.column_name, E'\r', ''),
                    E'\n', ' '),
                ' ', '_'),
            '%', '')
        );

        IF r.column_name <> new_name THEN
            EXECUTE 'ALTER TABLE bronze."2024_provincial" RENAME COLUMN "' || r.column_name || '" TO ' || quote_ident(new_name);
        END IF;
    END LOOP;
END $$;

ALTER TABLE bronze."2024_provincial"
    RENAME COLUMN "spartyname"  TO "party_name";

ALTER TABLE bronze."2024_provincial"
    RENAME COLUMN "ï»¿province" TO "province";

ALTER TABLE bronze."2024_provincial"
    DROP COLUMN "generated_datetime";


ALTER TABLE bronze."2024_provincial"
    RENAME COLUMN "total_valid_votes" TO "total_votes_cast";

select * from bronze."2024_provincial";


-- =============================================================================
-- SECTION 2: NULL VALUE CLEANUP
-- =============================================================================

-- 2004_npe: drop rows where municipality is null
-- (voting districts do not exist in voting stations data — only 0.0003% of rows)
DELETE FROM bronze."2004_npe"
WHERE "municipality" IS NULL;

-- 2009_npe: drop rows where ward is null
-- (voting districts do not exist in voting stations data)
DELETE FROM bronze."2009_npe"
WHERE "ward" IS NULL;

-- 2019_national: drop out-of-country rows with no registered population
DELETE FROM bronze."2019_national"
WHERE "registered_population" IS NULL;

-- 2019_national: drop rows with no party name
DELETE FROM bronze."2019_national"
WHERE "party_name" IS NULL;

-- 2019_national: drop generated_datetime column (no data)
ALTER TABLE bronze."2019_national"
    DROP COLUMN "generated_datetime:_30_jun_2020_13:27:18";


-- =============================================================================
-- SECTION 3: DATA TYPE CASTING
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 3.1  2004_npe
-- -----------------------------------------------------------------------------

-- Strip % and cast voter_turnout to numeric
ALTER TABLE bronze."2004_npe"
    ALTER COLUMN "voter_turnout_percent" TYPE DOUBLE PRECISION
    USING REPLACE("voter_turnout_percent", '%', '')::DOUBLE PRECISION;


ALTER TABLE bronze."2004_npe"
    RENAME COLUMN "registered_voters"  TO "registered_population";

ALTER TABLE bronze."2004_npe"
    ALTER COLUMN "voting_district"       TYPE INTEGER USING "voting_district"::INTEGER;

ALTER TABLE bronze."2004_npe"
    ALTER COLUMN "registered_population" TYPE INTEGER USING "registered_population"::INTEGER;

ALTER TABLE bronze."2004_npe"
    ALTER COLUMN "valid_votes"           TYPE INTEGER USING "valid_votes"::INTEGER;

ALTER TABLE bronze."2004_npe"
    ALTER COLUMN "spoilt_votes"          TYPE INTEGER USING "spoilt_votes"::INTEGER;

ALTER TABLE bronze."2004_npe"
    ALTER COLUMN "total_votes_cast"      TYPE INTEGER USING "total_votes_cast"::INTEGER;

select * from bronze."2004_npe";


-- -----------------------------------------------------------------------------
-- 3.2  2009_npe
-- -----------------------------------------------------------------------------

ALTER TABLE bronze."2009_npe"
    RENAME COLUMN "registered_voters" TO "registered_population";

-- Strip commas and cast
ALTER TABLE bronze."2009_npe"
    ALTER COLUMN "registered_population" TYPE INTEGER
    USING REPLACE("registered_population", ',', '')::INTEGER;

ALTER TABLE bronze."2009_npe"
    ALTER COLUMN "voter_turnout_percent" TYPE DOUBLE PRECISION
    USING REPLACE("voter_turnout_percent", '%', '')::DOUBLE PRECISION;

ALTER TABLE bronze."2009_npe"
    ALTER COLUMN "valid_votes"        TYPE INTEGER USING REPLACE("valid_votes",        ',', '')::INTEGER;

ALTER TABLE bronze."2009_npe"
    ALTER COLUMN "total_votes_cast"   TYPE INTEGER USING REPLACE("total_votes_cast",   ',', '')::INTEGER;

ALTER TABLE bronze."2009_npe"
    ALTER COLUMN "section_24a_votes"  TYPE INTEGER USING REPLACE("section_24a_votes",  ',', '')::INTEGER;

ALTER TABLE bronze."2009_npe"
    ALTER COLUMN "special_votes"      TYPE INTEGER USING REPLACE("special_votes",      ',', '')::INTEGER;

ALTER TABLE bronze."2009_npe"
    ALTER COLUMN "voting_district"    TYPE INTEGER USING "voting_district"::INTEGER;

ALTER TABLE bronze."2009_npe"
    ALTER COLUMN "ward"               TYPE INTEGER USING "ward"::INTEGER;

ALTER TABLE bronze."2009_npe"
    ALTER COLUMN "spoilt_votes"       TYPE INTEGER USING "spoilt_votes"::INTEGER;


select * from bronze."2009_npe";


-- -----------------------------------------------------------------------------
-- 3.3  2014_npe
-- -----------------------------------------------------------------------------

ALTER TABLE bronze."2014_npe"
    ALTER COLUMN "ward"             TYPE INTEGER USING "ward"::INTEGER;

ALTER TABLE bronze."2014_npe"
    ALTER COLUMN "voting_district"  TYPE INTEGER USING "voting_district"::INTEGER;

ALTER TABLE bronze."2014_npe"
    RENAME COLUMN "registered_voters" TO "registered_population";

ALTER TABLE bronze."2014_npe"
    ALTER COLUMN "valid_votes"        TYPE INTEGER USING "valid_votes"::INTEGER;

ALTER TABLE bronze."2014_npe"
    ALTER COLUMN "spoilt_votes"       TYPE INTEGER USING "spoilt_votes"::INTEGER;

ALTER TABLE bronze."2014_npe"
    ALTER COLUMN "total_votes_cast"   TYPE INTEGER USING "total_votes_cast"::INTEGER;

ALTER TABLE bronze."2014_npe"
    ALTER COLUMN "section_24a_votes"  TYPE INTEGER USING "section_24a_votes"::INTEGER;

ALTER TABLE bronze."2014_npe"
    ALTER COLUMN "special_votes"      TYPE INTEGER USING "special_votes"::INTEGER;

select * from bronze."2014_npe";

-- Convert decimal ratio → percentage (e.g. 0.65 → 65.00)
UPDATE bronze."2014_npe"
SET "voter_turnout_percent" = ROUND(("voter_turnout_percent" * 100)::NUMERIC, 2);

select * from bronze."2014_npe";


-- -----------------------------------------------------------------------------
-- 3.4  2019_national
-- -----------------------------------------------------------------------------

ALTER TABLE bronze."2019_national"
    RENAME COLUMN "vd_number"          TO "voting_district";

ALTER TABLE bronze."2019_national"
    ALTER COLUMN "voting_district"      TYPE INTEGER USING "voting_district"::INTEGER;

ALTER TABLE bronze."2019_national"
    ALTER COLUMN "registered_population" TYPE INTEGER USING "registered_population"::INTEGER;

ALTER TABLE bronze."2019_national"
    ALTER COLUMN "spoilt_votes"         TYPE INTEGER USING "spoilt_votes"::INTEGER;

---ALTER TABLE bronze."2019_national"
    ---ALTER COLUMN "valid_votes"          TYPE INTEGER USING "valid_votes"::INTEGER;

ALTER TABLE bronze."2019_national"
    ALTER COLUMN "total_votes_cast"     TYPE INTEGER USING "total_votes_cast"::INTEGER;

select * from bronze."2019_national";

-- -----------------------------------------------------------------------------
-- 3.5  2019_provincial
-- -----------------------------------------------------------------------------

select * from bronze."2019_provincial";

ALTER TABLE bronze."2019_provincial"
    RENAME COLUMN "vd_number"         TO "voting_district";


ALTER TABLE bronze."2019_provincial"
    ALTER COLUMN "voting_district" TYPE INTEGER USING "voting_district"::INTEGER;

-- Use CASE to handle any non-numeric comma-formatted values
ALTER TABLE bronze."2019_provincial"
    ALTER COLUMN "registered_population" TYPE INTEGER
    USING CASE
        WHEN "registered_population" ~ '^[0-9,]+$'
        THEN REPLACE("registered_population", ',', '')::INTEGER
        ELSE 0
    END;

ALTER TABLE bronze."2019_provincial"
    ALTER COLUMN "spoilt_votes" TYPE INTEGER
    USING CASE
        WHEN "spoilt_votes" ~ '^[0-9,]+$'
        THEN REPLACE("spoilt_votes", ',', '')::INTEGER
        ELSE 0
    END;

---ALTER TABLE bronze."2019_provincial"
    ---ALTER COLUMN "valid_votes"      TYPE INTEGER USING "valid_votes"::INTEGER;

ALTER TABLE bronze."2019_provincial"
    ALTER COLUMN "total_votes_cast" TYPE INTEGER
    USING CASE
        WHEN "total_votes_cast" ~ '^[0-9,]+$'
        THEN REPLACE("total_votes_cast", ',', '')::INTEGER
        ELSE 0
    END;

ALTER TABLE bronze."2019_provincial"
    ALTER COLUMN "party_votes" TYPE INTEGER
    USING CASE
        WHEN "party_votes" ~ '^[0-9,]+$'
        THEN REPLACE("party_votes", ',', '')::INTEGER
        ELSE 0
    END;


-- -----------------------------------------------------------------------------
-- 3.6  2024_national
-- -----------------------------------------------------------------------------


select * from bronze."2024_national";

ALTER TABLE bronze."2024_national"
    RENAME COLUMN "vd_number"          TO "voting_district";

---ALTER TABLE bronze."2024_national"
    ---RENAME COLUMN "total_valid_votes"  TO "valid_votes";


ALTER TABLE bronze."2024_national"
    ALTER COLUMN "voting_district" TYPE INTEGER USING "voting_district"::INTEGER;

ALTER TABLE bronze."2024_national"
    ALTER COLUMN "registered_population" TYPE INTEGER
    USING CASE
        WHEN "registered_population"::TEXT ~ '^[0-9,]+$'
        THEN REPLACE("registered_population"::TEXT, ',', '')::INTEGER
        ELSE 0
    END;

ALTER TABLE bronze."2024_national"
    ALTER COLUMN "spoilt_votes" TYPE INTEGER
    USING CASE
        WHEN "spoilt_votes"::TEXT ~ '^[0-9,]+$'
        THEN REPLACE("spoilt_votes"::TEXT, ',', '')::INTEGER
        ELSE 0
    END;

---ALTER TABLE bronze."2024_national"
    ---ALTER COLUMN "valid_votes"      TYPE INTEGER USING "valid_votes"::INTEGER;

ALTER TABLE bronze."2024_national"
    ALTER COLUMN "total_votes_cast" TYPE INTEGER
    USING CASE
        WHEN "total_votes_cast"::TEXT ~ '^[0-9,]+$'
        THEN REPLACE("total_votes_cast"::TEXT, ',', '')::INTEGER
        ELSE 0
    END;


-- -----------------------------------------------------------------------------
-- 3.7  2024_provincial
-- -----------------------------------------------------------------------------

select * from bronze."2024_provincial";

ALTER TABLE bronze."2024_provincial"
    RENAME COLUMN "vd_number"         TO "voting_district";

---ALTER TABLE bronze."2024_provincial"
    ---RENAME COLUMN "total_valid_votes" TO "valid_votes";



ALTER TABLE bronze."2024_provincial"
    ALTER COLUMN "voting_district" TYPE INTEGER USING "voting_district"::INTEGER;

ALTER TABLE bronze."2024_provincial"
    ALTER COLUMN "registered_population" TYPE INTEGER
    USING CASE
        WHEN "registered_population"::TEXT ~ '^[0-9,]+$'
        THEN REPLACE("registered_population"::TEXT, ',', '')::INTEGER
        ELSE 0
    END;

ALTER TABLE bronze."2024_provincial"
    ALTER COLUMN "spoilt_votes" TYPE INTEGER
    USING CASE
        WHEN "spoilt_votes"::TEXT ~ '^[0-9,]+$'
        THEN REPLACE("spoilt_votes"::TEXT, ',', '')::INTEGER
        ELSE 0
    END;

---ALTER TABLE bronze."2024_provincial"
    ---ALTER COLUMN "valid_votes"      TYPE INTEGER USING "valid_votes"::INTEGER;

ALTER TABLE bronze."2024_provincial"
    ALTER COLUMN "total_votes_cast" TYPE INTEGER
    USING CASE
        WHEN "total_votes_cast"::TEXT ~ '^[0-9,]+$'
        THEN REPLACE("total_votes_cast"::TEXT, ',', '')::INTEGER
        ELSE 0
    END;


-- =============================================================================
-- SECTION 4: MDB WARDS 2020 — COLUMN CLEANUP
-- =============================================================================

ALTER TABLE bronze."mdb_wards_2020"
    DROP COLUMN "ï»¿FID";

ALTER TABLE bronze."mdb_wards_2020"
    DROP COLUMN "CAT_B";

ALTER TABLE bronze."mdb_wards_2020"
    DROP COLUMN "WardNo";

ALTER TABLE bronze."mdb_wards_2020"
    DROP COLUMN "DistrictCo";

ALTER TABLE bronze."mdb_wards_2020"
    DROP COLUMN "WardLabel";

ALTER TABLE bronze."mdb_wards_2020"
    RENAME COLUMN "Province"     TO "province";

ALTER TABLE bronze."mdb_wards_2020"
    RENAME COLUMN "Municipali"   TO "municipality";

ALTER TABLE bronze."mdb_wards_2020"
    RENAME COLUMN "District"     TO "district";

ALTER TABLE bronze."mdb_wards_2020"
    RENAME COLUMN "Date"         TO "date";

ALTER TABLE bronze."mdb_wards_2020"
    RENAME COLUMN "WardID"       TO "ward";

ALTER TABLE bronze."mdb_wards_2020"
    RENAME COLUMN "Shape__Area"  TO "shape_area";

ALTER TABLE bronze."mdb_wards_2020"
    RENAME COLUMN "Shape__Length" TO "shape_length";


-- =============================================================================
-- SECTION 5: ADD year AND election_type COLUMNS
-- =============================================================================

-- 2004_npe
ALTER TABLE bronze."2004_npe"
    ADD COLUMN "year"          TEXT,
    ADD COLUMN "election_type" TEXT;

UPDATE bronze."2004_npe" SET "year" = '2004';

UPDATE bronze."2004_npe" SET "election_type" = 'NATIONAL'
WHERE "electoral_event" = '14 APR 2004 NATIONAL ELECTION';

UPDATE bronze."2004_npe" SET "election_type" = 'PROVINCIAL'
WHERE "electoral_event" = '14 APR 2004 PROVINCIAL ELECTION';


-- 2009_npe
ALTER TABLE bronze."2009_npe"
    ADD COLUMN "year"          TEXT,
    ADD COLUMN "election_type" TEXT;

UPDATE bronze."2009_npe" SET "year" = '2009';

UPDATE bronze."2009_npe" SET "election_type" = 'NATIONAL'
WHERE "electoral_event" = '22 APR 2009 NATIONAL ELECTION';

UPDATE bronze."2009_npe" SET "election_type" = 'PROVINCIAL'
WHERE "electoral_event" = '22 APR 2009 PROVINCIAL ELECTION';


-- 2014_npe
ALTER TABLE bronze."2014_npe"
    ADD COLUMN "year"          TEXT,
    ADD COLUMN "election_type" TEXT;

UPDATE bronze."2014_npe" SET "year" = '2014';

UPDATE bronze."2014_npe" SET "election_type" = 'NATIONAL'
WHERE "electoral_event" = '2014 NATIONAL ELECTION';

UPDATE bronze."2014_npe" SET "election_type" = 'PROVINCIAL'
WHERE "electoral_event" = '2014 PROVINCIAL ELECTION';


-- 2019_national
ALTER TABLE bronze."2019_national"
    ADD COLUMN "year"          TEXT,
    ADD COLUMN "election_type" TEXT;

UPDATE bronze."2019_national" SET "year" = '2019';
UPDATE bronze."2019_national" SET "election_type" = 'NATIONAL';


-- 2019_provincial
ALTER TABLE bronze."2019_provincial"
    ADD COLUMN "year"          TEXT,
    ADD COLUMN "election_type" TEXT;

UPDATE bronze."2019_provincial" SET "year" = '2019';
UPDATE bronze."2019_provincial" SET "election_type" = 'PROVINCIAL';


-- 2024_national
ALTER TABLE bronze."2024_national"
    ADD COLUMN "year"          TEXT,
    ADD COLUMN "election_type" TEXT;

UPDATE bronze."2024_national" SET "year" = '2024';
UPDATE bronze."2024_national" SET "election_type" = 'NATIONAL';


-- 2024_provincial
ALTER TABLE bronze."2024_provincial"
    ADD COLUMN "year"          TEXT,
    ADD COLUMN "election_type" TEXT;

UPDATE bronze."2024_provincial" SET "year" = '2024';
UPDATE bronze."2024_provincial" SET "election_type" = 'PROVINCIAL';


-- =============================================================================
-- SECTION 6: CREATE SILVER TABLES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 6.1  silver.election_results
--      Unified view across all election years and types
-- -----------------------------------------------------------------------------
select * from bronze."2009_npe";
select * from bronze."2004_npe";
select * from bronze."2014_npe";
select * from bronze."2019_national";
select * from bronze."2019_provincial";  

CREATE TABLE silver."election_results" AS

-- 2004
SELECT
    "province"::TEXT,
    "municipality"::TEXT,
    "voting_district"::INTEGER,
    "party_name"::TEXT,
    "registered_population"::INTEGER,
    "voter_turnout_percent"::DOUBLE PRECISION,
    "total_votes_cast"::INTEGER,
    "year"::INTEGER,
    "election_type"::TEXT
FROM bronze."2004_npe"

UNION ALL

-- 2009
SELECT
    "province"::TEXT,
    "municipality"::TEXT,
    "voting_district"::INTEGER,
    "party_name"::TEXT,
    "registered_population"::INTEGER,
    "voter_turnout_percent"::DOUBLE PRECISION,
    "total_votes_cast"::INTEGER,
    "year"::INTEGER,
    "election_type"::TEXT
FROM bronze."2009_npe"

UNION ALL

-- 2014
SELECT
    "province"::TEXT,
    "municipality"::TEXT,
    "voting_district"::INTEGER,
    "party_name"::TEXT,
    "registered_population"::INTEGER,
    "voter_turnout_percent"::DOUBLE PRECISION,
    "total_votes_cast"::INTEGER,
    "year"::INTEGER,
    "election_type"::TEXT
FROM bronze."2014_npe"

UNION ALL

-- 2019 National (voter_turnout_percent not available)
SELECT
    "province"::TEXT,
    "municipality"::TEXT,
    "voting_district"::INTEGER,
    "party_name"::TEXT,
    "registered_population"::INTEGER,
    NULL::DOUBLE PRECISION AS voter_turnout_percent,
    "total_votes_cast"::INTEGER,
    "year"::INTEGER,
    "election_type"::TEXT
FROM bronze."2019_national"

UNION ALL

-- 2019 Provincial (voter_turnout_percent not available)
SELECT
    "province"::TEXT,
    "municipality"::TEXT,
    "voting_district"::INTEGER,
    "party_name"::TEXT,
    "registered_population"::INTEGER,
    NULL::DOUBLE PRECISION AS voter_turnout_percent,
    "total_votes_cast"::INTEGER,
    "year"::INTEGER,
    "election_type"::TEXT
FROM bronze."2019_provincial"

UNION ALL

-- 2024 National (voter_turnout_percent not available)
SELECT
    "province"::TEXT,
    "municipality"::TEXT,
    "voting_district"::INTEGER,
    "party_name"::TEXT,
    "registered_population"::INTEGER,
    NULL::DOUBLE PRECISION AS voter_turnout_percent,
    "total_votes_cast"::INTEGER,
    "year"::INTEGER,
    "election_type"::TEXT
FROM bronze."2024_national"

UNION ALL

-- 2024 Provincial (voter_turnout_percent not available)
SELECT
    "province"::TEXT,
    "municipality"::TEXT,
    "voting_district"::INTEGER,
    "party_name"::TEXT,
    "registered_population"::INTEGER,
    NULL::DOUBLE PRECISION AS voter_turnout_percent,
    "total_votes_cast"::INTEGER,
    "year"::INTEGER,
    "election_type"::TEXT
FROM bronze."2024_provincial";


-- Add ward column and populate from voting_stations lookup
ALTER TABLE silver."election_results"
    ADD COLUMN IF NOT EXISTS ward INTEGER;

select * from silver.election_results;



select * from bronze."voting_stations";


--extract json api response into columns
SELECT
    vs.*,
    vs.api_response ->> 'Ward'       AS ward,
    vs.api_response ->> 'VDNumber'    AS voting_district,
    vs.api_response ->> 'Province'   AS province,
    vs.api_response -> 'VotingStation' -> 0 ->> 'Latitude'  AS latitude,
    vs.api_response -> 'VotingStation' -> 0 ->> 'Longitude'  AS longitude
FROM bronze.voting_stations vs;


UPDATE silver.election_results e
SET ward = CASE 
    WHEN (v.api_response ->> 'Ward') ~ '^\d+$' 
    THEN (v.api_response ->> 'Ward')::INTEGER
    ELSE NULL
END
FROM bronze.voting_stations v
WHERE e.voting_district = v.vd_number;


-- -----------------------------------------------------------------------------
-- 6.2  silver.population
--      Age groups, population groups, and sex joined on ward code
-- -----------------------------------------------------------------------------

CREATE TABLE silver."population" AS
SELECT
    a."Ward_Code",

    -- Age groups
    a."0-4",
    a."5-9",
    a."10-14",
    a."15-19",
    a."20-24",
    a."25-29",
    a."30-34",
    a."35-39",
    a."40-44",
    a."45-49",
    a."50-54",
    a."55-59",
    a."60-64",
    a."65-69",
    a."70-74",
    a."75-79",
    a."80-84",
    a."85+",
    a."Total"  AS total_age_population,

    -- Population groups
    g."Black African",
    g."Coloured",
    g."Indian/Asian",
    g."White",
    g."Other",
    g."Total"  AS total_group_population,

    -- Sex
    s."Male",
    s."Female",
    s."Total"  AS total_sex_population

FROM bronze.pp_age_group_27_10_2025 a
INNER JOIN bronze.pp_population_group_27_10_2025 g
    ON a."Ward_Code" = g."Ward_Code"
INNER JOIN bronze.pp_sex_27_10_2025 s
    ON a."Ward_Code" = s."WARD_CODE";


-- Rename and cast ward key
ALTER TABLE silver.population
    RENAME COLUMN "Ward_Code" TO "ward_number";

ALTER TABLE silver."population"
    ALTER COLUMN "ward_number" TYPE INTEGER
    USING CASE
        WHEN "ward_number" ~ '^\d+$' THEN "ward_number"::INTEGER
        ELSE NULL
    END;

-- Remove rows where ward could not be parsed
DELETE FROM silver.population
WHERE "ward_number" IS NULL;


select * from silver."election_results";


--make all provinces uppercase
SELECT UPPER(province) AS province
FROM silver.election_results;

select count(*) from silver."election_results" where voter_turnout_percent<=100;