#!/bin/bash
#SBATCH --job-name=Bactopia_Step3_SNIPPY      # Job name
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

REFERENCE=/home/nf26742/vsnp3_test_dataset/vsnp_dependencies/Mycobacterium_AF2122

OUTDIR=/scratch/nf26742/rerun_2025/job_37864473

#Tells the program to make the ourdir folder if it cant find it
if [ ! -d $OUTDIR ] 
then
    mkdir -p $OUTDIR
fi

#Load modules
module load snpEff/5.0e-GCCcore-11.3.0-Java-11
module load java-11


#move to workdir
cd $OUTDIR

# ---- INPUTS ----
VCF_INPUT="/scratch/nf26742/rerun_2025/job_37864473/bactopia-runs/snippy-20250612-134408/snippy-core/core-snp.vcf"
GENOME_NAME="AF2122"

# ---- OUTPUTS ----
ANNOTATED_VCF="$OUTDIR/core-snp.ann.vcf"
STATS_HTML="$OUTDIR/snpeff_summary.html"

# ---- RUN SNPEFF ----
java -Xmx16g -jar $EBROOTSNPEFF/snpEff.jar \
    -v -stats $STATS_HTML \
    $GENOME_NAME $VCF_INPUT > $ANNOTATED_VCF

