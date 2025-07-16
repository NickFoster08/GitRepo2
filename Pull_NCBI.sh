#!/bin/bash
#SBATCH --job-name=Ehtiopia_Cattle      # Job name
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
OUTDIR="/scratch/nf26742/Wildlife_Bovis/Ethiopia_Cattle"

# Create output directory if it doesn't exist
mkdir -p "$OUTDIR"

# Load SRA tools
module load SRA-Toolkit/3.0.3-gompi-2022a

# List of SRR accessions
accessions=(
SRR29318480
SRR29318481
SRR29318482
SRR29318483
SRR29318484
SRR29318489
SRR29318490
ERR3458080
ERR3458081
ERR3458082
ERR3458083
ERR3458084
ERR3458085
ERR3458086
SRR8063651
SRR8063652
SRR8063653
SRR8063654
SRR8063655
SRR8063656
SRR8063657
SRR8063658
SRR8063659
SRR8063660
SRR8063661
SRR8063662
SRR8063663
SRR8063664
SRR8063665
SRR8063666
SRR5486071
SRR5486072
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
