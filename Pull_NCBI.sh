#!/bin/bash
#SBATCH --job-name=NCBI_Download_Accession      # Job name
#SBATCH --partition=batch                # Partition (queue) name
#SBATCH --ntasks=1                       # Run on a single CPU
#SBATCH --cpus-per-task=8                # Number of cores per task
#SBATCH --mem=80gb                       # Job memory request
#SBATCH --time=00-12:00:00               # Time limit hrs:min:sec
#SBATCH --output=/scratch/nf26742/scratch/log.%j.out  # Standard output log
#SBATCH --error=/scratch/nf26742/scratch/log.%j.err   # Standard error log

#SBATCH --mail-type=END,FAIL             # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=nf26742@uga.edu      # Where to send mail

# Specify output directory
OUTDIR="/lustre2/scratch/nf26742/Mbovis_Africa_Europe"

# Create output directory if it doesn't exist
mkdir -p "$OUTDIR"

# Load SRA tools
module load SRA-Toolkit/3.0.3-gompi-2022a

# List of SRR accessions
accessions=(
ERR6367053
ERR6367054
ERR6367055
ERR6367056
ERR6367057
ERR6367058
ERR6367059
ERR6367060
ERR6367061
ERR6367062
ERR6367063
ERR6367064
ERR6367065
ERR6367066
ERR6367067
ERR6367068
ERR6367069
ERR6367070
ERR6367071
ERR6367072
ERR6367073
ERR6367074
ERR6367075
ERR6367076
ERR6367077
ERR6367078
ERR6367079
ERR6367080
ERR6367081
ERR6367082
ERR6367083
ERR6367084
ERR6367085
ERR6367086
ERR6367087
ERR6367088
ERR6367089
ERR6367090
ERR6367091
ERR6367092
ERR6367093
ERR6367094
ERR6367095
ERR6367096
ERR6367097
ERR6367098
ERR6367099
ERR6367100
ERR6367101
ERR6367102
ERR6367103
ERR6367104
ERR6367105
ERR6367106
ERR6367107
ERR6367108
ERR6367109
ERR6367110
ERR6367111
ERR6367112
ERR6367113
ERR6367114
ERR6367115
ERR6367116
ERR6367117
ERR6367118
ERR6367119
ERR6367120
ERR6367121
ERR6367122
ERR6367123
ERR6367124
ERR6367125
ERR6367126
ERR6367127
ERR6367128
ERR15998592
ERR15998593
)

for srr in "${accessions[@]}"; do
    echo "🔄 Downloading $srr from NCBI"

    fasterq-dump "$srr" -O "$OUTDIR" --threads 8
    if [[ $? -eq 0 ]]; then
        echo "✅ Successfully downloaded and converted $srr"
    else
        echo "⚠️  NCBI failed"
    fi
done
