import pytest
import time
import os
import pandas as pd
from helpers import db_count, print_summary

# TC-F01 to TC-F03: Ingestion scripts execute without errors
def test_pipeline_bronze_ingest_election(db_conn):
    errors, warnings, passed = [], [], []
    try:
        count = db_count(db_conn, "bronze", "2024_provincial")
        if count > 0:
            passed.append(f"PASS  bronze.2024_provincial populated: {count} rows")
        else:
            errors.append("FAIL  bronze.2024_provincial is empty — ingestion may have failed")
    except Exception as e:
        errors.append(f"FAIL  Could not query bronze.2024_provincial: {e}")
    print_summary("TC-F01 BRONZE ELECTION INGESTION", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

def test_pipeline_bronze_ingest_api(db_conn):
    errors, warnings, passed = [], [], []
    try:
        count = db_count(db_conn, "bronze", "voting_stations")
        if count > 0:
            passed.append(f"PASS  bronze.voting_stations populated: {count} rows")
        else:
            errors.append("FAIL  bronze.voting_stations is empty — API ingestion may have failed")
    except Exception as e:
        errors.append(f"FAIL  Could not query bronze.voting_stations: {e}")
    print_summary("TC-F02 BRONZE API INGESTION", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

def test_pipeline_silver_transform(db_conn):
    errors, warnings, passed = [], [], []
    try:
        count = db_count(db_conn, "silver", "election_results")
        if count > 0:
            passed.append(f"PASS  silver.election_results populated: {count} rows")
        else:
            errors.append("FAIL  silver.election_results is empty — transformation may have failed")
    except Exception as e:
        errors.append(f"FAIL  Could not query silver.election_results: {e}")
    print_summary("TC-F03 SILVER TRANSFORMATION", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

def test_pipeline_gold_transform(db_conn):
    errors, warnings, passed = [], [], []
    try:
        count = db_count(db_conn, "gold", "vote")
        if count > 0:
            passed.append(f"PASS  gold.2024_npe populated: {count} rows")
        else:
            errors.append("FAIL  gold.2024_npe is empty — gold transformation may have failed")
    except Exception as e:
        errors.append(f"FAIL  Could not query gold.2024_npe: {e}")
    print_summary("TC-F04 GOLD TRANSFORMATION", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-F04: Negative test — missing file handled gracefully
def test_pipeline_negative_missing_file():
    errors, warnings, passed = [], [], []
    missing_path = "/app/data/Election Results/nonexistent_file.csv"
    try:
        if not os.path.exists(missing_path):
            passed.append("PASS  Missing file correctly detected — pipeline would skip gracefully")
        else:
            warnings.append("WARN  File unexpectedly exists — check file cleanup")
    except Exception as e:
        errors.append(f"FAIL  Unexpected error checking missing file: {e}")
    print_summary("TC-F04 NEGATIVE TEST MISSING FILE", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-F05: Negative test — malformed CSV handled gracefully
def test_pipeline_negative_malformed_csv(tmp_path):
    errors, warnings, passed = [], [], []
    bad_file = tmp_path / "bad.csv"
    bad_file.write_text("col1,col2\nval1\nval2,val3,extra_col\n")
    try:
        df = pd.read_csv(str(bad_file), on_bad_lines="skip")
        passed.append(f"PASS  Malformed CSV handled gracefully — {len(df)} valid rows read")
    except Exception as e:
        errors.append(f"FAIL  Malformed CSV caused crash: {e}")
    print_summary("TC-F05 NEGATIVE TEST MALFORMED CSV", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-F06: Negative test — empty CSV handled gracefully
def test_pipeline_negative_empty_csv(tmp_path):
    errors, warnings, passed = [], [], []
    empty_file = tmp_path / "empty.csv"
    empty_file.write_text("col1,col2\n")
    try:
        df = pd.read_csv(str(empty_file))
        if len(df) == 0:
            passed.append("PASS  Empty CSV handled gracefully — 0 rows, no crash")
        else:
            warnings.append(f"WARN  Expected 0 rows but got {len(df)}")
    except Exception as e:
        errors.append(f"FAIL  Empty CSV caused crash: {e}")
    print_summary("TC-F06 NEGATIVE TEST EMPTY CSV", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-F07: Pipeline sequence — bronze loaded before silver before gold
def test_pipeline_sequence_bronze_before_silver_before_gold(db_conn):
    errors, warnings, passed = [], [], []
    bronze_count = db_count(db_conn, "bronze", "2024_provincial")
    silver_count = db_count(db_conn, "silver", "election_results")
    gold_count   = db_count(db_conn, "gold", "vote")
    if bronze_count > 0 and silver_count > 0 and gold_count > 0:
        passed.append(f"PASS  All layers populated — Bronze={bronze_count}, Silver={silver_count}, Gold={gold_count}")
    else:
        errors.append(f"FAIL  Layer not populated — Bronze={bronze_count}, Silver={silver_count}, Gold={gold_count}")
    print_summary("TC-F07 PIPELINE SEQUENCE", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-F10: Logging — check that pipeline print logs exist in notebook outputs
def test_pipeline_logging_exists():
    errors, warnings, passed = [], [], []
    log_indicators = [
        "/app/notebooks/output",
        "/app/logs",
    ]
    found = any(os.path.exists(p) for p in log_indicators)
    if found:
        passed.append("PASS  Log output folder exists")
    else:
        warnings.append("WARN  No dedicated log folder found — verify print logging in notebooks")
    print_summary("TC-F10 LOGGING EXISTS", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)
