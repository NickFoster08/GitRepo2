#!/bin/bash
#SBATCH --job-name=vSNP_STEP2_AFREUR       # Job name
#SBATCH --partition=batch             # Partition (queue) name
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --cpus-per-task=4             #number of cores per task
#SBATCH --mem=300GB                     # Job memory request
#SBATCH --time=04-00:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)

set -euo pipefail

VCF_DIR="/scratch/nf26742/rerun_2025/job_49689386"

module load vSNP3/3.31

if [[ ! -d "$VCF_DIR" ]]; then
    echo "Error: VCF directory not found: $VCF_DIR"
    exit 1
fi

cd "$VCF_DIR"
vsnp3_step2.py -a -t Mycobacterium_AF2122

echo "vSNP step2 completed."