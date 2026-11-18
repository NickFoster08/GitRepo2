#!/bin/bash
#SBATCH --job-name=tbp_collate
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=collate_%j.log

module load TB-Profiler/6.6.5
cd /scratch/nf26742/Mbovis_Africa_Europe/TBProfiler_All
tb-profiler collate --prefix ALL_Bovis --dir TBProfiler_ALL/results
