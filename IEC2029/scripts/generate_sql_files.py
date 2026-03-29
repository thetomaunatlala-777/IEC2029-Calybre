import os

output_dir = "scripts"
os.makedirs(output_dir, exist_ok=True)

files = {
    "transform_bronze.sql": transform_bronze,
    "transform_silver.sql": transform_silver,
    "transform_gold.sql":   transform_gold,
}

for filename, content in files.items():
    path = os.path.join(output_dir, filename)
    with open(path, "w") as f:
        f.write(content.strip())
    print(f"Created: {path}")

print("\nDone! Open the scripts/ folder in VS Code.")