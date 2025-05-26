#!/bin/bash
#SBATCH --job-name=All_Country_Bactopia        # Job name
#SBATCH --partition=batch                       # Partition (queue) name
#SBATCH --ntasks=1                              # Run on a single CPU task
#SBATCH --cpus-per-task=4                       # Number of cores per task
#SBATCH --mem=40gb                              # Job memory request
#SBATCH --time=02-00:00:00                      # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log
#SBATCH --mail-type=END,FAIL                     # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu              # Where to send mail

set -euo pipefail

# Set output directory variable
OUTDIR="/scratch/nf26742/rerun_2025/job_${SLURM_JOB_ID}"

# Make output directory if it doesn't exist
if [ ! -d "$OUTDIR" ]; then
    mkdir -p "$OUTDIR"
fi

# Load modules
module load Bactopia/3.1.0

# Move to working directory
cd "$OUTDIR"

# Prepare FOFN
bactopia prepare \
  --path /home/nf26742/All_Seqs/All_Renamed \
  --species "Mycobacterium bovis" \
  --genome-size 4400000 \
  > All.Country.Samples.txt

# Run Bactopia
bactopia \
  --samples All.Country.Samples.txt \
  --coverage 100 \
  --max_cpus 4 \
  --outdir "$OUTDIR"
