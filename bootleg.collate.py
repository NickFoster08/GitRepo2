import json
import csv
from pathlib import Path

# Path to your directory containing all TB-Profiler results (JSONs in subdirs)
results_dir = Path("/scratch/nf26742/USA_Bovis_Human/TBProfiler_results")

# Output CSV file
output_csv = Path("/scratch/nf26742/USA_Bovis_Human/TBProfiler_results_collated.csv")

# Find all .results.json files recursively
json_files = list(results_dir.rglob("*.results.json"))
print(f"Found {len(json_files)} JSON files")

# Prepare CSV header
fieldnames = ["sample", "lineage", "lineage_confidence", "drug", "prediction", "mutation", "mutation_position"]

with open(output_csv, "w", newline="") as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    for jf in json_files:
        with open(jf) as f:
            data = json.load(f)

        sample_name = data.get("sample", jf.stem)

        # Lineage information
        lineage = data.get("lineage", [])
        lineage_str = ";".join([l.get("id", "") for l in lineage])
        # Confidence can sometimes be stored in support
        lineage_conf = ";".join(
            [str(s.get("allele_percent", "")) for l in lineage for s in l.get("support", [])]
        )

        # AMR/drug info
        drugs = data.get("drugs", {})
        if not drugs:
            writer.writerow({
                "sample": sample_name,
                "lineage": lineage_str,
                "lineage_confidence": lineage_conf,
                "drug": "",
                "prediction": "",
                "mutation": "",
                "mutation_position": ""
            })
            continue

        for drug_name, drug_info in drugs.items():
            prediction = drug_info.get("prediction", "")
            mutations = drug_info.get("mutations", [])
            if not mutations:
                writer.writerow({
                    "sample": sample_name,
                    "lineage": lineage_str,
                    "lineage_confidence": lineage_conf,
                    "drug": drug_name,
                    "prediction": prediction,
                    "mutation": "",
                    "mutation_position": ""
                })
            else:
                for mut in mutations:
                    writer.writerow({
                        "sample": sample_name,
                        "lineage": lineage_str,
                        "lineage_confidence": lineage_conf,
                        "drug": drug_name,
                        "prediction": prediction,
                        "mutation": mut.get("name", ""),
                        "mutation_position": mut.get("position", "")
                    })

print(f"Collated CSV saved to {output_csv}")
