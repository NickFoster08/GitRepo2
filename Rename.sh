#!/bin/bash
#SBATCH --job-name=Spain_Rename
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=80gb
#SBATCH --time=00-12:00:00
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=nf26742@uga.edu

OUTDIR="/scratch/nf26742/Spain_WL"
METADATA_FILE="/scratch/nf26742/Spain_WL/Full_Spain_WL_List.txt"
FASTQ_DIR="/scratch/nf26742/Spain_WL"

SRR=""
LOCATION=""
HOST=""
YEAR=""

while IFS= read -r line; do
    # Extract SRR
    if [[ $line =~ (SRR[0-9]+) ]]; then
        SRR="${BASH_REMATCH[1]}"
    fi

    # Extract location
    if [[ $line =~ /geographic\ location=\"([^\"]+)\" ]]; then
        LOCATION="${BASH_REMATCH[1]// /-}"
    fi

    # Extract host
    if [[ $line =~ /host=\"([^\"]+)\" ]]; then
        HOST="${BASH_REMATCH[1]// /-}"
    fi

    # Extract year
    if [[ $line =~ /collection\ date=\"([0-9]{4}) ]]; then
        YEAR="${BASH_REMATCH[1]}"
    fi

    # When all values are present, rename
    if [[ -n $SRR && -n $LOCATION && -n $HOST && -n $YEAR ]]; then
        OLD1="$FASTQ_DIR/${SRR}_1.fastq"
        OLD2="$FASTQ_DIR/${SRR}_2.fastq"
        NEW1="$FASTQ_DIR/${LOCATION}_${YEAR}_${HOST}_${SRR}_1.fastq"
        NEW2="$FASTQ_DIR/${LOCATION}_${YEAR}_${HOST}_${SRR}_2.fastq"

        if [[ -f $OLD1 && -f $OLD2 ]]; then
            mv "$OLD1" "$NEW1"
            mv "$OLD2" "$NEW2"
            echo "✅ Renamed $SRR to:"
            echo "   $NEW1"
            echo "   $NEW2"
        else
            echo "⚠️  FASTQ files not found for $SRR"
        fi

        # Reset for next block
        SRR=""
        LOCATION=""
        HOST=""
        YEAR=""
    fi
done < "$METADATA_FILE"
