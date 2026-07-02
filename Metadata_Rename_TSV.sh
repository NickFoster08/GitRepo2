#!/bin/bash
#SBATCH --job-name=TSV_Rename        # Job name
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
 
OUTDIR="/lustre2/scratch/nf26742/Mbovis_Africa_Europe"
METADATA="/lustre2/scratch/nf26742/Mbovis_Africa_Europe/Morocco_Metadata_Clean.tsv"
 
echo "Running script: $0"
echo "Working directory: $(pwd)"
 
mkdir -p "$OUTDIR"
 
# Clean metadata
sed -i 's/\r$//' "$METADATA"
sed -i '1s/^\xEF\xBB\xBF//' "$METADATA"
 
# Read header
header=$(head -n1 "$METADATA")
echo "Header: $header"
 
# Detect column positions (TAB delimiter)
run_col=$(echo "$header" | awk -F'\t' '{for(i=1;i<=NF;i++) if($i=="Run") print i}')
date_col=$(echo "$header" | awk -F'\t' '{for(i=1;i<=NF;i++) if($i=="Collection_Date") print i}')
country_col=$(echo "$header" | awk -F'\t' '{for(i=1;i<=NF;i++) if($i=="geo_loc_name_country") print i}')
host_col=$(echo "$header" | awk -F'\t' '{for(i=1;i<=NF;i++) if($i=="Host") print i}')
 
if [[ -z "$run_col" || -z "$date_col" || -z "$country_col" || -z "$host_col" ]]; then
    echo "ERROR: Required columns not found."
    exit 1
fi
 
echo "Columns detected: Run=$run_col, Date=$date_col, Country=$country_col, Host=$host_col"
 
# Process rows (TAB delimiter)
while IFS=$'\t' read -r -a fields; do
    # Skip header line
    [[ "${fields[0]}" == "Run" ]] && continue
 
    runid=$(echo "${fields[$((run_col-1))]}" | tr -d '"' | xargs)
    country=$(echo "${fields[$((country_col-1))]}" | tr -d '"' | xargs)
    date=$(echo "${fields[$((date_col-1))]}" | tr -d '"' | xargs)
    host=$(echo "${fields[$((host_col-1))]}" | tr -d '"' | xargs)
 
    [[ -z "$runid" ]] && continue
 
    # Sanitize for filenames
    safe_host=$(echo "$host" | sed 's/ /_/g' | sed 's/[^a-zA-Z0-9_-]//g')
    safe_date=$(echo "$date" | sed 's#[/: ]#_#g' | sed 's/[^a-zA-Z0-9_-]//g')
    safe_country=$(echo "$country" | sed 's/ /_/g' | sed 's/[^a-zA-Z0-9_-]//g')
 
    # New naming format: Location_Host_Date_Run
    newbase="${safe_country}_${safe_host}_${safe_date}_${runid}"
 
    # Find existing files by matching the runid, regardless of current prefix
    # (handles both raw SRR-named files and files already renamed by a prior pass)
    r1=$(find "$OUTDIR" -maxdepth 1 -type f \( -name "${runid}_1.fastq.gz" -o -name "*-${runid}_1.fastq.gz" -o -name "*_${runid}_1.fastq.gz" \) | head -n1)
    r2=$(find "$OUTDIR" -maxdepth 1 -type f \( -name "${runid}_2.fastq.gz" -o -name "*-${runid}_2.fastq.gz" -o -name "*_${runid}_2.fastq.gz" \) | head -n1)
 
    new_r1="${OUTDIR}/${newbase}_1.fastq.gz"
    new_r2="${OUTDIR}/${newbase}_2.fastq.gz"
 
    if [[ -n "$r1" && -n "$r2" ]]; then
        if [[ "$r1" == "$new_r1" && "$r2" == "$new_r2" ]]; then
            echo "Already correctly named: $runid -> $newbase"
        else
            mv "$r1" "$new_r1"
            mv "$r2" "$new_r2"
            echo "Renamed $runid -> $newbase"
        fi
    else
        echo "Skipping $runid (files not found)"
    fi
done < "$METADATA"
 
echo "Renaming complete."