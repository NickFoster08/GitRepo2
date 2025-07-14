#!/bin/bash
#SBATCH --job-name=Spain_WL_download
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=80gb
#SBATCH --time=00-12:00:00
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=nf26742@uga.edu

module load SRA-Toolkit/3.0.3-gompi-2022a
module load EntrezDirect/13.8

INPUT="Full_Spain_WL_List.txt"
OUTDIR="/scratch/nf26742/Spain_WL"
mkdir -p "$OUTDIR"

# Parse input file and extract "Host_Country_Year" label and SRA experiment accession (ERS)
awk -v RS="" '
  {
    host = "unknown_host"
    if (match($0, /\/host="([^"]+)"/, h)) { host = h[1] }
    gsub(/ /, "_", host)

    country = "unknown_country"
    if (match($0, /\/geographic location="([^"]+)"/, c)) { country = c[1] }
    gsub(/ /, "_", country)

    year = "unknown_year"
    if (match($0, /\/collection date="([^"]+)"/, d)) {
      split(d[1], arr, "-")
      year = arr[length(arr)]
    }

    sra_acc = ""
    if (match($0, /SRA: ([^; \n]+)/, s)) { sra_acc = s[1] }

    if (sra_acc != "") {
      print host "_" country "_" year "\t" sra_acc
    }
  }
' "$INPUT" > samples_sra.tsv

# Download loop: for each sample label + ERS, find SRR runs and download
while IFS=$'\t' read -r sample sra_acc; do
    echo "Processing sample $sample with SRA experiment $sra_acc"

    # Get SRR run accessions for this ERS
    srrs=$(esearch -db sra -query "$sra_acc" | efetch -format runinfo | cut -d',' -f1 | grep '^SRR')

    if [[ -z "$srrs" ]]; then
        echo "⚠️ No SRR runs found for $sra_acc (sample $sample)"
        continue
    fi

    for srr in $srrs; do
        echo "Downloading $srr for sample $sample"

        fasterq-dump "$srr" -O "$OUTDIR" --threads 8 --split-files

        # Rename files to Host_Country_Year_SRR_1.fastq and _2.fastq
        if [[ -f "$OUTDIR/${srr}_1.fastq" ]]; then
          mv "$OUTDIR/${srr}_1.fastq" "$OUTDIR/${sample}_${srr}_1.fastq"
        fi
        if [[ -f "$OUTDIR/${srr}_2.fastq" ]]; then
          mv "$OUTDIR/${srr}_2.fastq" "$OUTDIR/${sample}_${srr}_2.fastq"
        fi

        if [[ $? -eq 0 ]]; then
            echo "✅ Successfully downloaded $srr for sample $sample"
        else
            echo "❌ Failed to download $srr for sample $sample"
        fi
    done
done < samples_sra.tsv
