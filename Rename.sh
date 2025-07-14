#!/bin/bash

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
        OLD1="$FASTQ_DIR/${SRR}_1.fastq.gz"
        OLD2="$FASTQ_DIR/${SRR}_2.fastq.gz"
        NEW1="$FASTQ_DIR/${LOCATION}_${YEAR}_${HOST}_${SRR}_1.fastq.gz"
        NEW2="$FASTQ_DIR/${LOCATION}_${YEAR}_${HOST}_${SRR}_2.fastq.gz"

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
