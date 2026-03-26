#!/bin/bash
#SBATCH --job-name=Bactopia_USA_Human_Bovis
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=40GB
#SBATCH --time=07-00:00:00
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=nf26742@uga.edu

# Load modules
module load Bactopia/3.2.0

# Move to working directory
cd /scratch/nf26742/rerun_2025

# Prepare FOFN (only needed once; can reuse samples.txt)
bactopia prepare \
  --path /lustre2/scratch/nf26742/Mex_USA_Animal_Bovis \
  --species "Mycobacterium bovis" \
  --genome-size 4400000 \
  > samples.txt

# Run Bactopia with SLURM profile and resume previous run
bactopia \
  --samples samples.txt \
  --coverage 100 \
  --outdir ./bactopia_output \
  -profile slurm \
  -resume
