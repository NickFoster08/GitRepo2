#!/bin/bash
#SBATCH --job-name=_Full_IQTREE_EUR_AFR_BOVIS     # Job name
#SBATCH --partition=batch_30d    # Partition (queue) name
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --cpus-per-task=32     #number of cores per task
#SBATCH --mem=500gb                  # Job memory request
#SBATCH --time=21-00:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)

set -e

OUTDIR=/scratch/nf26742/rerun_2025/job_48673716/bactopia-runs/snippy-20261002-131410/IQTree_NOREF

# Make sure the output directory exists
mkdir -p $OUTDIR

# Move to the folder containing the alignment
cd /scratch/nf26742/rerun_2025/job_48673716/bactopia-runs/snippy-20261002-131410

# Check that the cleaned alignment exists
if [ ! -f core-snp.no-reference.aln ]; then
    echo "Error: core-snp.no-reference.aln not found in this folder"
    exit 1
fi

# Load IQ-TREE module
module load IQ-TREE/3.0.1-gompi-2024a

# Run IQ-TREE with outputs going into the clean folder
iqtree3 \
 -s core-snp.no-reference.aln \
 -m MFP \
 -nt 32 \
 -pre "$OUTDIR/iqtree_noref"


