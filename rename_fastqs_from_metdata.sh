#!/bin/bash
#SBATCH --job-name=Rename_FASTQs_Metadata
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4gb
#SBATCH --time=01:00:00
#SBATCH --output=/scratch/nf26742/scratch/rename.%j.out
#SBATCH --error=/scratch/nf26742/scratch/rename.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=nf26742@uga.edu

# ---- CONFIG ----
FASTQ_DIR="/scratch/nf26742/Spain_WL"
METADATA_FILE="/scratch/nf26742/Spain_WL/Full_Spain_WL_List.txt"
PARSED_FILE="/scratch/nf26742/Spain_WL/Spain_Metadata_Parsed.tsv"

# ---- BUILD MAPPING: Accession → Country_Date_Host ----
declare -A acc_to_metadata
while IFS=$'\t' read -r country acc date host; do
    clean_host=${host// /-}
    clean_host=${clean_host//[^a-zA-Z0-9_-]/}
    year=${date:0:4}
    key="$acc"
    value="${country}_${year}_${clean_host}"
    acc_to_metadata["$key"]="$value"
done < <(tail -n +2 "$PARSED_FILE")  # Skip header

# ---- MAP SRR → Accession AND RENAME FILES ----
srr=""
accession=""
while IFS= read -r line; do
    [[ $line =~ (SRR[0-9]+) ]] && srr="${BASH_REMATCH[1]}"
    [[ $line =~ BioSample:\ (SAME[A-Z0-9]+) ]] && accession="${BASH_REMATCH[1]}"

    if [[ -n $srr && -n $accession ]]; then
        metadata="${acc_to_metadata[$accession]}"
        if [[ -n $metadata ]]; then
            old1="${FASTQ_DIR}/${srr}_1.fastq"
            old2="${FASTQ_DIR}/${srr}_2.fastq"
            new1="${FASTQ_DIR}/${metadata}_${srr}_1.fastq"
            new2="${FASTQ_DIR}/${metadata}_${srr}_2.fastq"

            if [[ -f "$old1" && -f "$old2" ]]; then
                mv "$old1" "$new1"
                mv "$old2" "$new2"
                echo "✅ Renamed $srr to:"
                echo "   $new1"
                echo "   $new2"
            else
                echo "⚠️  FASTQ files not found for $srr"
            fi
        else
            echo "⚠️  Accession $accession not found in parsed file"
        fi

        srr=""
        accession=""
    fi
done < "$METADATA_FILE"
