#!/bin/zsh
# Change text in scripts from one string to another
# Exit on any error
set -e

# Go to target directory
cd $HOME/Desktop/claude_workspace/scripts

# Find files with the text and log them
grep -rl 'Hit any key' --include='*.sh' . > changes.log

# Apply the changes
if [[ -s "changes.log" ]]; then
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        echo "Updating $file"
        sed -i.bak 's/Hit any key/Press any key/g' "$file"
    done < changes.log
else
    echo "No files found containing 'Hit any key'"
fi

# Check if changes.log exists
if [[ ! -f "changes.log" ]]; then
    echo "Error: changes.log not found in current directory"
    exit 1
fi

# Create origfiles directory if it doesn't exist
# mkdir -p $HOME/bin

# Copy updated files
while IFS= read -r filename; do
    [[ -z "$filename" ]] && continue
    
    if [[ -f "$filename" ]]; then
        echo "Copying: $filename"
        cp "$filename" $HOME/bin
    else
        echo "Warning: File not found: $filename"
    fi
done < changes.log

echo "Copy operation completed."
