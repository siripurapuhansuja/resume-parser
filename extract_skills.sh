
#!/bin/sh

# Check whether the correct number of arguments is provided

if [ "$#" -ne 1 ]; then
    echo "Usage: sh extract_skills.sh resume.txt"
    exit 1
fi

# Store the resume filename

resume=$1

# Check whether the resume file exists and is readable

if [ ! -f "$resume" ] || [ ! -r "$resume" ]; then
    echo "Cannot read resume file: $resume"
    exit 1
fi

# Check whether skills.txt exists and is readable

if [ ! -f "skills.txt" ] || [ ! -r "skills.txt" ]; then
    echo "Cannot read skills.txt"
    exit 1
fi

# Read each skill from skills.txt

while IFS= read -r skill || [ -n "$skill" ]
do

    # Skip empty lines

    [ -z "$skill" ] && continue

    # Search for the skill in the resume

    if grep -Fwiq -- "$skill" "$resume"; then
        echo "$skill"
    fi

done < skills.txt

