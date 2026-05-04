-- =============================================================================
-- BRONZE LAYER (CLEAN + RE-RUN SAFE)
-- =============================================================================

-- =============================================================================
-- RESET SCHEMAS (IMPORTANT FOR CI/CD)
-- =============================================================================
DROP SCHEMA IF EXISTS bronze CASCADE;
DROP SCHEMA IF EXISTS silver CASCADE;
DROP SCHEMA IF EXISTS gold CASCADE;

CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;

-- =============================================================================
-- NOTE:
-- Your ingestion logic (COPY / imports) should already populate bronze tables
-- This file focuses on standardisation + cleaning
-- =============================================================================


-- =============================================================================
-- COLUMN NORMALISATION FUNCTION (REUSED PATTERN)
-- =============================================================================
DO $$
DECLARE
    r RECORD;
    new_name TEXT;
BEGIN
    FOR r IN
        SELECT table_name, column_name
        FROM information_schema.columns
        WHERE table_schema = 'bronze'
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
            EXECUTE format(
                'ALTER TABLE bronze.%I RENAME COLUMN %I TO %I',
                r.table_name,
                r.column_name,
                new_name
            );
        END IF;
    END LOOP;
END $$;

-- =============================================================================
-- FIX COMMON COLUMN ISSUES
-- =============================================================================

ALTER TABLE bronze."2004_npe"
    RENAME COLUMN "_voter_turnout" TO voter_turnout_percent;

ALTER TABLE bronze."2009_npe"
    RENAME COLUMN "_voter_turnout" TO voter_turnout_percent;

ALTER TABLE bronze."2019_national"
    RENAME COLUMN "spartname" TO party_name;

ALTER TABLE bronze."2019_provincial"
    RENAME COLUMN "spartyname" TO party_name;

ALTER TABLE bronze."2024_national"
    RENAME COLUMN "spartyname" TO party_name;

ALTER TABLE bronze."2024_provincial"
    RENAME COLUMN "spartyname" TO party_name;

-- =============================================================================
-- CLEAN NULL ROWS
-- =============================================================================

DELETE FROM bronze."2004_npe" WHERE municipality IS NULL;
DELETE FROM bronze."2009_npe" WHERE ward IS NULL;
DELETE FROM bronze."2019_national" WHERE registered_population IS NULL;
DELETE FROM bronze."2019_national" WHERE party_name IS NULL;

-- =============================================================================
-- TYPE CLEANUP (SAFE CASTING PATTERNS)
-- =============================================================================

ALTER TABLE bronze."2004_npe"
ALTER COLUMN voter_turnout_percent TYPE DOUBLE PRECISION
USING REPLACE(voter_turnout_percent, '%', '')::DOUBLE PRECISION;