#!/bin/bash
#SBATCH --job-name=Force_tbprofiler_Med_Bovis
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=300GB
#SBATCH --time=07:00:00
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=nf26742@uga.edu

module load TB-Profiler/6.6.5

FASTQDIR=/scratch/nf26742/rerun_2025/job_47709570/PDA_Select_Genomes
OUTBASE=/scratch/nf26742/rerun_2025/job_48673716/bactopia-runs

cd "$OUTBASE" || exit 1

mkdir -p TBProfiler_results
cd TBProfiler_results3 || exit 1

for fq1 in "$FASTQDIR"/*_1.fastq.gz; do
    fq2="${fq1/_1.fastq.gz/_2.fastq.gz}"

    if [[ ! -f "$fq2" ]]; then
        echo "Skipping $(basename "$fq1") (missing pair)" >&2
        continue
    fi

    prefix=$(basename "${fq1%%_1.fastq.gz}")

    echo "Processing $prefix"

    tb-profiler profile \
        -1 "$fq1" \
        -2 "$fq2" \
        -t 4 \
        -p "$prefix" \
        --spoligotype
done

cd "$OUTBASE" || exit 1

tb-profiler collate \
  --dir TBProfiler_results \
  --prefix PDA_Med_Bovis
