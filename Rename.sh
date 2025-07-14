#!/bin/bash
#SBATCH --job-name=Spain_Rename      # Job name
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

# Path to metadata file
METADATA_FILE="/scratch/nf26742/Spain_WL/Full_Spain_WL_List.txt"

# Path to directory with FASTQ files
FASTQ_DIR="/scratch/nf26742/Spain_WL"

# Loop through the metadata and extract info
while IFS= read -r line; do
    # Extract SRR ID
    if [[ $line =~ (SRR[0-9]+) ]]; then
        SRR=${BASH_REMATCH[1]}
    fi

    # Extract geographic location
    if [[ $line =~ /geographic\ location=\"([^\"]+)\" ]]; then
        LOCATION="${BASH_REMATCH[1]}"
        LOCATION=${LOCATION// /-}  # Replace spaces with dashes
    fi

    # Extract host
    if [[ $line =~ /host=\"([^\"]+)\" ]]; then
        HOST="${BASH_REMATCH[1]}"
        HOST=${HOST// /-}
    fi

    # Extract collection date (just the year)
    if [[ $line =~ /collection\ date=\"([0-9]{4}) ]]; then
        YEAR="${BASH_REMATCH[1]}"
    fi

    # Once all are set, rename files
    if [[ -n $SRR && -n $LOCATION && -n $HOST && -n $YEAR ]]; then
        OLD1="$FASTQ_DIR/${SRR}_1.fastq"
        OLD2="$FASTQ_DIR/${SRR}_2.fastq"
        NEW1="$FASTQ_DIR/${LOCATION}_${YEAR}_${HOST}_${SRR}_1.fastq"
        NEW2="$FASTQ_DIR/${LOCATION}_${YEAR}_${HOST}_${SRR}_2.fastq"

        # Rename only if files exist
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
