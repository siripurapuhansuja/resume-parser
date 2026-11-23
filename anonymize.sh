#!/usr/bin/env bash

resume_file="$1"
candidate_id="$2"
name_pattern='^[[:space:]]*Name[[:space:]]*:'

if [[ $# -ne 2 || ! -f "$resume_file" || ! -r "$resume_file" || ! "$candidate_id" =~ ^C[0-9]+$ ]]; then
    echo "Usage: bash anonymize.sh <readable-resume-file> <ID like C001>" >&2
    exit 1
fi

if ! grep -qi -- "$name_pattern" "$resume_file"; then
    echo "No Name: line found in $resume_file" >&2
    exit 1
fi

mkdir -p anonymized || exit 1
sed -E "s/${name_pattern}.*/Name: ${candidate_id}/I" -- "$resume_file" \
    > "anonymized/${candidate_id}.txt"
