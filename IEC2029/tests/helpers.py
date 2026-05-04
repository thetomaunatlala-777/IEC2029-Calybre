import pandas as pd
import os
from psycopg2 import sql

# Read a CSV trying multiple encodings — handles BOM and SA special characters
def read_csv(csv_path):
    for encoding in ["utf-8-sig", "latin-1", "cp1252"]:
        try:
            df = pd.read_csv(csv_path, encoding=encoding, low_memory=False, on_bad_lines="skip")
            print(f"\n  {os.path.basename(csv_path)}: {len(df)} rows (encoding: {encoding})")
            return df
        except Exception as e:
            print(f"\n  {os.path.basename(csv_path)}: failed with {encoding} — {e}")
    raise ValueError(f"Could not read {csv_path}")

# Get row count from a PostgreSQL table
def db_count(conn, schema, table):
    with conn.cursor() as cur:
        cur.execute(
            sql.SQL("SELECT COUNT(*) FROM {}.{}").format(
                sql.Identifier(schema),
                sql.Identifier(table)
            )
        )
        return cur.fetchone()[0]

# Print a formatted results summary
def print_summary(title, passed, warnings, errors, total):
    print(f"\n{'='*60}")
    print(f"{title} — {total} checked")
    print(f"{'='*60}")
    if passed:
        print(f"\n  PASSED ({len(passed)}):")
        for p in passed: print(f"    {p}")
    if warnings:
        print(f"\n  WARNINGS — within tolerance ({len(warnings)}):")
        for w in warnings: print(f"    {w}")
    if errors:
        print(f"\n  FAILED ({len(errors)}):")
        for e in errors: print(f"    {e}")
    print(f"\n  Summary: {len(passed)} passed, {len(warnings)} warned, {len(errors)} failed")
    print(f"{'='*60}\n")