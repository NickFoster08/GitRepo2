#!/bin/bash
#SBATCH --job-name=Italy_WL      # Job name
#SBATCH --partition=batch                # Partition (queue) name
#SBATCH --ntasks=1                       # Run on a single CPU
#SBATCH --cpus-per-task=8                # Number of cores per task
#SBATCH --mem=80gb                       # Job memory request
#SBATCH --time=00-12:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out  # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err   # Standard error log

#SBATCH --mail-type=END,FAIL             # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu      # Where to send mail

# Specify output directory
OUTDIR="/scratch/nf26742/Wildlife_Bovis/Italy_WL"

# Create output directory if it doesn't exist
mkdir -p "$OUTDIR"

# Load SRA tools
module load SRA-Toolkit/3.0.3-gompi-2022a

# List of SRR accessions
accessions=(
ERR12976115
ERR12976121
ERR12976113
ERR12976157
ERR12976168
ERR12976103
ERR12976104
ERR12976131
ERR12976130
ERR12976135
SRR3085259
SRR7131025
SRR7131117
ERR12976138
ERR12976167
)

for srr in "${accessions[@]}"; do
    echo "🔄 Downloading $srr from NCBI"

    fasterq-dump "$srr" -O "$OUTDIR" --threads 8
    if [[ $? -eq 0 ]]; then
        echo "✅ Successfully downloaded and converted $srr"
    else
        echo "⚠️  NCBI failed"
    fi
done
