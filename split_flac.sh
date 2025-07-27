#!/bin/bash

# Copyright (c) 2025 Luc Van Braekel
# Licensed under the MIT License. See LICENSE file in the project root for full license information.

# Root directory is the current working directory
ROOT_DIR="."

# Counter to track if any files were processed
processed=0

# Function to sanitize .cue file titles for NTFS compliance
sanitize_cue() {
    local input_cue="$1"
    local temp_cue=$(mktemp)
    
    # Start with a copy of the original file
    cp "$input_cue" "$temp_cue"
    
    # Step 1: Replace ? in TITLE lines
    sed '/^ *TITLE "/ s/?/-/g' "$temp_cue" > "$temp_cue.tmp" && mv "$temp_cue.tmp" "$temp_cue"
    
    # Step 2: Replace : in TITLE lines
    sed '/^ *TITLE "/ s/:/-/g' "$temp_cue" > "$temp_cue.tmp" && mv "$temp_cue.tmp" "$temp_cue"
    
    # Step 3: Replace < in TITLE lines
    sed '/^ *TITLE "/ s/</-/g' "$temp_cue" > "$temp_cue.tmp" && mv "$temp_cue.tmp" "$temp_cue"
    
    # Step 4: Replace > in TITLE lines
    sed '/^ *TITLE "/ s/>/-/g' "$temp_cue" > "$temp_cue.tmp" && mv "$temp_cue.tmp" "$temp_cue"
    
    # Step 5: Replace / in TITLE lines
    sed '/^ *TITLE "/ s/\//-/g' "$temp_cue" > "$temp_cue.tmp" && mv "$temp_cue.tmp" "$temp_cue"
    
    # Step 6: Replace \ in TITLE lines
    sed '/^ *TITLE "/ s/\\/-/g' "$temp_cue" > "$temp_cue.tmp" && mv "$temp_cue.tmp" "$temp_cue"
    
    # Step 7: Replace | in TITLE lines
    sed '/^ *TITLE "/ s/|/-/g' "$temp_cue" > "$temp_cue.tmp" && mv "$temp_cue.tmp" "$temp_cue"
    
    # Step 8: Replace * in TITLE lines
    sed '/^ *TITLE "/ s/\*/-/g' "$temp_cue" > "$temp_cue.tmp" && mv "$temp_cue.tmp" "$temp_cue"
    
    # Step 9: Replace octal \221 (0x91, left curly quote) in TITLE lines
    sed '/^ *TITLE "/ s/\o221/-/g' "$temp_cue" > "$temp_cue.tmp" && mv "$temp_cue.tmp" "$temp_cue"
    
    # Step 10: Replace octal \222 (0x92, right curly quote) in TITLE lines
    sed '/^ *TITLE "/ s/\o222/-/g' "$temp_cue" > "$temp_cue.tmp" && mv "$temp_cue.tmp" "$temp_cue"
    
    # Overwrite original with sanitized version
    mv "$temp_cue" "$input_cue"
}

# Find all .cue files recursively in the current directory, avoiding subshell
while read -r cue_file; do
    # Increment counter
    processed=$((processed + 1))
    
    # Get the directory of the .cue file
    dir=$(dirname "$cue_file")
    # Base name without .cue extension
    base_name="${cue_file%.cue}"
    # Check for both .flac and .FLAC extensions
    flac_file_lower="$base_name.flac"
    flac_file_upper="$base_name.FLAC"
    
    # Determine which flac file exists (if any)
    if [ -f "$flac_file_lower" ]; then
        flac_file="$flac_file_lower"
    elif [ -f "$flac_file_upper" ]; then
        flac_file="$flac_file_upper"
    else
        flac_file=""
    fi
    
    if [ -n "$flac_file" ]; then
        echo "[*] Checking: $flac_file with $cue_file"
        
        # Sanitize the .cue file for NTFS compliance
        sanitize_cue "$cue_file"
        
        # Check if any split files already exist (e.g., 01 - *.flac, 02 - *.flac, etc.)
        split_files_exist=false
        if ls "$dir"/[0-9][0-9]\ -\ *.flac >/dev/null 2>&1; then
            split_files_exist=true
            echo "[!] Split files (e.g., 01 - *.flac) already exist in $dir, skipping splitting."
            echo "[*] Renaming $cue_file to $cue_file.del since splitting is complete."
            mv "$cue_file" "$cue_file.del"
        fi
        
        # Only proceed with splitting if no split files exist
        if [ "$split_files_exist" = false ]; then
            echo "[*] Splitting: $flac_file"
            # Split the .flac using shntool into separate tracks, overwriting existing files
            shntool split -f "$cue_file" -o flac -t "%n - %t" -O always "$flac_file" -d "$dir"
            exit_code=$?
            if [ "$exit_code" -eq 0 ]; then
                echo "[v] Splitting successful, renaming originals with .del suffix..."
                mv "$flac_file" "${flac_file}.del"
                mv "$cue_file" "$cue_file.del"
            else
                echo "[!] Splitting failed (exit code: $exit_code), leaving originals unchanged."
            fi
        fi
    else
        echo "[!] No matching .flac or .FLAC found for $cue_file, renaming to $cue_file.del."
        mv "$cue_file" "$cue_file.del"
    fi
done < <(find "$ROOT_DIR" -type f -name "*.cue")

# Check if any files were processed
if [ "$processed" -eq 0 ]; then
    echo "[!] No .cue files found in $ROOT_DIR to process."
fi
echo "[v] Done! Check your files and cleanup by deleting all *.del files if needed."
