import pytest
from psycopg2 import sql
from helpers import db_count, print_summary

VALID_PROVINCES = {
    "Eastern Cape", "Free State", "Gauteng", "KwaZulu-Natal",
    "Limpopo", "Mpumalanga", "North West", "Northern Cape", "Western Cape"
}

# TC-S01: No duplicate rows — must include election_type in key
def test_silver_no_duplicates(db_conn):
    errors, warnings, passed = [], [], []
    with db_conn.cursor() as cur:
        cur.execute("""
            SELECT COUNT(*) FROM (
                SELECT province, voting_district, party_name, year, election_type, COUNT(*)
                FROM silver.election_results
                GROUP BY province, voting_district, party_name, year, election_type
                HAVING COUNT(*) > 1
            ) dupes
        """)
        dupes = cur.fetchone()[0]
    if dupes == 0:
        passed.append("PASS  silver.election_results: zero duplicate rows")
    else:
        errors.append(f"FAIL  silver.election_results: {dupes} duplicate combinations found")
    print_summary("TC-S01 NO DUPLICATES", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-S02: No NULLs in critical fields — party_name treated as warning
def test_silver_no_nulls_critical_fields(db_conn):
    errors, warnings, passed = [], [], []
    checks = {
        "silver.election_results": ["province", "voting_district", "year", "party_votes"],
        "silver.population":       ["ward_number", "total_age_population"],
    }
    for full_table, fields in checks.items():
        schema, table = full_table.split(".")
        for field in fields:
            with db_conn.cursor() as cur:
                cur.execute(
                    sql.SQL("SELECT COUNT(*) FROM {}.{} WHERE {} IS NULL").format(
                        sql.Identifier(schema),
                        sql.Identifier(table),
                        sql.Identifier(field)
                    )
                )
                nulls = cur.fetchone()[0]
            if nulls == 0:
                passed.append(f"PASS  {full_table}.{field}: no NULLs")
            else:
                errors.append(f"FAIL  {full_table}.{field}: {nulls} NULL values")

    # party_name — warn not fail (source data issue)
    with db_conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM silver.election_results WHERE party_name IS NULL")
        nulls = cur.fetchone()[0]
    if nulls == 0:
        passed.append("PASS  silver.election_results.party_name: no NULLs")
    elif nulls <= 200:
        warnings.append(f"WARN  silver.election_results.party_name: {nulls} NULLs — source data issue, within 200 row threshold")
    else:
        errors.append(f"FAIL  silver.election_results.party_name: {nulls} NULL values — exceeds threshold")

    print_summary("TC-S02 NO NULLS IN CRITICAL FIELDS", passed, warnings, errors,
                  sum(len(f) for f in checks.values()) + 1)
    assert not errors, "\n".join(errors)

# TC-S03: Province values valid — normalise case, allow uppercase and overseas
def test_silver_valid_provinces(db_conn):
    errors, warnings, passed = [], [], []
    with db_conn.cursor() as cur:
        cur.execute("SELECT DISTINCT province FROM silver.election_results WHERE province IS NOT NULL")
        actual = {row[0] for row in cur.fetchall()}

    # Normalise to title case and exclude overseas votes
    overseas = {"Out of Country", "Out of Country Voting", "OUT OF COUNTRY"}
    actual_normalised = {v.title() for v in actual if v not in overseas}
    invalid = actual_normalised - VALID_PROVINCES

    overseas_found = actual & overseas
    if overseas_found:
        warnings.append(f"WARN  silver.election_results: overseas vote records found: {overseas_found} — expected, not an error")

    if invalid:
        errors.append(f"FAIL  silver.election_results: invalid province values after normalisation: {invalid}")
    else:
        passed.append(f"PASS  silver.election_results: all province values valid (after case normalisation)")

    print_summary("TC-S03 VALID PROVINCE VALUES", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-S04: All 9 provinces must be present
def test_silver_all_9_provinces(db_conn):
    errors, warnings, passed = [], [], []
    with db_conn.cursor() as cur:
        cur.execute("SELECT DISTINCT province FROM silver.election_results WHERE province IS NOT NULL")
        actual = {row[0].title() for row in cur.fetchall()}
    missing = VALID_PROVINCES - actual
    if missing:
        errors.append(f"FAIL  silver.election_results: missing provinces: {missing}")
    else:
        passed.append("PASS  silver.election_results: all 9 provinces present")
    print_summary("TC-S04 ALL 9 PROVINCES PRESENT", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-S05: Silver row count reconciles back to bronze (max 1% loss)
def test_silver_source_to_target_reconciliation(db_conn):
    errors, warnings, passed = [], [], []
    bronze_total = sum([
        db_count(db_conn, "bronze", "2004_npe"),
        db_count(db_conn, "bronze", "2009_npe"),
        db_count(db_conn, "bronze", "2014_npe"),
        db_count(db_conn, "bronze", "2019_national"),
        db_count(db_conn, "bronze", "2019_provincial"),
        db_count(db_conn, "bronze", "2024_national"),
        db_count(db_conn, "bronze", "2024_provincial"),
    ])
    silver_rows = db_count(db_conn, "silver", "election_results")
    diff = abs(bronze_total - silver_rows)
    pct  = diff / bronze_total if bronze_total > 0 else 0
    if pct <= 0.01:
        passed.append(f"PASS  silver.election_results: {silver_rows} rows, bronze={bronze_total}, diff={diff} ({pct:.2%})")
    else:
        errors.append(f"FAIL  silver.election_results: {silver_rows} rows vs bronze {bronze_total}, lost {diff} ({pct:.2%})")
    print_summary("TC-S05 SOURCE TO TARGET RECONCILIATION", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-S06: No negative vote counts
def test_silver_no_negative_votes(db_conn):
    errors, warnings, passed = [], [], []
    with db_conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM silver.election_results WHERE party_votes < 0")
        neg = cur.fetchone()[0]
    if neg == 0:
        passed.append("PASS  silver.election_results: no negative party_votes")
    else:
        errors.append(f"FAIL  silver.election_results: {neg} rows with negative party_votes")
    print_summary("TC-S06 NO NEGATIVE VOTES", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-S07: Turnout percentage between 0 and 100
def test_silver_turnout_pct_range(db_conn):
    errors, warnings, passed = [], [], []
    with db_conn.cursor() as cur:
        cur.execute("""
            SELECT COUNT(*) FROM silver.election_results
            WHERE voter_turnout_percent IS NOT NULL
            AND (voter_turnout_percent < 0 OR voter_turnout_percent > 100)
        """)
        out_of_range = cur.fetchone()[0]
    with db_conn.cursor() as cur:
        cur.execute("""
            SELECT COUNT(*) FROM silver.election_results
            WHERE voter_turnout_percent IS NULL
        """)
        nulls = cur.fetchone()[0]
    if nulls > 0:
        warnings.append(f"WARN  silver.election_results: {nulls} NULL turnout values — expected for 2019/2024 rows")
    if out_of_range == 0:
        passed.append("PASS  silver.election_results: all non-null turnout values between 0-100")
    else:
        errors.append(f"FAIL  silver.election_results: {out_of_range} rows with turnout out of range")
    print_summary("TC-S07 TURNOUT PCT RANGE", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-S08: Silver tables must not be empty
def test_silver_tables_not_empty(db_conn):
    errors, warnings, passed = [], [], []
    tables = ["silver.election_results", "silver.population"]
    for full_table in tables:
        schema, table = full_table.split(".")
        count = db_count(db_conn, schema, table)
        if count == 0:
            errors.append(f"FAIL  {full_table}: table is empty")
        else:
            passed.append(f"PASS  {full_table}: {count} rows")
    print_summary("TC-S08 SILVER TABLES NOT EMPTY", passed, warnings, errors, len(tables))
    assert not errors, "\n".join(errors)

# TC-S09: No negative population values
def test_silver_no_negative_population(db_conn):
    errors, warnings, passed = [], [], []
    with db_conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM silver.population WHERE total_age_population < 0")
        neg = cur.fetchone()[0]
    if neg == 0:
        passed.append("PASS  silver.population: no negative total_age_population values")
    else:
        errors.append(f"FAIL  silver.population: {neg} rows with negative population")
    print_summary("TC-S09 NO NEGATIVE POPULATION", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-S10: Election years must be valid known values
def test_silver_valid_election_years(db_conn):
    errors, warnings, passed = [], [], []
    valid_years = {2004, 2009, 2014, 2019, 2024}
    with db_conn.cursor() as cur:
        cur.execute("SELECT DISTINCT year FROM silver.election_results WHERE year IS NOT NULL")
        actual = {row[0] for row in cur.fetchall()}
    invalid = actual - valid_years
    if invalid:
        errors.append(f"FAIL  silver.election_results: unexpected year values: {invalid}")
    else:
        passed.append(f"PASS  silver.election_results: all year values valid: {sorted(actual)}")
    print_summary("TC-S10 VALID ELECTION YEARS", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)
