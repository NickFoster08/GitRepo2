#!/usr/bin/env python3
import os
import re
import sys

# Check usage
if len(sys.argv) != 3:
    print("Usage: ./rename_fastq.py metadata.txt /path/to/fastq_dir")
    sys.exit(1)

metadata_file = sys.argv[1]
fastq_dir = sys.argv[2]

# Read metadata file
with open(metadata_file, "r") as f:
    content = f.read()

# Parse metadata entries by splitting on lines that start with a number and colon (e.g., '1:')
entries = re.split(r"\n\d+:\s", "\n" + content)

# Store info keyed by SRR ID
metadata = {}

for entry in entries:
    # Extract SRR ID - look for lines like "SRA: SRR18391669" or similar (adapt if your metadata differs)
    sra_match = re.search(r"SRA:\s*(SRR\d+)", entry)
    if not sra_match:
        continue
    srr_id = sra_match.group(1)

    # Extract collection date
    collection_date_match = re.search(r'/collection date="([^"]+)"', entry)
    if not collection_date_match:
        continue
    collection_date = collection_date_match.group(1)
    year = collection_date.split("-")[0]

    # Extract geographic location (country)
    geo_match = re.search(r'/geographic location="([^"]+)"', entry)
    if not geo_match:
        continue
    geo = geo_match.group(1).replace(" ", "_")

    # Extract host
    host_match = re.search(r'/host="([^"]+)"', entry)
    if not host_match:
        continue
    host = host_match.group(1).replace(" ", "_")

    metadata[srr_id] = {
        "year": year,
        "geo": geo,
        "host": host,
    }

# Now rename FASTQ files
for filename in os.listdir(fastq_dir):
    # Match files starting with SRR and possibly ending with .fastq or .fastq.gz
    fastq_match = re.match(r"(SRR\d+)(_.*\.fastq(?:\.gz)?)", filename)
    if fastq_match:
        srr_id = fastq_match.group(1)
        suffix = fastq_match.group(2)

        if srr_id in metadata:
            meta = metadata[srr_id]
            new_name = f"{meta['geo']}_{meta['host']}_{meta['geo']}_{meta['year']}_{srr_id}{suffix}"
            old_path = os.path.join(fastq_dir, filename)
            new_path = os.path.join(fastq_dir, new_name)
            print(f"Renaming:\n  {filename}\n  --> {new_name}\n")
            os.rename(old_path, new_path)
        else:
            print(f"Warning: No metadata found for {srr_id}, skipping file {filename}")

print("All done.")
