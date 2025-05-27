#!/bin/bash
#SBATCH --job-name=Bactopia_Bioproject        # Job name
#SBATCH --partition=batch             # Partition (queue) name
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --cpus-per-task=4             #number of cores per task
#SBATCH --mem=40gb                     # Job memory request
#SBATCH --time=02-00:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)

set -euo pipefail

# Set output directory variable
OUTDIR="/scratch/nf26742/rerun_2025/job_${SLURM_JOB_ID}"

# Make output directory if it doesn't exist
mkdir -p "$OUTDIR"

# Load modules
module load Bactopia/3.1.0

# Move to working directory
cd "$OUTDIR"

# Prepare FOFN
bactopia prepare \
  --path /home/nf26742/All_Seqs/All_Renamed \
  --fastq-ext .fastq \
 --pe1-pattern _1.fastq \
 --pe2-pattern _2.fastq \
  --species "Mycobacterium bovis" \
  --genome-size 4400000 \
  > $OUTDIR/samples.txt
  
# Run Bactopia
bactopia \
 --samples $OUTDIR/samples.txt \
 --coverage 100 \
 --outdir $OUTDIR/local-multiple-samples \
 --max_cpus 4 \
 --outdir "$OUTDIR"
# test