#!/bin/bash
#SBATCH --job-name=Metdata_extract
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=80gb
#SBATCH --time=00-12:00:00
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=nf26742@uga.edu

INPUT_FILE="/scratch/nf26742/Spain_WL/Full_Spain_WL_List.txt"
OUTPUT_FILE="/scratch/nf26742/Spain_WL/Spain_Metadata_Parsed.tsv"

# Initialize variables
ACC=""
DATE=""
HOST=""
COUNTRY=""

# Write header (optional)
echo -e "Country\tAccession\tCollection_Date\tHost" > "$OUTPUT_FILE"

while IFS= read -r line; do
    # Accession
    if [[ $line =~ Accession:\ ([A-Z0-9_]+) ]]; then
        ACC="${BASH_REMATCH[1]}"
    fi

    # Collection Date
    if [[ $line =~ /collection\ date=\"([^\"]+)\" ]]; then
        DATE="${BASH_REMATCH[1]}"
    fi

    # Host
    if [[ $line =~ /host=\"([^\"]+)\" ]]; then
        HOST="${BASH_REMATCH[1]}"
    fi

    # Country
    if [[ $line =~ /geographic\ location=\"([^\"]+)\" ]]; then
        COUNTRY="${BASH_REMATCH[1]}"
    fi

    # If all values are collected, write to output and reset
    if [[ -n $ACC && -n $DATE && -n $HOST && -n $COUNTRY ]]; then
        echo -e "${COUNTRY}\t${ACC}\t${DATE}\t${HOST}" >> "$OUTPUT_FILE"

        # Reset variables for next record
        ACC=""
        DATE=""
        HOST=""
        COUNTRY=""
    fi
done < "$INPUT_FILE"

echo "✅ Done. Parsed metadata written to: $OUTPUT_FILE"
