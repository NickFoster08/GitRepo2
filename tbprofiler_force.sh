#!/bin/bash
#SBATCH --job-name=TB_Profiler_USA_BOVIS     # Job name
#SBATCH --partition=batch             # Partition (queue) name
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --cpus-per-task=4             #number of cores per task
#SBATCH --mem=40GB                     # Job memory request
#SBATCH --time=07-00:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)

#Specify outdir
OUTDIR=/scratch/nf26742/USA_Bovis_Human/results_3

#Tells the program to make the ourdir folder if it cant find it
if [ ! -d $OUTDIR ] 
then
    mkdir -p $OUTDIR
fi

#Navigate to fastqdir
cd /scratch/nf26742/USA_Bovis_Human

#load TBprofiler
module load TB-Profiler/6.6.5

#invoke tbprofiler
tb-profiler profile -1 *_1.fastq.gz -2 *_2.fastq.gz -o $OUTDIR -t 4
