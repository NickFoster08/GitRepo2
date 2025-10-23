#!/bin/bash
#SBATCH --job-name=Extract_MD         # Job name
#SBATCH --partition=batch                  # Partition (queue) name
#SBATCH --ntasks=1                         # Run on a single CPU
#SBATCH --cpus-per-task=8                  # Number of cores per task
#SBATCH --mem=80gb                         # Job memory request
#SBATCH --time=00-12:00:00                 # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out  # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err   # Standard error log
#SBATCH --mail-type=END,FAIL               # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu        # Where to send mail

 Input and output
INPUT_FILE="/scratch/nf26742/MI_Bovis/MI_BTB_Metadata.txt"
OUTPUT_FILE="/scratch/nf26742/MI_Bovis/MI_BTB_Metadata_Cleaned.tsv"

# Sanitize Windows line endings
sed -i 's/\r$//' "$INPUT_FILE"

# Write header
echo -e "Country\trun\tCollection_Date\tHost" > "$OUTPUT_FILE"

# Initialize variables
RUN=""
DATE=""
HOST=""
COUNTRY=""

while IFS= read -r line; do
    # Remove any residual carriage returns
    line="${line//$'\r'/}"

    # Extract SRA run ID
    if [[ $line =~ SRA:\ ([A-Z0-9_]+) ]]; then
        RUN="${BASH_REMATCH[1]}"
    fi

    # Collection Date
    if [[ $line =~ /collection\ date=\"([^\"]+)\" ]]; then
        DATE="${BASH_REMATCH[1]}"
        [[ "$DATE" == "not collected" ]] && DATE="NA"
    fi

    # Host
    if [[ $line =~ /host=\"([^\"]+)\" ]]; then
        HOST="${BASH_REMATCH[1]}"
        [[ -z "$HOST" ]] && HOST="NA"
    fi

    # Country / Geographic location
    if [[ $line =~ /geographic\ location=\"([^\"]+)\" ]]; then
        COUNTRY="${BASH_REMATCH[1]}"
        [[ -z "$COUNTRY" ]] && COUNTRY="NA"
    fi

    # Write line when RUN is available
    if [[ -n $RUN ]]; then
        echo -e "${COUNTRY}\t${RUN}\t${DATE}\t${HOST}" >> "$OUTPUT_FILE"

        # Reset variables for next sample
        RUN=""
        DATE=""
        HOST=""
        COUNTRY=""
    fi
done < "$INPUT_FILE"

echo "✅ Done. Parsed metadata written to: $OUTPUT_FILE"