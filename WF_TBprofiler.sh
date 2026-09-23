#!/bin/bash
#SBATCH --job-name=WF_TBProf_Euro_Afr_Bovis        # Job name
#SBATCH --partition=highmem_p            # Partition (queue) name
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --cpus-per-task=16       #number of cores per task
#SBATCH --mem=200gb                   # Job memory request
#SBATCH --time=7-0:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)
#Specify outdir

#Exit on error immediatley 
set -e

OUTDIR=/scratch/nf26742/rerun_2025/job_47709570

#Tells the program to make the ourdir folder if it cant find it
if [ ! -d $OUTDIR ] 
then
    mkdir -p $OUTDIR
fi

#find the stupuid library plz
export LD_LIBRARY_PATH=/apps/eb/Bactopia/3.2.0-conda/lib:$LD_LIBRARY_PATH

#Load modules
module load Bactopia/3.2.0-conda

#move to workdir
cd $OUTDIR

#Bactopia tools
bactopia \
    --wf tbprofiler \
    --exclude $OUTDIR/bactopia-exclude.tsv \
    --bactopia $OUTDIR
