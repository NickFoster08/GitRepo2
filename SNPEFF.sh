#!/bin/bash
#SBATCH --job-name=SNPEFF      # Job name
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

OUTDIR=/scratch/nf26742/rerun_2025/job_37864473

#Tells the program to make the ourdir folder if it cant find it
if [ ! -d $OUTDIR ] 
then
    mkdir -p $OUTDIR
fi

#Load modules
module load snpEff/5.0e-GCCcore-11.3.0-Java-11
module load Java/21.0.5

#move to workdir
cd $OUTDIR

# ---- INPUTS ----
VCF_INPUT="/scratch/nf26742/rerun_2025/job_37864473/bactopia-runs/snippy-20250612-134408/snippy-core/core-snp.vcf"
GENOME_NAME="AF2122"

# ---- OUTPUTS ----
ANNOTATED_VCF="$OUTDIR/core-snp.ann.vcf"
STATS_HTML="$OUTDIR/snpeff_summary.html"

# Fix chromosome names in VCF to match SnpEff database
VCF_FIXED="$OUTDIR/core-snp.fixed.vcf"

awk 'BEGIN{OFS="\t"} 
    /^#/ {print; next} 
    {if($1 == "NC_002945") $1 = "NC_002945.4"; print}' \
    $VCF_INPUT > $VCF_FIXED

# ---- RUN SNPEFF ----
java -Xmx16g -jar /home/nf26742/SNPEFF_DataBase/snpEff/snpEff.jar \
    -c /home/nf26742/SNPEFF_DataBase/snpEff/snpEff.config \
    -v -stats $STATS_HTML \
 $GENOME_NAME $VCF_FIXED > $ANNOTATED_VCF



