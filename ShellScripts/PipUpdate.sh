#!/bin/zsh

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatEcho.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    echo "Error: Required library $FORMAT_LIBRARY not found" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

# Pip Package Update
clear
format_echo "Pip Package Update..." yellow bold
echo

# Log file to track updates
LOG_FILE="$HOME/pip_update_$(date +%Y-%m-%d).log"

echo | tee -a "$LOG_FILE"
echo "📦 Starting pip package update..." | tee -a "$LOG_FILE"
echo "🕒 Timestamp: $(date)" | tee -a "$LOG_FILE"

# Check for pip
if ! command -v pip >/dev/null; then
    echo "❌ pip is not installed or not in PATH." | tee -a "$LOG_FILE"
    exit 1
fi

# Self-upgrade pip
echo "⬆️  Checking for pip update..." | tee -a "$LOG_FILE"
if pip install --upgrade pip >>"$LOG_FILE" 2>&1; then
    echo "✅ pip upgraded successfully." | tee -a "$LOG_FILE"
else
    echo "⚠️ Failed to upgrade pip. Continuing with package updates..." | tee -a "$LOG_FILE"
fi

# Get list of outdated packages in JSON
outdated_json=$(pip list --outdated --format=json)

# Safely extract package names, excluding 'pip' and empty entries
packages=()
for pkg in ${(f)"$(echo "$outdated_json" | python3 -c "
import sys, json
for p in json.load(sys.stdin):
    name = p.get('name', '').strip()
    if name.lower() != 'pip' and name:
        print(name)
")"}; do
    packages+=("$pkg")
done

if [[ ${#packages[@]} -eq 0 ]]; then
# No outdated packages found
    echo "✅ No outdated packages to update." | tee -a "$LOG_FILE"
else
# Upgrade each package and log result
    echo "🔄 Updating the following packages:" | tee -a "$LOG_FILE"
    printf "%s\n" "${packages[@]}" | tee -a "$LOG_FILE"
    for pkg in "${packages[@]}"; do
        echo "⬆️ Updating $pkg..." | tee -a "$LOG_FILE"
        if pip install -U "$pkg" >>"$LOG_FILE" 2>&1; then
            echo "✅ $pkg updated successfully." | tee -a "$LOG_FILE"
        else
            echo "❌ Failed to update $pkg. Check log for details." | tee -a "$LOG_FILE"
        fi
    done
fi

# Ask user if they want to view the log file
echo
read "viewlog?📄 View log file? (y/n): "
if [[ "$viewlog" =~ ^[Yy]$ ]]; then
    clear
    format_echo "Pip Package Update Logfile..." yellow bold
    cat "$LOG_FILE" | more
fi

