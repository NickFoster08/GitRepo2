#!/bin/bash
#SBATCH --job-name=SNPEFF      # Job name
#SBATCH --partition=batch             # Partition (queue) name
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --cpus-per-task=4             # number of cores per task
#SBATCH --mem=40GB                     # Job memory request
#SBATCH --time=04-00:00:00             # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu)

# Exit immediately on error
set -e

OUTDIR=/scratch/nf26742/rerun_2025/job_41138789

# Make output directory if it doesn't exist
if [ ! -d $OUTDIR ]; then
    mkdir -p $OUTDIR
fi

# Load modules
module load snpEff/5.0e-GCCcore-11.3.0-Java-11
module load Java/21.0.5

# Move to work directory
cd $OUTDIR

# ---- INPUTS ----
VCF_INPUT="/scratch/nf26742/rerun_2025/job_40647442/bactopia-runs/snippy-20250926-130656/gubbins/core-snp.summary_of_snp_distribution.vcf"
GENOME_NAME="AF2122"

# ---- OUTPUTS ----
CLEAN_VCF="$OUTDIR/core-snp.snpeff_ready.vcf"
VCF_FIXED="$OUTDIR/core-snp.fixed3.vcf"
ANNOTATED_VCF="$OUTDIR/core-snp.ann3.vcf"
STATS_HTML="$OUTDIR/snpeff_summary.html"

# Step 1: Clean VCF to keep only simple SNPs (no indels or complex alleles)
awk 'BEGIN {OFS="\t"} \
    /^#/ {print; next} \
    length($4)==1 && length($5)==1 && $5 ~ /^[ACGT]$/ {print}' \
    $VCF_INPUT > $CLEAN_VCF

# Step 2: Fix chromosome names in VCF header and variant lines to match snpEff database

# Replace contig header line "##contig=<ID=1,...>" with "##contig=<ID=NC_002945.4,...>"
sed 's/##contig=<ID=1,/##contig=<ID=NC_002945.4,/' $CLEAN_VCF | \
awk 'BEGIN{OFS="\t"} 
    /^#/ {print; next} 
    {if($1 == "1") $1 = "NC_002945.4"; print}' > $VCF_FIXED

# Step 3: Run snpEff annotation
java -Xmx16g -jar /home/nf26742/SNPEFF_DataBase/snpEff/snpEff.jar \
    -c /home/nf26742/SNPEFF_DataBase/snpEff/snpEff.config \
    -v -stats $STATS_HTML \
    $GENOME_NAME $VCF_FIXED > $ANNOTATED_VCF
