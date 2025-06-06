#!/bin/bash
#SBATCH --job-name=Bactopia_rename        # Job name
#SBATCH --partition=batch             # Partition (queue) name
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --cpus-per-task=4             #number of cores per task
#SBATCH --mem=40GB                     # Job memory request
#SBATCH --time=04-00:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)

#move to target directory

cd /lustre2/scratch/nf26742/AllFastqs_UPDATED25 || { echo "Failed to cd"; exit 1; }

# Unzip all fastq.gz files if any exist
shopt -s nullglob
for gzfile in *.fastq.gz; do
    gunzip -f "$gzfile"
done

# Rename .fastq files replacing '-' with '_'
for file in *.fastq; do
    new_name="${file//-/_}"
    if [[ "$file" != "$new_name" ]]; then
        mv -v "$file" "$new_name"
    fi
done

# Gzip all .fastq files again
for fastqfile in *.fastq; do
    gzip -f "$fastqfile"
done
