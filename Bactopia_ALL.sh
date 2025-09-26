#!/bin/bash
#SBATCH --job-name=Bactopia_Bioproject        # Job name
#SBATCH --partition=batch             # Partition (queue) name
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --cpus-per-task=4             #number of cores per task
#SBATCH --mem=40GB                     # Job memory request
#SBATCH --time=04-00:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)


# Set output directory variable
OUTDIR="/scratch/nf26742/rerun_2025/job_${SLURM_JOB_ID}"

# Make output directory if it doesn't exist
mkdir -p "$OUTDIR"

# Load modules
module load Bactopia/3.2.0

# Move to working directory
cd "$OUTDIR"sq

# Prepare FOFN
bactopia prepare \
  --path /scratch/nf26742/Cattle_Wildlife_All\
  --species "Mycobacterium bovis" \
  --genome-size 4400000 \
  > $OUTDIR/samples.txt
  
# Run Bactopia
bactopia \
 --samples $OUTDIR/samples.txt \
 --coverage 100 \
 --max_cpus 4 \
 --outdir "$OUTDIR"
