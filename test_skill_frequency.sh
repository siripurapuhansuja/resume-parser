#!/bin/sh
set -eu

cd "$(dirname "$0")"

expected='skill,candidate_count
Python,2
SQL,2
Git,1'
actual=$(printf 'C001\tPython\nC001\tPython\nC001\tPYTHON\nC001\tSQL\nC002\tPython\nC002\tGit\nC003\tSQL\n' |
    awk -f skill_frequency.awk)
if [ "$actual" != "$expected" ]; then
    printf 'Sample report mismatch. Actual output:\n%s\n' "$actual" >&2
    exit 1
fi

expected='skill,candidate_count
"Data, ""AI""",2'
actual=$(printf 'C001\t Data, "AI" \r\nC002\tdata, "ai"\r\nC001\tDATA, "AI"\r\nC003\t\r\n\tJava\r\n' |
    awk -f skill_frequency.awk)
if [ "$actual" != "$expected" ]; then
    printf 'CSV escaping or blank field mismatch. Actual output:\n%s\n' "$actual" >&2
    exit 1
fi

actual=$(awk -f skill_frequency.awk < /dev/null)
if [ "$actual" != 'skill,candidate_count' ]; then
    printf 'Empty input should produce only the CSV header.\n' >&2
    exit 1
fi

printf 'Member 4 smoke tests passed.\n'
