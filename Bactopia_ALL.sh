#!/bin/bash
#SBATCH --job-name=Bactopia_Euro_Afr_Bovis        # Job name
#SBATCH --partition=batch             # Partition (queue) name
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --cpus-per-task=12       #number of cores per task
#SBATCH --mem=120GB                     # Job memory request
#SBATCH --time=07-0:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)

# "job_${SLURM_JOB_ID}" for future runs, job ID autofill
# Set output directory variable
OUTDIR="/scratch/nf26742/rerun_2025/job_47709570"

# Make output directory if it doesn't exist
mkdir -p "$OUTDIR"

# Load modules
module load Bactopia/3.2.0

# Move to working directory
cd "$OUTDIR"

# Only recreate samples.txt if necessary
if [ ! -f "$OUTDIR/samples.txt" ]; then
    bactopia prepare \
      --path /lustre2/scratch/nf26742/Mbovis_Africa_Europe \
      --species "Mycobacterium bovis" \
      --genome-size 4400000 \
      > "$OUTDIR/samples.txt"
fi
  
# Run Bactopia
bactopia \
 --samples $OUTDIR/samples.txt \
 --coverage 100 \
 --max_cpus 12 \
 --outdir "$OUTDIR" \
 -resume
