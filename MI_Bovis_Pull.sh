#!/bin/bash
#SBATCH --job-name=MI_bovis      # Job name
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
OUTDIR="/scratch/nf26742/MI_Bovis"

# Create output directory if it doesn't exist
mkdir -p "$OUTDIR"

# Load SRA tools
module load SRA-Toolkit/3.0.3-gompi-2022a

# List of SRR accessions
accessions=(
SAMN04386755
SAMN04386752
SAMN04386751
SAMN04386750
SAMN04386749
SAMN04386748
SAMN04386747
SAMN04386746
SAMN04386745
SAMN04386744
SAMN04386743
SAMN04386742
SAMN04386741
SAMN04386740
SAMN04386739
SAMN04386738
SAMN04386737
SAMN04386736
SAMN04386735
SAMN04386734
SAMN04386733
SAMN04386732
SAMN04386731
SAMN04386730
SAMN04386729
SAMN04386754
SAMN04386753
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
