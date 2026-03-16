CREATE TABLE IF NOT EXISTS gold."2004_npe" (
    electoral_event TEXT,
    province TEXT,
    municipality TEXT,
    vd_number INT PRIMARY KEY,
    party_name TEXT,
    registered_population INT,
    voter_turnout_percent FLOAT,
    valid_votes INT,
    spoilt_votes INT,
    total_votes_cast INT
);

CREATE TABLE IF NOT EXISTS gold."2009_npe" (
    electoral_event TEXT,
    province TEXT,
    municipality TEXT,
    ward_number INT,
    vd_number INT PRIMARY KEY,
    party_name TEXT,
    registered_population INT,
    voter_turnout_percent FLOAT,
    valid_votes INT,
    spoilt_votes INT,
    total_votes_cast INT,
    section24a_votes INT,
    special_votes INT
);

CREATE TABLE IF NOT EXISTS gold."2014_npe" (
    electoral_event TEXT,
    province TEXT,
    municipality TEXT,
    ward_number INT,
    vd_number INT PRIMARY KEY,
    party_name TEXT,
    registered_population INT,
    voter_turnout_percent FLOAT,
    valid_votes INT,
    spoilt_votes INT,
    total_votes_cast INT,
    section24a_votes INT,
    special_votes INT
);

CREATE TABLE IF NOT EXISTS gold."2019_npe" (
    province TEXT,
    municipality TEXT,
    ward_number INT,
    vd_number INT PRIMARY KEY,
    vs_name TEXT,
    party_name TEXT,
    registered_population INT,
    voter_turnout_percent FLOAT, --calculate using (valid votes +spoilt votes)/registered population
    valid_votes INT,
    spoilt_votes INT,
    total_votes_cast INT, --calculate from spoilt votes + valid votes
    party_votes INT
);

CREATE TABLE IF NOT EXISTS gold."2024_npe" (
    province TEXT,
    municipality TEXT,
    vd_number INT PRIMARY KEY,
    vs_name TEXT,
    party_name TEXT,
    registered_population INT,
    voter_turnout_percent FLOAT, --calculate using (valid votes +spoilt votes)/registered population
    valid_votes INT,
    spoilt_votes INT,
    total_votes_cast INT, --calculate from spoilt votes + valid votes
    party_votes INT
);

CREATE TABLE IF NOT EXISTS gold."mdb_wards" (
    province TEXT,
    municipality TEXT,
    ward_label TEXT,
    ward_number INT PRIMARY KEY,
    district_name TEXT,
    district_code TEXT,
    date TIMESTAMP,
    shape_area FLOAT,
    shape_length FLOAT
);

CREATE TABLE IF NOT EXISTS gold.population (
    ward_number      INT PRIMARY KEY,
    age_0_4          INT,
    age_5_9          INT,
    age_10_14        INT,
    age_15_19        INT,
    age_20_24        INT,
    age_25_29        INT,
    age_30_34        INT,
    age_35_39        INT,
    age_40_44        INT,
    age_45_49        INT,
    age_50_54        INT,
    age_55_59        INT,
    age_60_64        INT,
    age_65_69        INT,
    age_70_74        INT,
    age_75_79        INT,
    age_80_84        INT,
    age_85_plus      INT,
    total_population INT,
    black_african    INT,
    coloured         INT,
    indian_or_asian  INT,
    white            INT,
    other            INT,
    male             INT,
    female           INT
);

CREATE TABLE IF NOT EXISTS gold.voting_stations (
    vd_number INT PRIMARY KEY,
    municipality_number INT,
    municipality_code VARCHAR,
    municipality_name TEXT,
    province TEXT,
    ward_number INT,
    geometry JSONB,
    vs_name TEXT,
    vs_latitude FLOAT,
    vs_longitude FLOAT,
    vs_street_name TEXT,
    vs_suburb TEXT,
    vs_town TEXT,
    vs_type TEXT
);


ALTER TABLE gold."2004_npe" DROP CONSTRAINT "2004_npe_pkey";
ALTER TABLE gold."2004_npe" ADD PRIMARY KEY (vd_number, party_name, electoral_event);

ALTER TABLE gold."2009_npe" DROP CONSTRAINT "2009_npe_pkey";
ALTER TABLE gold."2009_npe" ADD PRIMARY KEY (vd_number, party_name, electoral_event);

ALTER TABLE gold."2014_npe" DROP CONSTRAINT "2014_npe_pkey";
ALTER TABLE gold."2014_npe" ADD PRIMARY KEY (vd_number, party_name, electoral_event);

ALTER TABLE gold."mdb_wards" DROP CONSTRAINT "mdb_wards_pkey";
ALTER TABLE gold."mdb_wards" ADD PRIMARY KEY (ward_number, municipality);