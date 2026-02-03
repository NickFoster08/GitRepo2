#!/bin/bash
#SBATCH --job-name=VSNP_USA      # Job name
#SBATCH --partition=batch              # Partition (queue) name
#SBATCH --ntasks=1                     # Run on a single CPU
#SBATCH --cpus-per-task=8              # Number of cores per task
#SBATCH --mem=40gb                     # Job memory request
#SBATCH --time=02-00:00:00             # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out  # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err   # Standard error log

#SBATCH --mail-type=END,FAIL           # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu    # Where to send mail

set -x
set -euo pipefail  # Enable strict error handling

# Define output directory for step 1 results
OUTDIR="/scratch/nf26742/rerun_2025/job_${SLURM_JOB_ID}"

# Create output directory if it doesn't exist
mkdir -p "$OUTDIR"

# Set reference genome variable
REFERENCE="/home/nf26742/vsnp3_test_dataset/vsnp_dependencies/Mycobacterium_AF2122"

# Load vsnp module
module load vSNP3/3.31|| { echo "Error: Failed to load vsnp3 module"; exit 1; }

# Navigate to the correct directory
cd "/scratch/nf26742/USA_Bovis_Human" || { echo "Error: Directory not found"; exit 1; } 

# Loop over each pair of R1 and R2 files
for r1_file in *_R1_001.fastq.gz; do
    # Generate the corresponding R2 file
    r2_file="${r1_file/_R1_001.fastq.gz/_R2_001.fastq.gz}"
    
    # Check if R2 file exists
    if [[ -f "$r2_file" && -s "$r1_file" && -s "$r2_file" ]]; then
        echo "Processing: $r1_file and $r2_file"

        # Ensure alignment directory exists
        ALIGNMENT_DIR="$OUTDIR/alignment_NC_002945v4"
        mkdir -p "$ALIGNMENT_DIR"

        # Remove the reference genome and index file inside the alignment directory to avoid conflicts
        REF_COPY="$ALIGNMENT_DIR/NC_002945v4.fasta"
        REF_INDEX="$ALIGNMENT_DIR/NC_002945v4.fasta.fai"

        if [ -f "$REF_COPY" ]; then
            echo "Removing existing reference genome: $REF_COPY"
            rm -f "$REF_COPY"
        fi

        if [ -f "$REF_INDEX" ]; then
            echo "Removing existing reference genome index: $REF_INDEX"
            rm -f "$REF_INDEX"
        fi

        # Remove the unmapped_reads directory if it exists to avoid shutil.move error
        UNMAPPED_DIR="$ALIGNMENT_DIR/unmapped_reads"
        if [ -d "$UNMAPPED_DIR" ]; then
            echo "Removing existing directory: $UNMAPPED_DIR"
            rm -rf "$UNMAPPED_DIR"
        fi

        # Run vsnp3_step1.py for each pair of R1 and R2 files
        vsnp3_step1.py \
        -r1 "$r1_file" \
        -r2 "$r2_file" \
        -t "$REFERENCE" \
        -o "$OUTDIR"
        - spoligo
        
        # Check if vSNP output is generated
        if [ ! -s "$OUTDIR/alignment_NC_002945v4/${r1_file%%_1.fastq}_zc.vcf" ]; then
            echo "Warning: No vSNP output for $r1_file and $r2_file" | tee -a "$OUTDIR/vsnp_errors.log"
        fi
    else
        echo "Warning: Missing or empty files for $r1_file, skipping..." | tee -a "$OUTDIR/vsnp_errors.log"
    fi
done

#/scratch/nf26742/USA_Bovis_Human is where human fastqs are