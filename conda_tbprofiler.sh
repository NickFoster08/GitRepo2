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

#Exit on error immediatley 
set -e

# Directory containing FASTQs
FASTQDIR=/scratch/nf26742/Cattle_Wildlife_All

# Directory for TB-Profiler outputs
OUTDIR=/scratch/nf26742/Cattle_Wildlife_All/TBProfiler_results
mkdir -p $OUTDIR
cd $OUTDIR

# Activate TB-Profiler Conda environment
source /apps/eb/Bactopia/3.2.0-conda/etc/profile.d/conda.sh
conda activate tbprofiler

# Loop over all R1 FASTQs
for R1 in ${FASTQDIR}/*_R1.fastq.gz; do
    SAMPLE=$(basename $R1 _R1.fastq.gz)
    R2=${FASTQDIR}/${SAMPLE}_R2.fastq.gz

    # Skip if output already exists
    if [ -d "${OUTDIR}/${SAMPLE}" ]; then
        echo "Skipping $SAMPLE, output already exists."
        continue
    fi

    mkdir -p "${OUTDIR}/${SAMPLE}"

    # Run TB-Profiler
    tb-profiler profile \
        -1 $R1 \
        -2 $R2 \
        -p "${OUTDIR}/${SAMPLE}/${SAMPLE}" \
        --threads 4
done
