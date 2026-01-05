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

module load TB-Profiler/6.6.5

FASTQDIR=/scratch/nf26742/USA_Bovis_Human
OUTDIR=/scratch/nf26742/USA_Bovis_Human/TBProfiler_results

mkdir -p "$OUTDIR"
cd "$FASTQDIR" || exit 1

for fq1 in *_1.fastq.gz; do
    fq2="${fq1/_1.fastq.gz/_2.fastq.gz}"

    if [[ ! -f "$fq2" ]]; then
        echo "Skipping $fq1 (missing pair)" >&2
        continue
    fi

    prefix="${fq1%%_1.fastq.gz}"

    echo "Processing $prefix"

    tb-profiler profile \
        -1 "$fq1" \
        -2 "$fq2" \
        -t 4 \
        -p "$prefix" \
        --outdir "$OUTDIR"
done

cd "$FASTQDIR" || exit 1

tb-profiler collate \
  --dir TBProfiler_results \
  --prefix USA_Bovis_Human
