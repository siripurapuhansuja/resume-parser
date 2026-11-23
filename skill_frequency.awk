# Input: one candidate_id<TAB>skill pair per line, without a header.
# Output: one CSV row per skill, in first-seen order.

BEGIN {
    FS = "\t"
}

function trim(value) {
    sub(/^[[:space:]]+/, "", value)
    sub(/[[:space:]]+$/, "", value)
    return value
}

function csv_field(value) {
    if (value ~ /[",\r\n]/) {
        gsub(/"/, "\"\"", value)
        return "\"" value "\""
    }
    return value
}

NF == 2 {
    candidate = trim($1)
    skill = trim($2)
    if (candidate == "" || skill == "")
        next

    skill_key = tolower(skill)
    if ((candidate, skill_key) in seen)
        next
    seen[candidate, skill_key] = 1

    if (!(skill_key in counts)) {
        display_name[skill_key] = skill
        order[++skill_count] = skill_key
    }
    counts[skill_key]++
}

END {
    print "skill,candidate_count"
    for (i = 1; i <= skill_count; i++) {
        skill_key = order[i]
        printf "%s,%d\n", csv_field(display_name[skill_key]), counts[skill_key]
    }
}
