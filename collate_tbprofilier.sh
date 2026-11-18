#!/bin/bash
#SBATCH --job-name=tbp_collate
#SBATCH --partition=batch            # Partition (queue) name
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --cpus-per-task=1      #number of cores per task
#SBATCH --mem=10gb                   # Job memory request
#SBATCH --time=04:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)

module load TB-Profiler/6.6.5
cd /scratch/nf26742/Mbovis_Africa_Europe/TBProfiler_All
tb-profiler collate --prefix ALL_Bovis --dir TBProfiler_ALL/results
