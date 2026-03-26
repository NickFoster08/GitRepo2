#!/bin/bash
#SBATCH --job-name=parallel_bovis    # Job name
#SBATCH --partition=batch                       # Partition (queue) name
#SBATCH --ntasks=8                               # Number of parallel tasks (samples)
#SBATCH --cpus-per-task=4                        # CPUs per task
#SBATCH --mem=40GB                               # Memory per task
#SBATCH --time=07-00:00:00                       # Time limit (hh:mm:ss)
#SBATCH --output=/scratch/nf26742/rerun_2025/log.%j.out
#SBATCH --error=/scratch/nf26742/rerun_2025/log.%j.err

#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=nf26742@uga.edu

# Output directory
OUTDIR="/scratch/nf26742/rerun_2025/job_${SLURM_JOB_ID}"
mkdir -p "$OUTDIR"

# Load Bactopia module
module load Bactopia/3.2.0

# Move to output directory
cd "$OUTDIR"

# Prepare samples list (FOFN)
bactopia prepare \
  --path /lustre2/scratch/nf26742/Mex_USA_Animal_Bovis \
  --species "Mycobacterium bovis" \
  --genome-size 4400000 \
  > $OUTDIR/samples.txt

# Run Bactopia with Nextflow Slurm profile, resuming previous run
bactopia \
 --samples $OUTDIR/samples.txt \
 --coverage 100 \
 --outdir "$OUTDIR" \
 -profile slurm 
