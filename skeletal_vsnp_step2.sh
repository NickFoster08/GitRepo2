#!/bin/bash
#SBATCH --job-name=VSNP_STEP2        # Job name
#SBATCH --partition=batch             # Partition (queue) name
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --cpus-per-task=8       #number of cores per task
#SBATCH --mem=150gb                   # Job memory request
#SBATCH --time=07-0:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)

set -euo pipefail

STEP1_DIR="/scratch/nf26742/rerun_2025/job_50148622"
STEP2_DIR="/scratch/nf26742/rerun_2025/step2_${SLURM_JOB_ID}"
REFERENCE="/home/nf26742/vsnp3_test_dataset/vsnp_dependencies/Mycobacterium_AF2122"

module load vSNP3/3.31

mkdir -p "$STEP2_DIR"

# Gather one zero-coverage VCF per sample, renamed to the full sample name
shopt -s nullglob
n=0
for d in "$STEP1_DIR"/*/; do
    s=$(basename "$d")
    [[ -f "$d/.done" ]] || { echo "skipping $s (no .done)" >&2; continue; }
    for v in "$d"alignment_*/*_zc.vcf; do
        cp "$v" "$STEP2_DIR/${s}_zc.vcf"
        n=$((n+1))
    done
done
echo "Collected $n VCFs"
if [[ "$n" -ne 496 ]]; then
    echo "WARNING: expected 496 VCFs, found $n" >&2
fi

cd "$STEP2_DIR"
vsnp3_step2.py -a -t "$REFERENCE"