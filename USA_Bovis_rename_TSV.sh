#!/bin/bash
#SBATCH --job-name=USA_Bovis_Rename        # Job name
#SBATCH --partition=batch                 # Partition (queue) name
#SBATCH --ntasks=1                        # Run on a single CPU
#SBATCH --cpus-per-task=8                 # Number of cores per task
#SBATCH --mem=80gb                        # Job memory request
#SBATCH --time=00-12:00:00                # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out  # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err   # Standard error log
#SBATCH --mail-type=END,FAIL              # Mail events
#SBATCH --mail-user=nf26742@uga.edu       # Where to send mail


OUTDIR="/scratch/nf26742/USA_Bovis_Human"
mkdir -p "$OUTDIR"

METADATA="$OUTDIR/USA_Bovis_MD.tsv"
if [[ ! -f "$METADATA" ]]; then
    echo "❌ Metadata file not found!"
    exit 1
fi

sed -i 's/\r$//' "$METADATA"

header=$(head -n 1 "$METADATA" | tr -d '\r')
echo "Columns found:"
echo "$header" | tr '\t' '\n' | nl

# Identify columns
host_col=$(echo "$header" | tr '\t' '\n' | grep -ni '^HOST$' | cut -d: -f1)
site_col=$(echo "$header" | tr '\t' '\n' | grep -ni '^Site_TB_Disease$' | cut -d: -f1)
geo_col=$(echo "$header" | tr '\t' '\n' | grep -ni '^geo_loc_name_country$' | cut -d: -f1)
year_col=$(echo "$header" | tr '\t' '\n' | grep -ni '^Collection_Date$' | cut -d: -f1)
run_col=$(echo "$header" | tr '\t' '\n' | grep -ni '^Run$' | cut -d: -f1)

if [[ -z $host_col || -z $site_col || -z $geo_col || -z $year_col || -z $run_col ]]; then
    echo "❌ Missing required columns!"
    exit 1
fi

tail -n +2 "$METADATA" | while IFS=$'\t' read -r -a fields; do
    host="${fields[$((host_col-1))]}"
    site="${fields[$((site_col-1))]}"
    geo="${fields[$((geo_col-1))]}"
    year="${fields[$((year_col-1))]}"
    runid="${fields[$((run_col-1))]}"

    # Clean strings for filenames
    safe_host=$(echo "$host" | sed 's/ /_/g' | sed 's/[^a-zA-Z0-9_-]//g')
    safe_site=$(echo "$site" | sed 's/ /_/g' | sed 's/[^a-zA-Z0-9_-]//g')
    safe_geo=$(echo "$geo" | sed 's/ /_/g' | sed 's/[^a-zA-Z0-9_-]//g')
    safe_year=$(echo "$year" | sed 's/[^a-zA-Z0-9_-]//g')

    newbase="${safe_host}_${safe_site}_${safe_geo}_${safe_year}_${runid}"

    r1="${OUTDIR}/${runid}_1.fastq"
    r2="${OUTDIR}/${runid}_2.fastq"
    new_r1="${OUTDIR}/${newbase}_1.fastq"
    new_r2="${OUTDIR}/${newbase}_2.fastq"

    echo "🔎 Checking files: $r1 / $r2"

    if [[ -f "$r1" && -f "$r2" ]]; then
        mv "$r1" "$new_r1"
        mv "$r2" "$new_r2"
        echo "✅ Renamed $runid → $newbase"
    else
        echo "⚠️ Missing FASTQ files for $runid"
    fi
done

echo "🎯 Renaming complete."
