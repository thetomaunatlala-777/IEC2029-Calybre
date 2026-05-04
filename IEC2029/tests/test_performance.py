import pytest
import time
from helpers import print_summary

# TC-N01 to TC-N04: Query performance — key queries must complete within SLA

def test_performance_province_summary_query(db_conn):
    errors, warnings, passed = [], [], []
    start = time.time()
    with db_conn.cursor() as cur:
        cur.execute("""
            SELECT province, COUNT(*) as total_records,
            SUM(party_votes) as total_votes
            FROM silver.election_results
            GROUP BY province
            ORDER BY province
        """)
        cur.fetchall()
    elapsed = time.time() - start
    if elapsed < 5:
        passed.append(f"PASS  Province summary query: {elapsed:.2f}s (SLA: 5s)")
    else:
        errors.append(f"FAIL  Province summary query: {elapsed:.2f}s — exceeds 5s SLA")
    print_summary("TC-N01 PROVINCE SUMMARY QUERY PERFORMANCE", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

def test_performance_ward_level_query(db_conn):
    errors, warnings, passed = [], [], []
    start = time.time()
    with db_conn.cursor() as cur:
        cur.execute("""
            SELECT ward, province, SUM(party_votes) as total_votes
            FROM silver.election_results
            WHERE year = 2024
            GROUP BY ward, province
            ORDER BY total_votes DESC
            LIMIT 100
        """)
        cur.fetchall()
    elapsed = time.time() - start
    if elapsed < 10:
        passed.append(f"PASS  Ward level query: {elapsed:.2f}s (SLA: 10s)")
    else:
        errors.append(f"FAIL  Ward level query: {elapsed:.2f}s — exceeds 10s SLA")
    print_summary("TC-N02 WARD LEVEL QUERY PERFORMANCE", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

def test_performance_gold_join_query(db_conn):
    errors, warnings, passed = [], [], []
    start = time.time()
    with db_conn.cursor() as cur:
        cur.execute("""
            SELECT g.province, g.municipality, g.party_name,
            g.party_votes, p.total_population
            FROM gold."2024_npe" g
            LEFT JOIN gold.voting_stations v ON g.vd_number = v.vd_number
            LEFT JOIN gold.population p ON v.ward_number = p.ward_number
            LIMIT 1000
        """)
        cur.fetchall()
    elapsed = time.time() - start
    if elapsed < 10:
        passed.append(f"PASS  Gold join query: {elapsed:.2f}s (SLA: 10s)")
    else:
        errors.append(f"FAIL  Gold join query: {elapsed:.2f}s — exceeds 10s SLA")
    print_summary("TC-N03 GOLD JOIN QUERY PERFORMANCE", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

def test_performance_full_election_scan(db_conn):
    errors, warnings, passed = [], [], []
    start = time.time()
    with db_conn.cursor() as cur:
        cur.execute("""
            SELECT year, election_type, COUNT(*) as records,
            SUM(party_votes) as total_votes
            FROM silver.election_results
            GROUP BY year, election_type
            ORDER BY year
        """)
        results = cur.fetchall()
    elapsed = time.time() - start
    if elapsed < 15:
        passed.append(f"PASS  Full election scan: {elapsed:.2f}s, {len(results)} year groups (SLA: 15s)")
    else:
        errors.append(f"FAIL  Full election scan: {elapsed:.2f}s — exceeds 15s SLA")
    print_summary("TC-N04 FULL ELECTION SCAN PERFORMANCE", passed, warnings, errors, 1)
    assert not errors, "\n".join(errors)

# TC-N06: Solution reproducibility — required files exist
def test_reproducibility_required_files_exist():
    errors, warnings, passed = [], [], []
    import os
    required = [
        "/app/notebooks",
        "/app/requirements.txt",
        "/app/docker-compose.yml",
    ]
    for path in required:
        if os.path.exists(path):
            passed.append(f"PASS  {path} exists")
        else:
            errors.append(f"FAIL  {path} missing — solution may not be reproducible")
    print_summary("TC-N06 REPRODUCIBILITY FILES EXIST", passed, warnings, errors, len(required))
    assert not errors, "\n".join(errors)

# TC-N07: requirements.txt must list key dependencies
def test_reproducibility_requirements_complete():
    errors, warnings, passed = [], [], []
    import os
    req_path = "/app/requirements.txt"
    required_packages = ["pandas", "psycopg2", "sqlalchemy", "pytest", "python-dotenv"]
    if not os.path.exists(req_path):
        errors.append("FAIL  requirements.txt not found")
    else:
        with open(req_path) as f:
            content = f.read().lower()
        for pkg in required_packages:
            if pkg.lower() in content:
                passed.append(f"PASS  {pkg} in requirements.txt")
            else:
                errors.append(f"FAIL  {pkg} missing from requirements.txt")
    print_summary("TC-N07 REQUIREMENTS COMPLETE", passed, warnings, errors, len(required_packages))
    assert not errors, "\n".join(errors)
