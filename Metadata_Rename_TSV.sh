#!/bin/bash
#SBATCH --job-name=CSV_Rename        # Job name
#SBATCH --partition=batch                 # Partition (queue) name
#SBATCH --ntasks=1                        # Run on a single CPU
#SBATCH --cpus-per-task=8                 # Number of cores per task
#SBATCH --mem=80gb                        # Job memory request
#SBATCH --time=00-12:00:00                # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out  # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err   # Standard error log
#SBATCH --mail-type=END,FAIL              # Mail events
#SBATCH --mail-user=nf26742@uga.edu       # Where to send mail

set -euo pipefail

OUTDIR="/lustre2/scratch/nf26742/Mex_USA_Animal_Bovis"
METADATA="/lustre2/scratch/nf26742/Mex_USA_Animal_Bovis/Mexico_USA_Metadata.tsv"

echo "Running script: $0"
echo "Working directory: $(pwd)"

mkdir -p "$OUTDIR"

# Clean metadata
sed -i 's/\r$//' "$METADATA"
sed -i '1s/^\xEF\xBB\xBF//' "$METADATA"

# Read header
header=$(head -n1 "$METADATA")
echo "Header: $header"

# Detect column positions
run_col=$(echo "$header" | awk -F',' '{for(i=1;i<=NF;i++) if($i=="Run") print i}')
date_col=$(echo "$header" | awk -F',' '{for(i=1;i<=NF;i++) if($i=="Collection_Date") print i}')
country_col=$(echo "$header" | awk -F',' '{for(i=1;i<=NF;i++) if($i=="geo_loc_name") print i}')
host_col=$(echo "$header" | awk -F',' '{for(i=1;i<=NF;i++) if($i=="HOST") print i}')

if [[ -z "$run_col" || -z "$date_col" || -z "$country_col" || -z "$host_col" ]]; then
    echo "ERROR: Required columns not found."
    exit 1
fi

echo "Columns detected: Run=$run_col, Date=$date_col, Country=$country_col, Host=$host_col"

# Process rows (using while-read without pipe to avoid subshell)
while IFS=',' read -r -a fields; do
    # Skip header line
    [[ "${fields[0]}" == "Run" ]] && continue

runid=$(echo "${fields[$((run_col-1))]}" | tr -d '"' | xargs)
date=$(echo "${fields[$((date_col-1))]}" | tr -d '"' | xargs)
host=$(echo "${fields[$((host_col-1))]}" | tr -d '"' | xargs)

    [[ -z "$runid" ]] && continue

    # Sanitize for filenames
    safe_host=$(echo "$host" | sed 's/ /_/g' | sed 's/[^a-zA-Z0-9_-]//g')
    safe_date=$(echo "$date" | sed 's#[/: ]#_#g' | sed 's/[^a-zA-Z0-9_-]//g')
    newbase="${safe_host}_${safe_date}-${runid}"

    r1="${OUTDIR}/${runid}_1.fastq.gz"
    r2="${OUTDIR}/${runid}_2.fastq.gz"
    new_r1="${OUTDIR}/${newbase}_1.fastq.gz"
    new_r2="${OUTDIR}/${newbase}_2.fastq.gz"

    # Check if original FASTQ files exist
    if [[ -f "$r1" && -f "$r2" ]]; then
        mv "$r1" "$new_r1"
        mv "$r2" "$new_r2"
        echo "Renamed $runid -> $newbase"
    else
        # Skip if files are already renamed or missing
        echo "Skipping $runid (already renamed or missing)"
    fi
done < "$METADATA"

echo "Renaming complete."