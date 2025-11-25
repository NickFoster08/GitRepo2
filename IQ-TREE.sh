#!/bin/bash
#SBATCH --job-name=IQTREE_USA_BOVIS     # Job name
#SBATCH --partition=batch             # Partition (queue) name
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --cpus-per-task=4             #number of cores per task
#SBATCH --mem=40GB                     # Job memory request
#SBATCH --time=07-00:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)

set -e

OUTDIR=/scratch/nf26742/rerun_2025/job_41187889/bactopia-runs/snippy-20251121-145859/iqtree_noRef

# Make sure the output directory exists
mkdir -p $OUTDIR

# Move to the folder containing the alignment
cd /scratch/nf26742/rerun_2025/job_41187889/bactopia-runs/snippy-20251121-145859/

# Check that the cleaned alignment exists
if [ ! -f core-snp.no_ref.fasta ]; then
    echo "Error: core-snp.no_ref.fasta not found in this folder"
    exit 1
fi

# Load IQ-TREE module
module load IQ-TREE/3.0.1-gompi-2024a

# Run IQ-TREE with outputs going into the clean folder
iqtree3 -s core-snp.no_ref.fasta -st BINARY -m MK+F -bb 1000 -nt AUTO -pre $OUTDIR/iqtree_run