#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: flactoaif <input> <output_directory>"
    echo ""
    echo "  input: a single FLAC/M4A file or a directory (searched recursively)"
    echo "  Converts to AIFF (16-bit 44.1kHz), preserving metadata and cover art."
    exit 1
}

if [[ $# -ne 2 ]]; then
    usage
fi

input="$1"
output_dir="$2"

if [[ ! -e "$input" ]]; then
    echo "Error: '$input' does not exist."
    exit 1
fi

if ! command -v ffmpeg &>/dev/null; then
    echo "Error: ffmpeg is not installed."
    exit 1
fi

convert_file() {
    local src_file="$1"
    local aiff_file="$2"

    echo "Converting: $(basename "$src_file")"

    if ffmpeg -nostdin -i "$src_file" -af aresample=osr=44100:dither_method=shibata:cutoff=0.91:filter_size=256 -sample_fmt s16 -write_id3v2 1 -id3v2_version 3 -c:v copy "$aiff_file" -y -loglevel warning; then
        ((count++))
    else
        echo "  Failed: $(basename "$src_file")"
        ((failed++))
    fi
}

mkdir -p "$output_dir"
output_dir="$(cd "$output_dir" && pwd)"

count=0
failed=0

# Single file mode
if [[ -f "$input" ]]; then
    base="$(basename "$input")"
    ext="${base##*.}"
    ext_lower="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"

    if [[ "$ext_lower" != "flac" && "$ext_lower" != "m4a" ]]; then
        echo "Error: Unsupported file type '.$ext'. Only FLAC and M4A are supported."
        exit 1
    fi

    filename="${base%.*}.aiff"
    convert_file "$input" "$output_dir/$filename"
else
    # Directory mode
    input_dir="$(cd "$input" && pwd)"

    # Check for duplicate filenames across both formats
    all_names="$(
        find "$input_dir" -type f \( -iname '*.flac' -o -iname '*.m4a' \) -print0 \
        | xargs -0 -n1 basename \
        | sed -E 's/\.(flac|m4a)$//i' \
        | sort
    )"
    dupes="$(echo "$all_names" | uniq -d)"
    if [[ -n "$dupes" ]]; then
        echo "Error: Duplicate output filenames found:"
        while IFS= read -r name; do
            echo "  $name"
            find "$input_dir" -type f \( -iname "$name.flac" -o -iname "$name.m4a" \) -print | sed 's/^/    /'
        done <<< "$dupes"
        echo ""
        echo "Aborting. Rename the source files and try again."
        exit 1
    fi

    while IFS= read -r -d '' src_file; do
        base="$(basename "$src_file")"
        filename="${base%.*}.aiff"
        convert_file "$src_file" "$output_dir/$filename"
    done < <(find "$input_dir" -type f \( -iname '*.flac' -o -iname '*.m4a' \) -print0)
fi

echo ""
echo "Done. Converted: $count | Failed: $failed"
