#!/bin/bash
# remove_ref.sh
# Removes the reference sequence from a Snippy core alignment
# Usage: bash remove_ref.sh core-snp.full.aln core-snp.no_ref.fasta

# Input alignment (FASTA)
ALN_FILE=${1:-core-snp.full.aln}

# Output cleaned alignment
CLEAN_ALN=${2:-core-snp.no_ref.fasta}

# Reference sequence header (exact match or unique substring)
REFNAME="Reference"

# Check input file exists
if [ ! -f "$ALN_FILE" ]; then
    echo "Error: Input alignment $ALN_FILE not found!"
    exit 1
fi

# Remove reference
awk -v ref="$REFNAME" '
    /^>/ {header=$0; getline seq;
           if (header !~ ref) { print header; print seq }
    }
' "$ALN_FILE" > "$CLEAN_ALN"

echo "Reference removed. Clean alignment saved to $CLEAN_ALN"

# Optional verification
echo "Verifying headers in cleaned alignment:"
grep "^>" "$CLEAN_ALN"

# Count sequences
SEQ_COUNT=$(grep "^>" "$CLEAN_ALN" | wc -l)
echo "Number of sequences in cleaned alignment: $SEQ_COUNT"
