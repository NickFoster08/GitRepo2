
#!/bin/bash
#SBATCH --job-name=VSNP_STEP1_Afr_Euro
#SBATCH --cpus-per-task=16
#SBATCH --mem=300gb
#SBATCH --time=14-0:00:00
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=nf26742@uga.edu

set -euo pipefail

OUTDIR="/scratch/nf26742/rerun_2025/job_${SLURM_JOB_ID}"
REFERENCE="/home/nf26742/vsnp3_test_dataset/vsnp_dependencies/Mycobacterium_AF2122"
FASTQ_DIR="/scratch/nf26742/rerun_2025/job_47709570/PDA_Select_Genomes"

# Central directory containing all Step 2 VCF inputs
STEP2_DIR="$OUTDIR/step2_vcfs"

module load vSNP3/3.31

mkdir -p "$OUTDIR"
mkdir -p "$STEP2_DIR"

cd "$FASTQ_DIR"

shopt -s nullglob

R1_FILES=(*_1.fastq.gz)

if (( ${#R1_FILES[@]} == 0 )); then
    echo "ERROR: No R1 FASTQ files found in $FASTQ_DIR"
    exit 1
fi

COUNT=0

for R1 in "${R1_FILES[@]}"; do

    R2="${R1/_1.fastq.gz/_2.fastq.gz}"

    if [[ ! -f "$R2" ]]; then
        echo "ERROR: Missing R2 for $R1"
        exit 1
    fi

    SAMPLE=$(basename "$R1" _1.fastq.gz)
    SAMPLE_OUTDIR="$OUTDIR/$SAMPLE"

    # Extract accession identifier
    ACCESSION=$(grep -oE '(SRR|ERR)[0-9]+' <<< "$SAMPLE" | tail -1)

    if [[ -z "$ACCESSION" ]]; then
        echo "ERROR: Could not identify accession for $SAMPLE"
        exit 1
    fi

    echo "Processing sample: $SAMPLE"

    mkdir -p "$SAMPLE_OUTDIR"

    vsnp3_step1.py \
        -r1 "$R1" \
        -r2 "$R2" \
        -t "$REFERENCE" \
        -o "$SAMPLE_OUTDIR" \
        --spoligo

    # Locate the Step 1 zc.vcf output
    mapfile -d '' ZC_VCFS < <(
        find "$SAMPLE_OUTDIR" -type f -name "*_zc.vcf" -print0
    )

    if (( ${#ZC_VCFS[@]} != 1 )); then
        echo "ERROR: Expected exactly one zc.vcf for $SAMPLE"
        echo "Found: ${#ZC_VCFS[@]}"
        exit 1
    fi

    # Create uniquely named symbolic link for Step 2
    LINK="$STEP2_DIR/${ACCESSION}_zc.vcf"

    if [[ -e "$LINK" || -L "$LINK" ]]; then
        echo "ERROR: Duplicate accession or existing VCF link: $LINK"
        exit 1
    fi

    ln -s "${ZC_VCFS[0]}" "$LINK"

    COUNT=$((COUNT + 1))

    echo "Added $ACCESSION to Step 2 input directory."

done

echo "----------------------------------------"
echo "All samples processed successfully."
echo "Total VCFs collected: $COUNT"
echo "Step 2 input directory: $STEP2_DIR"
echo "----------------------------------------"

if [[ "$COUNT" -ne "${#R1_FILES[@]}" ]]; then
    echo "ERROR: VCF count does not match FASTQ sample count."
    exit 1
fi
