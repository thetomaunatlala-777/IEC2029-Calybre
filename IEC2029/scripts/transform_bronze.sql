-- ============================================================
-- BRONZE LAYER TRANSFORMS
-- ============================================================

-- ── Rename columns (2004_npe) ────────────────────────────────
DO $$
DECLARE 
    r RECORD;
    new_name TEXT;
BEGIN
    FOR r IN 
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '2004_npe'
    LOOP
        new_name := LOWER(
            REPLACE(REPLACE(REPLACE(REPLACE(r.column_name, E'\r', ''), E'\n', ' '), ' ', '_'), '%', '')
        );
        IF r.column_name <> new_name THEN
            EXECUTE 'ALTER TABLE bronze."2004_npe" RENAME COLUMN "' || r.column_name || '" TO ' || new_name;
        END IF;
    END LOOP;
END $$;

ALTER TABLE bronze."2004_npe" RENAME COLUMN "_voter_turnout" TO "voter_turnout";


-- ── Rename columns (2009_npe) ────────────────────────────────
DO $$
DECLARE 
    r RECORD;
    new_name TEXT;
BEGIN
    FOR r IN 
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '2009_npe'
    LOOP
        new_name := LOWER(
            REPLACE(REPLACE(REPLACE(REPLACE(r.column_name, E'\r', ''), E'\n', ' '), ' ', '_'), '%', '')
        );
        IF r.column_name <> new_name THEN
            EXECUTE 'ALTER TABLE bronze."2009_npe" RENAME COLUMN "' || r.column_name || '" TO ' || new_name;
        END IF;
    END LOOP;
END $$;

ALTER TABLE bronze."2009_npe" RENAME COLUMN "_voter_turnout" TO "voter_turnout";


-- ── Rename columns (2014_npe) ────────────────────────────────
DO $$
DECLARE 
    r RECORD;
    new_name TEXT;
BEGIN
    FOR r IN 
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '2014_npe'
    LOOP
        new_name := LOWER(
            REPLACE(REPLACE(REPLACE(REPLACE(r.column_name, E'\r', ''), E'\n', ' '), ' ', '_'), '%', '')
        );
        IF r.column_name <> new_name THEN
            EXECUTE 'ALTER TABLE bronze."2014_npe" RENAME COLUMN "' || r.column_name || '" TO ' || new_name;
        END IF;
    END LOOP;
END $$;

ALTER TABLE bronze."2014_npe" RENAME COLUMN "_voter_turnout" TO "voter_turnout";


-- ── Rename columns (2019_national) ───────────────────────────
DO $$
DECLARE 
    r RECORD;
    new_name TEXT;
BEGIN
    FOR r IN 
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '2019_national'
    LOOP
        new_name := LOWER(
            REPLACE(REPLACE(REPLACE(REPLACE(r.column_name, E'\r', ''), E'\n', ' '), ' ', '_'), '%', '')
        );
        IF r.column_name <> new_name THEN
            EXECUTE 'ALTER TABLE bronze."2019_national" RENAME COLUMN "' || r.column_name || '" TO ' || quote_ident(new_name);
        END IF;
    END LOOP;
END $$;


-- ── Rename columns (2019_provincial) ─────────────────────────
DO $$
DECLARE 
    r RECORD;
    new_name TEXT;
BEGIN
    FOR r IN 
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '2019_provincial'
    LOOP
        new_name := LOWER(
            REPLACE(REPLACE(REPLACE(REPLACE(r.column_name, E'\r', ''), E'\n', ' '), ' ', '_'), '%', '')
        );
        IF r.column_name <> new_name THEN
            EXECUTE 'ALTER TABLE bronze."2019_provincial" RENAME COLUMN "' || r.column_name || '" TO ' || quote_ident(new_name);
        END IF;
    END LOOP;
END $$;

ALTER TABLE bronze."2019_provincial" RENAME COLUMN "spartyname" TO "party_name";
ALTER TABLE bronze."2019_provincial" DROP COLUMN "generated_datetime:_30_jun_2020_13:19:48";
ALTER TABLE bronze."2019_provincial" DROP COLUMN "unnamed:_10";


-- ── Rename columns (2024_national) ───────────────────────────
DO $$
DECLARE 
    r RECORD;
    new_name TEXT;
BEGIN
    FOR r IN 
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '2024_national'
    LOOP
        new_name := LOWER(
            REPLACE(REPLACE(REPLACE(REPLACE(r.column_name, E'\r', ''), E'\n', ' '), ' ', '_'), '%', '')
        );
        IF r.column_name <> new_name THEN
            EXECUTE 'ALTER TABLE bronze."2024_national" RENAME COLUMN "' || r.column_name || '" TO ' || quote_ident(new_name);
        END IF;
    END LOOP;
END $$;

ALTER TABLE bronze."2024_national" RENAME COLUMN "spartyname" TO "party_name";
ALTER TABLE bronze."2024_national" DROP COLUMN "generated_datetime";


-- ── Rename columns (2024_provincial) ─────────────────────────
DO $$
DECLARE 
    r RECORD;
    new_name TEXT;
BEGIN
    FOR r IN 
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '2024_provincial'
    LOOP
        new_name := LOWER(
            REPLACE(REPLACE(REPLACE(REPLACE(r.column_name, E'\r', ''), E'\n', ' '), ' ', '_'), '%', '')
        );
        IF r.column_name <> new_name THEN
            EXECUTE 'ALTER TABLE bronze."2024_provincial" RENAME COLUMN "' || r.column_name || '" TO ' || quote_ident(new_name);
        END IF;
    END LOOP;
END $$;

ALTER TABLE bronze."2024_provincial" RENAME COLUMN "spartyname" TO "party_name";
ALTER TABLE bronze."2024_provincial" RENAME COLUMN "\u00ef\u00bb\u00bfprovince" TO "province";
ALTER TABLE bronze."2024_provincial" DROP COLUMN "generated_datetime";


-- ── Null value cleanup ────────────────────────────────────────
DELETE FROM bronze."2004_npe" WHERE "municipality" IS NULL;
DELETE FROM bronze."2009_npe" WHERE "ward" IS NULL;
DELETE FROM bronze."2019_national" WHERE "registered_population" IS NULL;
DELETE FROM bronze."2019_national" WHERE "spartname" IS NULL;

ALTER TABLE bronze."2019_national" RENAME COLUMN "spartname" TO "party_name";
ALTER TABLE bronze."2019_national" DROP COLUMN "generated_datetime:_30_jun_2020_13:27:18";


-- ── Data type fixes (2004_npe) ────────────────────────────────
ALTER TABLE bronze."2004_npe" ALTER COLUMN "voter_turnout" TYPE DOUBLE PRECISION USING REPLACE("voter_turnout", '%', '')::DOUBLE PRECISION;
ALTER TABLE bronze."2004_npe" RENAME COLUMN "voter_turnout" TO "voter_turnout_percent";
ALTER TABLE bronze."2004_npe" RENAME COLUMN "registered_voters" TO "registered_population";
ALTER TABLE bronze."2004_npe" ALTER COLUMN "voting_district" TYPE INTEGER USING "voting_district"::INTEGER;
ALTER TABLE bronze."2004_npe" ALTER COLUMN "registered_population" TYPE INTEGER USING "registered_population"::INTEGER;
ALTER TABLE bronze."2004_npe" ALTER COLUMN "valid_votes" TYPE INTEGER USING "valid_votes"::INTEGER;
ALTER TABLE bronze."2004_npe" ALTER COLUMN "spoilt_votes" TYPE INTEGER USING "spoilt_votes"::INTEGER;
ALTER TABLE bronze."2004_npe" ALTER COLUMN "total_votes_cast" TYPE INTEGER USING "total_votes_cast"::INTEGER;


-- ── Data type fixes (2009_npe) ────────────────────────────────
ALTER TABLE bronze."2009_npe" RENAME COLUMN "registered_voters" TO "registered_population";
ALTER TABLE bronze."2009_npe" ALTER COLUMN "voter_turnout" TYPE DOUBLE PRECISION USING REPLACE("voter_turnout", '%', '')::DOUBLE PRECISION;
ALTER TABLE bronze."2009_npe" ALTER COLUMN "valid_votes" TYPE INTEGER USING REPLACE("valid_votes", ',', '')::INTEGER;
ALTER TABLE bronze."2009_npe" ALTER COLUMN "total_votes_cast" TYPE INTEGER USING REPLACE("total_votes_cast", ',', '')::INTEGER;
ALTER TABLE bronze."2009_npe" ALTER COLUMN "section_24a_votes" TYPE INTEGER USING REPLACE("section_24a_votes", ',', '')::INTEGER;
ALTER TABLE bronze."2009_npe" ALTER COLUMN "special_votes" TYPE INTEGER USING REPLACE("special_votes", ',', '')::INTEGER;
ALTER TABLE bronze."2009_npe" ALTER COLUMN "voting_district" TYPE INTEGER USING "voting_district"::INTEGER;
ALTER TABLE bronze."2009_npe" ALTER COLUMN "ward" TYPE INTEGER USING "ward"::INTEGER;
ALTER TABLE bronze."2009_npe" ALTER COLUMN "spoilt_votes" TYPE INTEGER USING "spoilt_votes"::INTEGER;


-- ── Data type fixes (2014_npe) ────────────────────────────────
ALTER TABLE bronze."2014_npe" ALTER COLUMN "ward" TYPE INTEGER USING "ward"::INTEGER;
ALTER TABLE bronze."2014_npe" ALTER COLUMN "voting_district" TYPE INTEGER USING "voting_district"::INTEGER;
ALTER TABLE bronze."2014_npe" ALTER COLUMN "registered_voters" TYPE INTEGER USING "registered_voters"::INTEGER;
ALTER TABLE bronze."2014_npe" RENAME COLUMN "registered_voters" TO "registered_population";
ALTER TABLE bronze."2014_npe" ALTER COLUMN "valid_votes" TYPE INTEGER USING "valid_votes"::INTEGER;
ALTER TABLE bronze."2014_npe" ALTER COLUMN "spoilt_votes" TYPE INTEGER USING "spoilt_votes"::INTEGER;
ALTER TABLE bronze."2014_npe" ALTER COLUMN "total_votes_cast" TYPE INTEGER USING "total_votes_cast"::INTEGER;
ALTER TABLE bronze."2014_npe" ALTER COLUMN "section_24a_votes" TYPE INTEGER USING "section_24a_votes"::INTEGER;
UPDATE bronze."2014_npe" SET "voter_turnout" = ROUND(("voter_turnout" * 100)::NUMERIC, 2);
ALTER TABLE bronze."2014_npe" RENAME COLUMN "voter_turnout" TO "voter_turnout_percent";
ALTER TABLE bronze."2014_npe" ALTER COLUMN "special_votes" TYPE INTEGER USING "special_votes"::INTEGER;


-- ── Data type fixes (2019_national) ──────────────────────────
ALTER TABLE bronze."2019_national" RENAME COLUMN "vd_number" TO "voting_district";
ALTER TABLE bronze."2019_national" ALTER COLUMN "voting_district" TYPE INTEGER USING "voting_district"::INTEGER;
ALTER TABLE bronze."2019_national" ALTER COLUMN "registered_population" TYPE INTEGER USING "registered_population"::INTEGER;
ALTER TABLE bronze."2019_national" ALTER COLUMN "spoilt_votes" TYPE INTEGER USING "spoilt_votes"::INTEGER;
ALTER TABLE bronze."2019_national" ALTER COLUMN "total_valid_votes" TYPE INTEGER USING "total_valid_votes"::INTEGER;
ALTER TABLE bronze."2019_national" RENAME COLUMN "total_valid_votes" TO "valid_votes";
ALTER TABLE bronze."2019_national" RENAME COLUMN "party_votes" TO "total_votes_cast";
ALTER TABLE bronze."2019_national" ALTER COLUMN "total_votes_cast" TYPE INTEGER USING "total_votes_cast"::INTEGER;


-- ── Data type fixes (2019_provincial) ────────────────────────
ALTER TABLE bronze."2019_provincial" RENAME COLUMN "vd_number" TO "voting_district";
ALTER TABLE bronze."2019_provincial" ALTER COLUMN "voting_district" TYPE INTEGER USING "voting_district"::INTEGER;
ALTER TABLE bronze."2019_provincial" ALTER COLUMN "registered_population" TYPE INTEGER
    USING CASE WHEN "registered_population" ~ '^[0-9,]+$' THEN REPLACE("registered_population", ',', '')::INTEGER ELSE 0 END;
ALTER TABLE bronze."2019_provincial" ALTER COLUMN "spoilt_votes" TYPE INTEGER
    USING CASE WHEN "spoilt_votes" ~ '^[0-9,]+$' THEN REPLACE("spoilt_votes", ',', '')::INTEGER ELSE 0 END;
ALTER TABLE bronze."2019_provincial" ALTER COLUMN "total_valid_votes" TYPE INTEGER USING "total_valid_votes"::INTEGER;
ALTER TABLE bronze."2019_provincial" RENAME COLUMN "total_valid_votes" TO "valid_votes";
ALTER TABLE bronze."2019_provincial" RENAME COLUMN "party_votes" TO "total_votes_cast";
ALTER TABLE bronze."2019_provincial" ALTER COLUMN "total_votes_cast" TYPE INTEGER
    USING CASE WHEN "total_votes_cast" ~ '^[0-9,]+$' THEN REPLACE("total_votes_cast", ',', '')::INTEGER ELSE 0 END;


-- ── Data type fixes (2024_national) ──────────────────────────
ALTER TABLE bronze."2024_national" RENAME COLUMN "ï»¿province" TO "province";
ALTER TABLE bronze."2024_national" RENAME COLUMN "vd_number" TO "voting_district";
ALTER TABLE bronze."2024_national" ALTER COLUMN "voting_district" TYPE INTEGER USING "voting_district"::INTEGER;
ALTER TABLE bronze."2024_national" ALTER COLUMN "registered_population" TYPE INTEGER
    USING CASE WHEN "registered_population"::TEXT ~ '^[0-9,]+$' THEN REPLACE("registered_population"::TEXT, ',', '')::INTEGER ELSE 0 END;
ALTER TABLE bronze."2024_national" ALTER COLUMN "spoilt_votes" TYPE INTEGER
    USING CASE WHEN "spoilt_votes"::TEXT ~ '^[0-9,]+$' THEN REPLACE("spoilt_votes"::TEXT, ',', '')::INTEGER ELSE 0 END;
ALTER TABLE bronze."2024_national" ALTER COLUMN "total_valid_votes" TYPE INTEGER USING "total_valid_votes"::INTEGER;
ALTER TABLE bronze."2024_national" RENAME COLUMN "total_valid_votes" TO "valid_votes";
ALTER TABLE bronze."2024_national" RENAME COLUMN "party_votes" TO "total_votes_cast";
ALTER TABLE bronze."2024_national" ALTER COLUMN "total_votes_cast" TYPE INTEGER
    USING CASE WHEN "total_votes_cast"::TEXT ~ '^[0-9,]+$' THEN REPLACE("total_votes_cast"::TEXT, ',', '')::INTEGER ELSE 0 END;


-- ── Data type fixes (2024_provincial) ────────────────────────
ALTER TABLE bronze."2024_provincial" RENAME COLUMN "vd_number" TO "voting_district";
ALTER TABLE bronze."2024_provincial" ALTER COLUMN "voting_district" TYPE INTEGER USING "voting_district"::INTEGER;
ALTER TABLE bronze."2024_provincial" ALTER COLUMN "registered_population" TYPE INTEGER
    USING CASE WHEN "registered_population"::TEXT ~ '^[0-9,]+$' THEN REPLACE("registered_population"::TEXT, ',', '')::INTEGER ELSE 0 END;
ALTER TABLE bronze."2024_provincial" ALTER COLUMN "spoilt_votes" TYPE INTEGER
    USING CASE WHEN "spoilt_votes"::TEXT ~ '^[0-9,]+$' THEN REPLACE("spoilt_votes"::TEXT, ',', '')::INTEGER ELSE 0 END;
ALTER TABLE bronze."2024_provincial" ALTER COLUMN "total_valid_votes" TYPE INTEGER USING "total_valid_votes"::INTEGER;
ALTER TABLE bronze."2024_provincial" RENAME COLUMN "total_valid_votes" TO "valid_votes";
ALTER TABLE bronze."2024_provincial" RENAME COLUMN "party_votes" TO "total_votes_cast";
ALTER TABLE bronze."2024_provincial" ALTER COLUMN "total_votes_cast" TYPE INTEGER
    USING CASE WHEN "total_votes_cast"::TEXT ~ '^[0-9,]+$' THEN REPLACE("total_votes_cast"::TEXT, ',', '')::INTEGER ELSE 0 END;


-- ── MDB Wards cleanup ─────────────────────────────────────────
ALTER TABLE bronze."mdb_wards_2020" DROP COLUMN "ï»¿FID";
ALTER TABLE bronze."mdb_wards_2020" RENAME COLUMN "Province" TO "province";
ALTER TABLE bronze."mdb_wards_2020" RENAME COLUMN "Municipali" TO "municipality";
ALTER TABLE bronze."mdb_wards_2020" DROP COLUMN "CAT_B";
ALTER TABLE bronze."mdb_wards_2020" DROP COLUMN "WardNo";
ALTER TABLE bronze."mdb_wards_2020" RENAME COLUMN "District" TO "district";
ALTER TABLE bronze."mdb_wards_2020" DROP COLUMN "DistrictCo";
ALTER TABLE bronze."mdb_wards_2020" RENAME COLUMN "Date" TO "date";
ALTER TABLE bronze."mdb_wards_2020" RENAME COLUMN "WardID" TO "ward";
ALTER TABLE bronze."mdb_wards_2020" DROP COLUMN "WardLabel";
ALTER TABLE bronze."mdb_wards_2020" RENAME COLUMN "Shape__Area" TO "shape_area";
ALTER TABLE bronze."mdb_wards_2020" RENAME COLUMN "Shape__Length" TO "shape_length";


-- ── Add year and election_type columns ────────────────────────
ALTER TABLE bronze."2004_npe" ADD COLUMN "year" TEXT;
ALTER TABLE bronze."2004_npe" ADD COLUMN "election_type" TEXT;
UPDATE bronze."2004_npe" SET "election_type" = 'NATIONAL'   WHERE "electoral_event" = '14 APR 2004 NATIONAL ELECTION';
UPDATE bronze."2004_npe" SET "election_type" = 'PROVINCIAL' WHERE "electoral_event" = '14 APR 2004 PROVINCIAL ELECTION';
UPDATE bronze."2004_npe" SET "year" = '2004';

ALTER TABLE bronze."2009_npe" ADD COLUMN "year" TEXT;
ALTER TABLE bronze."2009_npe" ADD COLUMN "election_type" TEXT;
UPDATE bronze."2009_npe" SET "election_type" = 'NATIONAL'   WHERE "electoral_event" = '22 APR 2009 NATIONAL ELECTION';
UPDATE bronze."2009_npe" SET "election_type" = 'PROVINCIAL' WHERE "electoral_event" = '22 APR 2009 PROVINCIAL ELECTION';
UPDATE bronze."2009_npe" SET "year" = '2009';

ALTER TABLE bronze."2014_npe" ADD COLUMN "year" TEXT;
ALTER TABLE bronze."2014_npe" ADD COLUMN "election_type" TEXT;
UPDATE bronze."2014_npe" SET "election_type" = 'NATIONAL'   WHERE "electoral_event" = '2014 NATIONAL ELECTION';
UPDATE bronze."2014_npe" SET "election_type" = 'PROVINCIAL' WHERE "electoral_event" = '2014 PROVINCIAL ELECTION';
UPDATE bronze."2014_npe" SET "year" = '2014';

ALTER TABLE bronze."2019_national" ADD COLUMN "year" TEXT;
ALTER TABLE bronze."2019_national" ADD COLUMN "election_type" TEXT;
UPDATE bronze."2019_national" SET "election_type" = 'NATIONAL';
UPDATE bronze."2019_national" SET "year" = '2019';

ALTER TABLE bronze."2019_provincial" ADD COLUMN "year" TEXT;
ALTER TABLE bronze."2019_provincial" ADD COLUMN "election_type" TEXT;
UPDATE bronze."2019_provincial" SET "election_type" = 'PROVINCIAL';
UPDATE bronze."2019_provincial" SET "year" = '2019';

ALTER TABLE bronze."2024_national" ADD COLUMN "year" TEXT;
ALTER TABLE bronze."2024_national" ADD COLUMN "election_type" TEXT;
UPDATE bronze."2024_national" SET "election_type" = 'NATIONAL';
UPDATE bronze."2024_national" SET "year" = '2024';

ALTER TABLE bronze."2024_provincial" ADD COLUMN "year" TEXT;
ALTER TABLE bronze."2024_provincial" ADD COLUMN "election_type" TEXT;
UPDATE bronze."2024_provincial" SET "election_type" = 'PROVINCIAL';
UPDATE bronze."2024_provincial" SET "year" = '2024';