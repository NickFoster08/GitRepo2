import os
import re

metadata_file = "/scratch/nf26742/Spain_WL/Full_Spain_WL_List.txt"
files_dir = "/scratch/nf26742/Spain_WL"

# Load full metadata text
with open(metadata_file, "r") as f:
    content = f.read()

# Split entries by number + colon (e.g. "108:")
entries = re.split(r'\n(?=\d+:)', content)

# Build a dict to map sample ID to metadata prefix info
metadata_map = {}

for entry in entries:
    biosample_match = re.search(r'BioSample:\s*(SAMN\d+)', entry)
    if not biosample_match:
        continue
    biosample_id = biosample_match.group(1)

    # Extract fields for prefix: Country, Host, Year
    # Adjust regex if your metadata fields are named differently
    country_match = re.search(r'/geographic location="([^"]+)"', entry)
    country = country_match.group(1).split(":")[-1].strip().replace(" ", "_") if country_match else "UnknownCountry"

    host_match = re.search(r'/host="([^"]+)"', entry)
    host = host_match.group(1).replace(" ", "_") if host_match else "UnknownHost"

    date_match = re.search(r'/collection date="([^"]+)"', entry)
    year = "UnknownYear"
    if date_match:
        year = date_match.group(1).split("-")[0]  # just take year part

    # Create prefix string
    prefix = f"{country}_{host}_{year}"

    # Save in dict keyed by BioSample ID
    metadata_map[biosample_id] = prefix

# Now rename files in folder based on metadata prefix
for filename in os.listdir(files_dir):
    # Check if filename matches SAMN ID pattern with optional _R1/_R2 and extensions
    # Example filenames: SAMN12345678.fastq.gz or SAMN12345678_R1.fastq.gz
    match = re.match(r'(SAMN\d+)(.*)(\.fastq(?:\.gz)?|\.fq(?:\.gz)?)$', filename)
    if not match:
        continue

    sample_id = match.group(1)
    rest = match.group(2)    # e.g., "_R1"
    ext = match.group(3)     # e.g., ".fastq.gz"

    if sample_id not in metadata_map:
        print(f"No metadata for {sample_id}, skipping {filename}")
        continue

    prefix = metadata_map[sample_id]

    new_filename = f"{prefix}_{filename}"
    old_path = os.path.join(files_dir, filename)
    new_path = os.path.join(files_dir, new_filename)

    if os.path.exists(new_path):
        print(f"Warning: {new_filename} already exists, skipping")
        continue

    print(f"Renaming {filename} -> {new_filename}")
    os.rename(old_path, new_path)
print("Script started")
print(f"Metadata file: {metadata_file}")
