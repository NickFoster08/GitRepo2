#!/bin/bash
#SBATCH --job-name=IQTREE_EUR_AFR_BOVIS     # Job name
#SBATCH --partition=highmem_30d_p           # Partition (queue) name
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --cpus-per-task=16       #number of cores per task
#SBATCH --mem=600gb                   # Job memory request
#SBATCH --time=07-00:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)

set -e

OUTDIR=/scratch/nf26742/rerun_2025/job_47709570/bactopia-runs/snippy-20260914-163539/iqtree

# Make sure the output directory exists
mkdir -p $OUTDIR

# Move to the folder containing the alignment
cd /scratch/nf26742/rerun_2025/job_47709570/bactopia-runs/snippy-20260914-163539/

# Check that the cleaned alignment exists
if [ ! -f core-snp-clean.full.aln ]; then
    echo "Error: core-snp-clean.full.aln not found in this folder"
    exit 1
fi

# Load IQ-TREE module
module load IQ-TREE/3.0.1-gompi-2024a

# Run IQ-TREE with outputs going into the clean folder
iqtree3 -s core-snp-clean.full.aln -m GTR -bb 1000 -nt 4 -pre $OUTDIR/iqtree_full


