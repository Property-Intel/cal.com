#!/bin/bash
set -e

FROM=$1
TO=$2

if [ -z "$FROM" ] || [ -z "$TO" ]; then
    echo "Error: Both FROM and TO arguments are required"
    exit 1
fi

if [ "${FROM}" = "${TO}" ]; then
    echo "Nothing to replace, the value is already set to ${TO}."
    exit 0
fi

# Only perform action if $FROM and $TO are different.
echo "Replacing all statically built instances of $FROM with $TO."

# Create a temporary file for sed
for file in $(grep -r -l "${FROM}" apps/web/.next/ apps/web/public/ 2>/dev/null || true); do
    if [ -f "$file" ]; then
        sed -i.bak "s|${FROM}|${TO}|g" "$file" && rm -f "${file}.bak"
    fi
done
