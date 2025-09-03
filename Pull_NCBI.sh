#!/bin/bash
#SBATCH --job-name=Italy_cattle      # Job name
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
OUTDIR="/scratch/nf26742/Wildlife_Bovis/Italy_Cattle"

# Create output directory if it doesn't exist
mkdir -p "$OUTDIR"

# Load SRA tools
module load SRA-Toolkit/3.0.3-gompi-2022a

# List of SRR accessions
accessions=(
ERR12976097  
ERR12976107  
ERR12976116  
ERR12976126  
ERR12976143  
ERR12976150  
ERR12976156  
ERR12976160  
ERR12976162  
ERR12976171  
ERR12976149  
ERR12976158  
ERR12976159  
ERR12976161  
ERR12976172  
ERR12976099  
ERR12976102  
ERR12976106  
ERR12976108  
ERR12976110  
ERR12976111  
ERR12976117  
ERR12976119  
ERR12976120  
ERR12976123  
ERR12976134  
ERR12976139  
ERR12976098  
ERR12976100  
ERR12976122  
ERR12976127  
ERR12976129  
ERR12976132  
ERR12976140  
ERR12976144  
ERR12976155  
ERR12976165  
ERR12976169  
ERR12976173  
ERR12976101  
ERR12976112  
ERR12976114  
ERR12976118  
ERR12976125  
ERR12976128  
ERR12976133  
ERR12976136  
ERR12976137  
ERR12976148  
ERR12976153  
ERR12976154  
ERR12976163  
ERR12976164  
ERR12976109  
ERR12976124  
ERR12976142  
ERR12976145  
ERR12976146  
ERR12976147  
ERR12976151  
ERR12976152  
ERR12976166  
ERR12976170  
ERR12976174  
ERR12976175  
ERR6358029  
ERR6358030  
ERR12976105  
ERR12976141  
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
