#!/bin/bash
#SBATCH --job-name=NCBI_Download_SRR_Accession      # Job name
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
OUTDIR="/lustre2/scratch/nf26742/Mbovis_Africa_Europe"

# Create output directory if it doesn't exist
mkdir -p "$OUTDIR"

# Load SRA tools
module load SRA-Toolkit/3.0.3-gompi-2022a

# List of SRR accessions
accessions=(
SRR13986556
SRR13986557
SRR13986558
SRR13986559
SRR13986560
SRR13986561
SRR13986562
SRR13986563
SRR13986564
SRR13986565
SRR13986566
SRR13986567
SRR13986568
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
