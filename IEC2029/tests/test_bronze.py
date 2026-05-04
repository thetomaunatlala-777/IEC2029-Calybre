import os
import pytest
from helpers import read_csv, db_count, print_summary

# Maps each source file to its bronze table
CSV_MAP = {
    "/app/data/Election Results/2004_npe.csv":        "bronze.2004_npe",
    "/app/data/Election Results/2009_npe.csv":        "bronze.2009_npe",
    "/app/data/Election Results/2014_npe.csv":        "bronze.2014_npe",
    "/app/data/Election Results/2019_National.csv":   "bronze.2019_national",
    "/app/data/Election Results/2019_Provincial.csv": "bronze.2019_provincial",
    "/app/data/Election Results/2024_National.csv":   "bronze.2024_national",
    "/app/data/Election Results/2024_Provincial.csv": "bronze.2024_provincial",
    "/app/data/MDB Ward Shape 2020/MDB_Wards_2020.csv": "bronze.mdb_wards_2020",
}

EXPECTED_COLUMNS = {
    "bronze.2024_provincial": ["Province", "Municipality", "VD_Number", "VS_Name",
                                "Registered_Population", "Spoilt_Votes",
                                "Total_Valid_Votes", "sPartyName",
                                "Party_Votes", "Generated_Datetime"],
}

# TC-B01: CSV row count must match bronze table (allows up to 1% loss)
def test_bronze_row_counts(db_conn):
    errors, warnings, passed = [], [], []

    for csv_path, full_table in CSV_MAP.items():
        if not os.path.exists(csv_path):
            errors.append(f"FAIL  {full_table}: missing file {csv_path}")
            continue

        schema, table = full_table.split(".")
        csv_rows = len(read_csv(csv_path))
        pg_rows  = db_count(db_conn, schema, table)

        if csv_rows == pg_rows:
            passed.append(f"PASS  {full_table}: {pg_rows} rows — exact match")
        else:
            diff = abs(csv_rows - pg_rows)
            pct  = diff / csv_rows
            if pct > 0.01:
                errors.append(f"FAIL  {full_table}: CSV={csv_rows}, DB={pg_rows}, lost {diff} rows ({pct:.2%})")
            else:
                warnings.append(f"WARN  {full_table}: CSV={csv_rows}, DB={pg_rows}, lost {diff} rows ({pct:.2%}) — within 1%")

    print_summary("TC-B01 ROW COUNTS", passed, warnings, errors, len(CSV_MAP))
    assert not errors, "Row count failures:\n" + "\n".join(errors)

# TC-B03: Expected columns must exist in bronze tables
def test_bronze_expected_columns(db_conn):
    errors, warnings, passed = [], [], []

    for full_table, expected_cols in EXPECTED_COLUMNS.items():
        schema, table = full_table.split(".")
        with db_conn.cursor() as cur:
            cur.execute("""
                SELECT column_name FROM information_schema.columns
                WHERE table_schema = %s AND table_name = %s
            """, (schema, table))
            actual = {row[0].strip("\ufeff") for row in cur.fetchall()}

        missing = [c for c in expected_cols if c not in actual]
        if missing:
            errors.append(f"FAIL  {full_table}: missing columns {missing}")
        else:
            passed.append(f"PASS  {full_table}: all {len(expected_cols)} columns present")

    print_summary("TC-B03 EXPECTED COLUMNS", passed, warnings, errors, len(EXPECTED_COLUMNS))
    assert not errors, "Missing columns:\n" + "\n".join(errors)

# TC-B04: Bronze tables must not be empty
def test_bronze_tables_not_empty(db_conn):
    errors, warnings, passed = [], [], []

    for _, full_table in CSV_MAP.items():
        schema, table = full_table.split(".")
        count = db_count(db_conn, schema, table)
        if count == 0:
            errors.append(f"FAIL  {full_table}: table is empty")
        else:
            passed.append(f"PASS  {full_table}: {count} rows")

    print_summary("TC-B04 TABLES NOT EMPTY", passed, warnings, errors, len(CSV_MAP))
    assert not errors, "Empty tables:\n" + "\n".join(errors)

# TC-B05: loaded_at timestamp must exist and be populated (if column present)
def test_bronze_load_timestamp(db_conn):
    errors, warnings, passed = [], [], []

    for _, full_table in CSV_MAP.items():
        schema, table = full_table.split(".")
        with db_conn.cursor() as cur:
            cur.execute("""
                SELECT column_name FROM information_schema.columns
                WHERE table_schema = %s AND table_name = %s AND column_name = 'loaded_at'
            """, (schema, table))
            has_col = cur.fetchone()

        if not has_col:
            warnings.append(f"WARN  {full_table}: no loaded_at column — skipped")
            continue

        with db_conn.cursor() as cur:
            cur.execute(
                f'SELECT COUNT(*) FROM {schema}."{table}" WHERE loaded_at IS NULL'
            )
            nulls = cur.fetchone()[0]

        if nulls > 0:
            errors.append(f"FAIL  {full_table}: {nulls} rows with NULL loaded_at")
        else:
            passed.append(f"PASS  {full_table}: loaded_at fully populated")

    print_summary("TC-B05 LOAD TIMESTAMP", passed, warnings, errors, len(CSV_MAP))
    assert not errors, "NULL timestamps:\n" + "\n".join(errors)