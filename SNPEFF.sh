#!/bin/bash
#SBATCH --job-name=SNPEFF_USA_BOVIS
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=40GB
#SBATCH --time=04-00:00:00
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=nf26742@uga.edu

# Exit on error, undefined variables, or failed pipes
set -euo pipefail

# -----------------------------
# Paths
# -----------------------------
OUTDIR=/scratch/nf26742/rerun_2025/job_41187889
VCF_INPUT="$OUTDIR/bactopia-runs/snippy-20251201-150604/snippy-core/core-snp.vcf"
GENOME_NAME="AF2122"

CLEAN_VCF="$OUTDIR/core-snp.snpeff_ready.vcf"
VCF_FIXED="$OUTDIR/core-snp.fixed3.vcf"
ANNOTATED_VCF="$OUTDIR/core-snp.ann3.vcf"
STATS_HTML="$OUTDIR/snpeff_summary.html"

# -----------------------------
# Prepare output directory
# -----------------------------
mkdir -p "$OUTDIR"

# -----------------------------
# Load modules
# -----------------------------
module purge
module load snpEff/5.2c-GCCcore-12.3.0-Java-11
module load Java/11.0.20

# -----------------------------
# Check input file
# -----------------------------
[ -f "$VCF_INPUT" ] || { echo "ERROR: Input VCF not found: $VCF_INPUT"; exit 1; }

cd "$OUTDIR"

# -----------------------------
# Step 1: Keep only simple SNPs
# -----------------------------
awk 'BEGIN {OFS="\t"} 
    /^#/ {print; next} 
    length($4)==1 && length($5)==1 && $5 ~ /^[ACGT]$/ {print}' \
    "$VCF_INPUT" > "$CLEAN_VCF"

# -----------------------------
# Step 2: Fix chromosome names for snpEff
# -----------------------------
# Replace header contig lines
sed -i 's/^##contig=<ID=1,/##contig=<ID=NC_002945.4,/' "$CLEAN_VCF"

# Force chromosome in all variant lines to match snpEff database
awk 'BEGIN{OFS="\t"} 
    /^#/ {print; next} 
    {$1="NC_002945.4"; print}' "$CLEAN_VCF" > "$VCF_FIXED"

# Quick check (optional)
echo "Unique chromosomes in fixed VCF:"
cut -f1 "$VCF_FIXED" | sort | uniq

# -----------------------------
# Step 3: Run snpEff annotation
# -----------------------------
java -Xmx16G -jar /home/nf26742/SNPEFF_DataBase/snpEff/snpEff.jar \
    -c /home/nf26742/SNPEFF_DataBase/snpEff/snpEff.config \
    -v -stats "$STATS_HTML" \
    "$GENOME_NAME" "$VCF_FIXED" > "$ANNOTATED_VCF"

echo "snpEff annotation completed successfully!"
