#!/bin/bash
#SBATCH --job-name=GZ_All       # Job name
#SBATCH --partition=batch                  # Partition (queue) name
#SBATCH --ntasks=1                         # Run on a single CPU
#SBATCH --cpus-per-task=8                  # Number of cores per task
#SBATCH --mem=80gb                         # Job memory request
#SBATCH --time=00-12:00:00                 # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out  # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err   # Standard error log
#SBATCH --mail-type=END,FAIL               # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu        # Where to send mail

module load  pigz/2.8-GCCcore-13.3.0

cd /scratch/nf26742/MI_Bovis_Any

# Gzip only uncompressed .fastq files
for f in *.fastq; do
    [ -f "$f" ] && pigz -p 8 "$f"
done
