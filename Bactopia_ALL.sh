#!/bin/bash
#SBATCH --job-name=All_Country_Bactopia
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=40gb
#SBATCH --time=02-00:00:00
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=nf26742@uga.edu

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
  --pe1-pattern '_1.fastq' \
  --pe2-pattern '_2.fastq' \
  --species "Mycobacterium bovis" \
  --genome-size 4400000 \
  --output prepare_output

# Run Bactopia
bactopia \
  --samples prepare_output/samples.csv \
  --coverage 100 \
  --max_cpus 4 \
  --outdir "$OUTDIR"
