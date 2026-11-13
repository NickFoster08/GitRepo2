#!/bin/bash
#SBATCH --job-name=VSNP_STEP1        # Job name
#SBATCH --partition=batch            # Partition (queue) name
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --cpus-per-task=8      #number of cores per task
#SBATCH --mem=100gb                   # Job memory request
#SBATCH --time=07-0:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)


set -euo pipefail

OUTDIR="/scratch/nf26742/rerun_2025/job_${SLURM_JOB_ID}"
REFERENCE="/home/nf26742/vsnp3_test_dataset/vsnp_dependencies/Mycobacterium_AF2122"
READDIR="/scratch/nf26742/rerun_2025/job_47709570/PDA_Select_Genomes"
GBK_file="/home/nf26742/vsnp3_test_dataset/vsnp_dependencies/Mycobacterium_AF2122/NC_002945v4.gbk"

module load vSNP3/3.31

mkdir -p "$OUTDIR"
cd "$READDIR"

for r1 in *_1.fastq.gz; do
    r2="${r1/_1.fastq.gz/_2.fastq.gz}"
    sample="${r1%_1.fastq.gz}"

    # Skip if R2 is missing
    if [[ ! -f "$r2" ]]; then
        echo "MISSING R2: $sample" >> "$OUTDIR/failed_samples.txt"
        continue
    fi

    # Skip samples already finished (lets you resume after a timeout)
    if [[ -f "$OUTDIR/$sample/.done" ]]; then
        continue
    fi

    mkdir -p "$OUTDIR/$sample"

    echo "$(date): starting $sample"
    if vsnp3_step1.py \
        -r1 "$r1" \
        -r2 "$r2" \
        -n "$sample" \
        -b "$GBK_file" \
        -t "$REFERENCE" \
        -o "$OUTDIR/$sample" \
        --spoligo; then
        touch "$OUTDIR/$sample/.done"
        echo "$(date): finished $sample"
    else
        echo "FAILED: $sample" >> "$OUTDIR/failed_samples.txt"
    fi
done