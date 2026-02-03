#!/bin/bash
#SBATCH --job-name=VSNP_STEP1_USA        # Job name
#SBATCH --partition=batch             # Partition (queue) name
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --cpus-per-task=4             #number of cores per task
#SBATCH --mem=40GB                     # Job memory request
#SBATCH --time=04-00:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)

set -euo pipefail

OUTDIR="/scratch/nf26742/rerun_2025/job_${SLURM_JOB_ID}"
REFERENCE="/home/nf26742/vsnp3_test_dataset/vsnp_dependencies/Mycobacterium_AF2122"
FASTQ_DIR="/scratch/nf26742/USA_Bovis_Human"

module load vSNP3/3.31

mkdir -p "$OUTDIR"
cd "$FASTQ_DIR"

shopt -s nullglob

R1_FILES=(*_1.fastq.gz)

if (( ${#R1_FILES[@]} == 0 )); then
    echo "Error: No R1 FASTQ files found in $FASTQ_DIR"
    exit 1
fi

for R1 in "${R1_FILES[@]}"; do
    R2="${R1/_1.fastq.gz/_2.fastq.gz}"

    if [[ ! -f "$R2" ]]; then
        echo "Error: Missing R2 for $R1"
        exit 1
    fi

    SAMPLE=$(basename "$R1" _1.fastq.gz)
    SAMPLE_OUTDIR="$OUTDIR/$SAMPLE"

    echo "Processing sample: $SAMPLE"

    mkdir -p "$SAMPLE_OUTDIR"

    vsnp3_step1.py \
        -r1 "$R1" \
        -r2 "$R2" \
        -t "$REFERENCE" \
        -o "$SAMPLE_OUTDIR" \
        --spoligo
done

echo "All samples processed successfully."
