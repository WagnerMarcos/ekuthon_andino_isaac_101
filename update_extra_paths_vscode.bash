#!/usr/bin/env bash
set -euo pipefail

# ----- CONFIG -----
BASE_PATHS=(
    "/isaac-sim/extscache"
    "/isaac-sim/exts"
    "/isaac-sim/extsDeprecated"
    "/isaac-sim/kit/extscore/"
)

# ----- Collect first-level subdirectories -----
RESULT=()

for base in "${BASE_PATHS[@]}"; do
    base="${base%/}"

    if [[ -d "$base" ]]; then
        while IFS= read -r -d '' subdir; do
            RESULT+=("$subdir")
        done < <(find "$base" -mindepth 1 -maxdepth 1 -type d -print0)
    else
        echo "Warning: $base does not exist" >&2
    fi
done

# Deduplicate
readarray -t UNIQUE < <(printf "%s\n" "${RESULT[@]}" | sort -u)

# ----- Print JSON-friendly list -----

echo "["
for i in "${!UNIQUE[@]}"; do
    path=${UNIQUE[$i]}
    if [[ $i -lt $((${#UNIQUE[@]} - 1)) ]]; then
        echo "  \"${path}\","
    else
        echo "  \"${path}\""
    fi
done
echo "]"
echo ""

echo ""
echo "Copy this into your settings.json → python.analysis.extraPaths:"
echo ""