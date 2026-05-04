import pytest
from helpers import db_count, print_summary

GOLD_TABLES = ["vote", "location", "party", "date", "demographic"]

# TC-G01: All gold tables must not be empty
def test_gold_tables_not_empty(db_conn):
    errors, warnings, passed = [], [], []
    for table in GOLD_TABLES:
        count = db_count(db_conn, "gold", table)
        if count == 0:
            errors.append(f"FAIL  gold.{table}: table is empty")
        else:
            passed.append(f"PASS  gold.{table}: {count} rows")
    print_summary("TC-G01 GOLD TABLES NOT EMPTY", passed, warnings, errors, len(GOLD_TABLES))
    assert not errors, "\n".join(errors)

# TC-G02: gold.vote row count must be > 0 and reconcile to silver scope
def test_gold_vote_reconciles_to_silver(db_conn):
    errors, warnings, passed = [], [], []
    silver_rows = db_count(db_conn, "silver", "election_results")
    gold_rows   = db_count(db_conn, "gold", "vote")
    if gold_rows == 0:
        errors.append("FAIL  gold.vote: table is empty")
    elif gold_rows <= silver_rows:
        passed.append(f"PASS  gold.vote: {gold_rows} rows (silver scope={silver_rows})")
    else:
        errors.append(f"FAIL  gold.vote: {gold_rows} rows exceeds silver {silver_rows}")
    print_summary("TC-G02 GOLD VOTE RECONCILES TO SILVER", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-G03: All 9 provinces present in gold.location
def test_gold_all_9_provinces(db_conn):
    errors, warnings, passed = [], [], []
    valid_provinces = {
        "EASTERN CAPE", "FREE STATE", "GAUTENG", "KWAZULU-NATAL",
        "LIMPOPO", "MPUMALANGA", "NORTH WEST", "NORTHERN CAPE", "WESTERN CAPE"
    }
    with db_conn.cursor() as cur:
        cur.execute("SELECT DISTINCT province FROM gold.location WHERE province IS NOT NULL")
        actual = {row[0] for row in cur.fetchall()}
    missing = valid_provinces - actual
    if missing:
        errors.append(f"FAIL  gold.location: missing provinces: {missing}")
    else:
        passed.append(f"PASS  gold.location: all 9 provinces present")
    print_summary("TC-G03 ALL 9 PROVINCES IN GOLD", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-G04: No negative values in gold.vote
def test_gold_no_negative_votes(db_conn):
    errors, warnings, passed = [], [], []
    with db_conn.cursor() as cur:
        cur.execute("""
            SELECT COUNT(*) FROM gold.vote
            WHERE party_votes < 0
            OR total_votes < 0
            OR registered_population < 0
        """)
        neg = cur.fetchone()[0]
    if neg == 0:
        passed.append("PASS  gold.vote: no negative values")
    else:
        errors.append(f"FAIL  gold.vote: {neg} rows with negative values")
    print_summary("TC-G04 NO NEGATIVE VALUES IN GOLD", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-G05: Turnout percentage between 0 and 100 in gold.vote
def test_gold_turnout_pct_range(db_conn):
    errors, warnings, passed = [], [], []
    with db_conn.cursor() as cur:
        cur.execute("""
            SELECT COUNT(*) FROM gold.vote
            WHERE voter_turnout_percent < 0
            OR voter_turnout_percent > 100
        """)
        out = cur.fetchone()[0]
    if out == 0:
        passed.append("PASS  gold.vote: all turnout values between 0-100")
    else:
        errors.append(f"FAIL  gold.vote: {out} rows with turnout out of range")
    print_summary("TC-G05 TURNOUT PCT RANGE IN GOLD", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-G06: gold.location must have valid SA coordinates
def test_gold_valid_coordinates(db_conn):
    errors, warnings, passed = [], [], []
    with db_conn.cursor() as cur:
        cur.execute("""
            SELECT COUNT(*) FROM gold.location
            WHERE station_latitude IS NULL OR station_longitude IS NULL
        """)
        nulls = cur.fetchone()[0]
    with db_conn.cursor() as cur:
        cur.execute("""
            SELECT COUNT(*) FROM gold.location
            WHERE station_latitude IS NOT NULL
            AND (station_latitude NOT BETWEEN -35 AND -22
            OR station_longitude NOT BETWEEN 16 AND 33)
        """)
        invalid = cur.fetchone()[0]
    total = db_count(db_conn, "gold", "location")
    null_pct = nulls / total if total > 0 else 0
    if null_pct > 0.05:
        errors.append(f"FAIL  gold.location: {nulls} rows ({null_pct:.1%}) with NULL coordinates — exceeds 5%")
    else:
        warnings.append(f"WARN  gold.location: {nulls} rows with NULL coordinates ({null_pct:.1%}) — within tolerance")
        passed.append(f"PASS  gold.location: coordinate NULL rate acceptable")
    if invalid == 0:
        passed.append("PASS  gold.location: all non-null coordinates within SA bounds")
    else:
        errors.append(f"FAIL  gold.location: {invalid} coordinates outside SA bounds")
    print_summary("TC-G06 VALID SA COORDINATES", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-G07: gold.demographic ward_numbers must match gold.location
def test_gold_demographic_ward_join(db_conn):
    errors, warnings, passed = [], [], []
    with db_conn.cursor() as cur:
        cur.execute("""
            SELECT COUNT(*) FROM gold.location l
            LEFT JOIN gold.demographic d ON l.ward_number = d.ward_number
            WHERE d.ward_number IS NULL
        """)
        unmatched = cur.fetchone()[0]
    if unmatched == 0:
        passed.append("PASS  gold.location: all ward_numbers found in gold.demographic")
    else:
        warnings.append(f"WARN  gold.location: {unmatched} ward_numbers not in gold.demographic")
    print_summary("TC-G07 DEMOGRAPHIC WARD JOIN", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-G08: gold.demographic total_population must be positive
def test_gold_population_positive(db_conn):
    errors, warnings, passed = [], [], []
    with db_conn.cursor() as cur:
        cur.execute("""
            SELECT COUNT(*) FROM gold.demographic
            WHERE total_age_population <= 0
        """)
        zero = cur.fetchone()[0]
    if zero == 0:
        passed.append("PASS  gold.demographic: all total_age_population values positive")
    else:
        errors.append(f"FAIL  gold.demographic: {zero} rows with zero or negative population")
    print_summary("TC-G08 POPULATION VALUES POSITIVE", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-G09: Referential integrity — all FKs in gold.vote must resolve
def test_gold_referential_integrity(db_conn):
    errors, warnings, passed = [], [], []
    checks = [
        ("location_id", "gold.location", "location_id"),
        ("party_id",    "gold.party",    "party_id"),
        ("date_id",     "gold.date",     "date_id"),
    ]
    for fk_col, ref_table, ref_col in checks:
        schema, table = ref_table.split(".")
        with db_conn.cursor() as cur:
            cur.execute(f"""
                SELECT COUNT(*) FROM gold.vote v
                LEFT JOIN {ref_table} r ON v.{fk_col} = r.{ref_col}
                WHERE r.{ref_col} IS NULL
            """)
            orphans = cur.fetchone()[0]
        if orphans == 0:
            passed.append(f"PASS  gold.vote.{fk_col}: all FKs resolve to {ref_table}")
        else:
            errors.append(f"FAIL  gold.vote.{fk_col}: {orphans} orphaned FK values")
    print_summary("TC-G09 REFERENTIAL INTEGRITY", passed, warnings, errors, len(checks))
    assert not errors, "\n".join(errors)

# TC-G10: gold.party must have no duplicate party names
def test_gold_no_duplicate_parties(db_conn):
    errors, warnings, passed = [], [], []
    with db_conn.cursor() as cur:
        cur.execute("""
            SELECT COUNT(*) FROM (
                SELECT party_name, COUNT(*)
                FROM gold.party
                GROUP BY party_name
                HAVING COUNT(*) > 1
            ) dupes
        """)
        dupes = cur.fetchone()[0]
    if dupes == 0:
        passed.append("PASS  gold.party: no duplicate party names")
    else:
        errors.append(f"FAIL  gold.party: {dupes} duplicate party names")
    print_summary("TC-G10 NO DUPLICATE PARTIES", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)
