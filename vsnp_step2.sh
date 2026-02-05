#!/bin/bash
#SBATCH --job-name=vSNP_STEP2_USA        # Job name
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

BASE_OUTDIR="/scratch/nf26742/rerun_2025/job_${SLURM_JOB_ID}"

module load vSNP3/3.31

if [[ ! -d "$BASE_OUTDIR" ]]; then
    echo "Error: Step1 output directory not found: $BASE_OUTDIR"
    exit 1
fi

shopt -s nullglob

SAMPLE_DIRS=("$BASE_OUTDIR"/*)

if (( ${#SAMPLE_DIRS[@]} == 0 )); then
    echo "Error: No sample directories found in $BASE_OUTDIR"
    exit 1
fi

for SAMPLE_DIR in "${SAMPLE_DIRS[@]}"; do
    if [[ ! -d "$SAMPLE_DIR" ]]; then
        continue
    fi

    echo "Running step2 on: $(basename "$SAMPLE_DIR")"

    vsnp3_step2.py \
        -i "$SAMPLE_DIR"
done

echo "vSNP step2 completed for all samples."
