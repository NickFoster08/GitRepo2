#!/bin/bash
#SBATCH --job-name=Spain_WL_Rename      # Job name
#SBATCH --partition=batch                # Partition (queue) name
#SBATCH --ntasks=1                       # Run on a single CPU
#SBATCH --cpus-per-task=8                # Number of cores per task
#SBATCH --mem=80gb                       # Job memory request
#SBATCH --time=00-12:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out  # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err   # Standard error log

#SBATCH --mail-type=END,FAIL             # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu      # Where to send mail

# Specify output directory
OUTDIR="/scratch/nf26742/Spain_WL"

# Create output directory if it doesn't exist
mkdir -p "$OUTDIR"

# Define the directory where your FASTQ files are located
OUTDIR="/scratch/nf26742/Spain_WLv"

# Path to the metadata TSV file
METADATA="/scratch/nf26742/Spain_WL/All_MetaData_WL_Spain_FINAL.tsv"

# Read header and get column numbers
header=$(head -1 "$METADATA")

geo_col=$(echo "$header" | tr '\t' '\n' | grep -n -i 'geo_loc_name_country' | cut -d: -f1)
host_col=$(echo "$header" | tr '\t' '\n' | grep -n -i 'HOST' | cut -d: -f1)
date_col=$(echo "$header" | tr '\t' '\n' | grep -n -i 'Collection_Date' | cut -d: -f1)
run_col=$(echo "$header" | tr '\t' '\n' | grep -n -i '^Run$' | cut -d: -f1)

if [[ -z $geo_col || -z $host_col || -z $date_col || -z $run_col ]]; then
    echo "❌ Error: Could not find one or more required columns in the metadata header."
    exit 1
fi

# Process each line, skipping the header
tail -n +2 "$METADATA" | while IFS=$'\t' read -r line; do
    geo_loc=$(echo "$line" | awk -F'\t' -v col=$geo_col '{print $col}')
    host=$(echo "$line" | awk -F'\t' -v col=$host_col '{print $col}')
    date=$(echo "$line" | awk -F'\t' -v col=$date_col '{print $col}')
    runid=$(echo "$line" | awk -F'\t' -v col=$run_col '{print $col}')

    # Clean for filenames
    safe_geo=$(echo "$geo_loc" | sed 's/ /_/g' | sed 's/[^a-zA-Z0-9_-]//g')
    safe_host=$(echo "$host" | sed 's/ /_/g' | sed 's/[^a-zA-Z0-9_-]//g')
    safe_date=$(echo "$date" | sed 's#[/: ]#_#g' | sed 's/[^a-zA-Z0-9_-]//g')

    # Compose new file name
    newbase="${safe_geo}_${safe_host}_${safe_date}-${runid}"
    r1="${OUTDIR}/${runid}_1.fastq"
    r2="${OUTDIR}/${runid}_2.fastq"
    new_r1="${OUTDIR}/${newbase}_1.fastq"
    new_r2="${OUTDIR}/${newbase}_2.fastq"

    if [[ -f "$r1" && -f "$r2" ]]; then
        mv "$r1" "$new_r1"
        mv "$r2" "$new_r2"
        echo "✅ Renamed $runid to $newbase"
    else
        echo "⚠️  One or both FASTQ files missing for $runid"
    fi
done
