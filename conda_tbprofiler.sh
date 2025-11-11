#!/bin/bash
#SBATCH --job-name=TB_Profiler_Conda      # Job name
#SBATCH --partition=batch             # Partition (queue) name
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --cpus-per-task=4             #number of cores per task
#SBATCH --mem=40GB                     # Job memory request
#SBATCH --time=04-00:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)

# Exit on error immediately
set -e

# Load TB Profiler module (optional if Conda already has it)
module load TB-Profiler/6.6.5

# Activate TB-Profiler Conda environment
source /apps/eb/Bactopia/3.2.0-conda/etc/profile.d/conda.sh
conda activate tb-profiler-env

# Directories
FASTQDIR=/scratch/nf26742/Cattle_Wildlife_All
OUTDIR=/scratch/nf26742/Cattle_Wildlife_All/TBProfiler_results
mkdir -p "$OUTDIR"

# Log file for skipped samples
SKIP_LOG="${OUTDIR}/skipped_samples.log"
echo "Skipped samples log - $(date)" > "$SKIP_LOG"

# Loop over all R1 FASTQs
for R1 in "${FASTQDIR}"/*_R1.fastq.gz; do
    SAMPLE=$(basename "$R1" _R1.fastq.gz)
    R2="${FASTQDIR}/${SAMPLE}_R2.fastq.gz"
    SAMPLE_OUTDIR="${OUTDIR}/${SAMPLE}"

    # Check if R2 exists
    if [ ! -f "$R2" ]; then
        echo "$SAMPLE: missing R2 file" | tee -a "$SKIP_LOG"
        continue
    fi

    # Check if output already exists
    if [ -d "$SAMPLE_OUTDIR" ]; then
        echo "$SAMPLE: output already exists" | tee -a "$SKIP_LOG"
        continue
    fi

    # Create output directory
    mkdir -p "$SAMPLE_OUTDIR"
    
    # Run TB-Profiler inside sample output directory
    cd "$SAMPLE_OUTDIR"
    tb-profiler profile \
        -1 "$R1" \
        -2 "$R2" \
        -p "$SAMPLE" \
        --threads 4

    # Return to main OUTDIR
    cd "$OUTDIR"
done