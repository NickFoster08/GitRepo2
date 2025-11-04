#!/bin/bash
#SBATCH --job-name=Bactopia_Step2_Bioproject        # Job name
#SBATCH --partition=batch             # Partition (queue) name
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --cpus-per-task=4             #number of cores per task
#SBATCH --mem=40GB                     # Job memory request
#SBATCH --time=04-00:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)

#Specify outdir
OUTDIR=/scratch/nf26742/Bactopia_Reports/run3

#Tells the program to make the ourdir folder if it cant find it
if [ ! -d $OUTDIR ] 
then
    mkdir -p $OUTDIR
fi

#Load Bactopia
module load Bactopia/3.2.0

#move to workdir
cd /scratch/nf26742/rerun_2025/job_41140111

#Create summary files from bactopia pipeline on samples
bactopia summary \
    --bactopia-path /scratch/nf26742/rerun_2025/job_41140111