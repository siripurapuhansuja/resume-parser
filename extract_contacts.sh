#!/bin/sh
# Usage: sh extract_contacts.sh resume.txt
# Output: first email on line 1, first phone on line 2, blank for either missing field.

if [ "$#" -ne 1 ]; then
    printf 'Usage: sh %s resume.txt\n' "${0##*/}" >&2
    exit 2
fi

resume=$1
if [ ! -f "$resume" ] || [ ! -r "$resume" ]; then
    printf 'Cannot read résumé file: %s\n' "$resume" >&2
    exit 2
fi

export LC_ALL=C

email_pattern='[A-Za-z0-9_%+-]+(\.[A-Za-z0-9_%+-]+)*@[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?(\.[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?)*\.[A-Za-z]{2,}'
phone_pattern='(\+91[ -]?)?([0-9]{10}|[0-9]{5}[ -][0-9]{5})'

email_matches=$(grep -aEow -e "$email_pattern" < "$resume") || [ "$?" -eq 1 ] || exit 2
phone_matches=$(grep -aEow -e "$phone_pattern" < "$resume") || [ "$?" -eq 1 ] || exit 2

# grep returns one match per line. Read the first line of each set.
IFS= read -r email <<EOF
$email_matches
EOF
IFS= read -r phone <<EOF
$phone_matches
EOF

printf '%s\n%s\n' "$email" "$phone"
