#!/bin/bash
#SBATCH --job-name=TB_Profiler_USA_BOVIS
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=40GB
#SBATCH --time=48:00:00
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=nf26742@uga.edu

# Load module
module load TB-Profiler/6.6.5

# Directory containing FASTQs
FASTQDIR=/scratch/nf26742/USA_Bovis_Human
OUTDIR=/scratch/nf26742/USA_Bovis_Human/results_3

mkdir -p $OUTDIR

cd $FASTQDIR

# Loop over all _1.fastq.gz files
for fq1 in *_1.fastq.gz; do
    # Infer _2 file
    fq2="${fq1/_1.fastq.gz/_2.fastq.gz}"
    
    # Generate a prefix based on the sample name
    prefix="${fq1%%_1.fastq.gz}"
    
    echo "Processing $prefix ..."
    
    tb-profiler profile -1 "$fq1" -2 "$fq2" -o "$OUTDIR" -t 4 -p "$prefix"
done

# Collate results at the end
cd $OUTDIR
tb-profiler collate
