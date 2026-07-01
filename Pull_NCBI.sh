#!/bin/bash
#SBATCH --job-name=USA_CDC_Bov      # Job name
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
SRR31781513
SRR31781514
SRR31781515
SRR31781516
SRR31781517
SRR31781518
SRR31781519
SRR31781520
SRR31781521
SRR31781522
SRR31781523
SRR31781524
SRR31781525
SRR31781526
SRR31781527
SRR31781528
SRR31781529
SRR31781530
SRR31781531
SRR31781532
SRR31781533
SRR31781534
SRR31781535
SRR31781536
SRR31781537
SRR31781538
SRR31781539
SRR31781540
SRR31781541
SRR31781542
SRR31781543
SRR31781544
SRR31781545
SRR31781546
SRR31781547
SRR31781548
SRR31781549
SRR31781550
SRR31781551
SRR31781552
SRR31781553
SRR31781554
SRR31781555
SRR31781556
SRR31781557
SRR31781558
SRR31781559
SRR31781560
SRR31781561
SRR31781562
SRR31781563
SRR31781564
SRR31781565
SRR31781566
SRR31781567
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
