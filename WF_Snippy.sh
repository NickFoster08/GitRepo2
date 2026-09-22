#!/bin/bash
#SBATCH --job-name=WF_Snippy_Euro_Afr_Bovis        # Job name
#SBATCH --partition=batch_30d             # Partition (queue) name
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --cpus-per-task=16       #number of cores per task
#SBATCH --mem=300gb                   # Job memory request
#SBATCH --time=14-0:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)
#Specify outdir

#Exit on error immediatley 
set -e

REFERENCE=/home/nf26742/vsnp3_test_dataset/vsnp_dependencies/Mycobacterium_AF2122

OUTDIR=/scratch/nf26742/rerun_2025/job_47709570/bactopia-runs/snippy-20260914-163539

#Tells the program to make the ourdir folder if it cant find it
if [ ! -d $OUTDIR ] 
then
    mkdir -p $OUTDIR
fi

#Load modules
module load Java/17.0.6
module load Bactopia/3.2.0

#move to workdir
cd $OUTDIR

#Bactopia tools
bactopia \
    --wf snippy \
    --reference $REFERENCE/NC_002945v4.gbk \
    --exclude $OUTDIR/bactopia-exclude.tsv \
    --bactopia $OUTDIR \
    -resume