#!/bin/bash
#SBATCH --job-name=TB_Profiler_Conda_USA_BOVIS     # Job name
#SBATCH --partition=batch             # Partition (queue) name
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --cpus-per-task=4             #number of cores per task
#SBATCH --mem=40GB                     # Job memory request
#SBATCH --time=07-00:00:00               # Time limit hrs:min:sec
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
FASTQDIR=/scratch/nf26742/USA_Bovis_Human
OUTDIR=/scratch/nf26742/USA_Bovis_Human/TBProfiler_results_2
mkdir -p "$OUTDIR"

# Log file for skipped samples
SKIP_LOG="${OUTDIR}/skipped_samples.log"
echo "Skipped samples log - $(date)" > "$SKIP_LOG"

# Loop over all _1.fastq.gz files
for R1 in "${FASTQDIR}"/*_1.fastq.gz; do
    # Dynamically determine R2 by replacing _1 with _2
    R2="${R1/_1.fastq.gz/_2.fastq.gz}"
    
    # Extract a sample name for output dir (everything before _1.fastq.gz)
    SAMPLE="${R1##*/}"        # strip path
    SAMPLE="${SAMPLE%_1.fastq.gz}"

    SAMPLE_OUTDIR="${OUTDIR}/${SAMPLE}"

    # Check if R2 exists
    if [ ! -f "$R2" ]; then
        echo "$SAMPLE: missing R2 file" | tee -a "$SKIP_LOG"
        continue
    fi

    # Skip if output already exists
    if [ -d "$SAMPLE_OUTDIR" ]; then
        echo "$SAMPLE: output already exists" | tee -a "$SKIP_LOG"
        continue
    fi

    mkdir -p "$SAMPLE_OUTDIR"
    
    cd "$SAMPLE_OUTDIR"
    tb-profiler profile \
        -1 "$R1" \
        -2 "$R2" \
        -p "$SAMPLE" \
        --threads 4

    cd "$OUTDIR"
done

#Collate
tb-profiler collate --data-dir "$OUTDIR"