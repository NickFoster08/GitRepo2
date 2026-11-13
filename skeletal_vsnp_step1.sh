#!/bin/bash
#SBATCH --job-name=VSNP_STEP1        # Job name
#SBATCH --partition=batch            # Partition (queue) name
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --cpus-per-task=4      #number of cores per task
#SBATCH --mem=200gb                   # Job memory request
#SBATCH --time=07-0:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)


set -euo pipefail

OUTDIR="/scratch/nf26742/rerun_2025/job_${SLURM_JOB_ID}"
REFERENCE="/home/nf26742/vsnp3_test_dataset/vsnp_dependencies/Mycobacterium_AF2122"

module load vSNP3/3.31

cd /scratch/nf26742/rerun_2025/job_47709570/PDA_Select_Genomes

vsnp3_step1.py \
    -r1 *_1.fastq.gz \
    -r2 *_2.fastq.gz \
    -t "$REFERENCE" \
    -o "$OUTDIR" \
    --spoligo