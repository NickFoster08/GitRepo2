#!/bin/bash

export PATH=${HOME}/edirect:$PATH

INPUT="/mnt/c/Users/nf26742/Desktop/Bovis_SAMN.txt"
OUTPUT="valid_srrs.txt"

> "$OUTPUT"

while read samn; do
    [[ -z "$samn" ]] && continue
    samn_clean=$(echo "$samn" | tr -d '\r' | tr -d ' ')
    srr=$(esearch -db biosample -query "$samn_clean" \
          | elink -target sra \
          | efetch -format runinfo \
          | cut -d',' -f1 \
          | grep SRR)
    if [[ -n "$srr" ]]; then
        echo "$samn_clean -> $srr"
        echo "$srr" >> "$OUTPUT"
    else
        echo "$samn_clean -> NO SRR FOUND"
    fi
done < "$INPUT"
