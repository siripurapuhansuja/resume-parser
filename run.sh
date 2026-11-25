#!/bin/bash

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESUMES_DIR="$PROJECT_DIR/resumes"
OUTPUT_DIR="$PROJECT_DIR/output"

mkdir -p "$OUTPUT_DIR"

CANDIDATES_CSV="$OUTPUT_DIR/candidates.csv"
SKILLS_TSV="$OUTPUT_DIR/candidate_skills.tsv"

printf 'candidate_id,email,phone\n' > "$CANDIDATES_CSV"
: > "$SKILLS_TSV"

counter=0

for resume in "$RESUMES_DIR"/*.txt
do
    [ -f "$resume" ] || continue

    counter=$((counter + 1))
    candidate_id=$(printf "C%03d" "$counter")

    # Extract contact details
    contact_info=$(bash "$PROJECT_DIR/extract_contacts.sh" "$resume")
    email=$(printf '%s\n' "$contact_info" | sed -n '1p')
    phone=$(printf '%s\n' "$contact_info" | sed -n '2p')

    printf '%s,%s,%s\n' "$candidate_id" "$email" "$phone" >> "$CANDIDATES_CSV"

    # Extract skills
    skills=$(bash "$PROJECT_DIR/extract_skills.sh" "$resume")

    while IFS= read -r skill
    do
        if [ -n "$skill" ]; then
            printf '%s\t%s\n' "$candidate_id" "$skill" >> "$SKILLS_TSV"
        fi
    done <<< "$skills"

    # Anonymize only when Name field exists
    if grep -q 'Name:' "$resume"; then
        bash "$PROJECT_DIR/anonymize.sh" "$resume" "$candidate_id"
    else
        echo "Skipping anonymization for $resume: Name field missing"
    fi

done

# Generate skill frequency report
awk -f "$PROJECT_DIR/skill_frequency.awk" \
    < "$SKILLS_TSV" > "$OUTPUT_DIR/skill_frequency.csv"

echo ""
echo "=================================="
echo "BATCH PROCESSING COMPLETED!"
echo "=================================="
echo "Total candidates processed: $counter"
echo ""
echo "Generated files:"
echo "1. $CANDIDATES_CSV"
echo "2. $SKILLS_TSV"
echo "3. $OUTPUT_DIR/skill_frequency.csv"
