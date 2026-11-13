#!/bin/bash
#SBATCH --job-name=vSNP_STEP2_AFREUR       # Job name
#SBATCH --partition=batch             # Partition (queue) name
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --cpus-per-task=4             #number of cores per task
#SBATCH --mem=300GB                     # Job memory request
#SBATCH --time=04-00:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out    # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err     # Standard error log

#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu  # Where to send mail (change username@uga.edu to your email address)

set -euo pipefail

VCF_DIR="/scratch/nf26742/rerun_2025/job_50080262/step2_vcfs"

module load vSNP3/3.31

export PYTHONPATH="/scratch/nf26742:/apps/eb/vSNP3/3.31/bin:${PYTHONPATH:-}"

if [[ ! -d "$VCF_DIR" ]]; then
    echo "Error: VCF directory not found: $VCF_DIR"
    exit 1
fi

VCF_COUNT=$(find "$VCF_DIR" -maxdepth 1 -type l -name '*_zc.vcf' | wc -l)
BROKEN_COUNT=$(find "$VCF_DIR" -maxdepth 1 -type l -name '*_zc.vcf' ! -exec test -e {} \; | wc -l)

echo "VCF symlinks found: $VCF_COUNT"
echo "Broken symlinks: $BROKEN_COUNT"

if [[ "$VCF_COUNT" -eq 0 ]]; then
    echo "ERROR: No VCF symlinks found. Step 2 will not run."
    exit 1
fi

if [[ "$BROKEN_COUNT" -ne 0 ]]; then
    echo "ERROR: Broken VCF symlinks detected."
    exit 1
fi

cd "$VCF_DIR"
python -c '
import sys, runpy

sys.path.insert(0, "/scratch/nf26742")
import vsnp3_group_on_defining_snps

print("Loaded module from:", vsnp3_group_on_defining_snps.__file__)

if vsnp3_group_on_defining_snps.__file__ != "/scratch/nf26742/vsnp3_group_on_defining_snps.py":
    raise RuntimeError("ERROR: Patched vSNP3 module was not loaded.")

sys.argv = [
    "vsnp3_step2.py",
    "-a",
    "-t",
    "Mycobacterium_AF2122"
]

runpy.run_path(
    "/apps/eb/vSNP3/3.31/bin/vsnp3_step2.py",
    run_name="__main__"
)
'

echo "vSNP step2 completed."