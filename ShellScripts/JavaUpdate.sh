#!/bin/zsh
# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"

[[ -f "$FORMAT_LIBRARY" ]] || { echo "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Function to display script header
display_header() {
    clear
    format_printf "Java Update..." "yellow" "bold"
}

# --- Main script execution ---
display_header
printf "\n"

# Get current installed Java version (Zulu style)
# Handle both formats: Zulu24.30.11 and Zulu24.30+11-CA
java_version_output=$(java -version 2>&1)
if echo "$java_version_output" | grep -q "Zulu"; then
    # Extract the Zulu version pattern and clean it up
    current_zulu_version=$(echo "$java_version_output" | grep -oE 'Zulu[0-9]+\.[0-9]+[+\.][0-9]+' | head -1 | sed -E 's/Zulu([0-9]+\.[0-9]+)[+\.]([0-9]+).*/\1.\2/')
else
    current_zulu_version=""
fi

# Check if we found a Zulu version
if [[ -z "$current_zulu_version" ]]; then
    warning_printf "Current installed Zulu version: Not found (or not Zulu JDK)"
else
    info_printf "Current installed Zulu version: $current_zulu_version"
fi

update_printf "Checking for latest version..."

# Fetch list of all Zulu .dmg files from CDN
file_list=$(curl -s https://cdn.azul.com/zulu/bin/)

# Check if curl was successful
if [[ $? -ne 0 || -z "$file_list" ]]; then
    error_printf "Failed to fetch version information from Azul CDN" true
fi

# Extract macOS .dmg filenames with Zulu and Java 11+
dmg_links=(${(@f)$(echo "$file_list" | grep -Eo 'zulu([0-9]+\.[0-9]+\.[0-9]+)-ca-jdk(1[1-9]|2[0-9])[0-9\.\-]*-macosx_[^"]+\.dmg')})

# Remove duplicate links and sort (reverse natural sort)
unique_dmg_links=(${(u)dmg_links[@]})
sorted=(${(On)unique_dmg_links[@]})

# Extract latest Zulu version
latest_zulu_version=""
for link in "${sorted[@]}"; do
    version=$(echo "$link" | sed -E 's/zulu([0-9]+\.[0-9]+\.[0-9]+)-ca.*/\1/')
    if [[ -n "$version" ]]; then
        latest_zulu_version="$version"
        break
    fi
done

if [[ -z "$latest_zulu_version" ]]; then
    error_printf "Could not determine latest Zulu version" true
fi

# Now list all links that match this latest version
printf "\n"
success_printf "Latest Zulu version: $latest_zulu_version"
package_printf "macOS .dmg links for this version:"
for link in "${sorted[@]}"; do
    version=$(echo "$link" | sed -E 's/zulu([0-9]+\.[0-9]+\.[0-9]+)-ca.*/\1/')
    if [[ "$version" == "$latest_zulu_version" ]]; then
        printf "  https://cdn.azul.com/zulu/bin/%s\n" "$link"
    fi
done
printf "\n"

# Function to compare semver-style Zulu versions
ver_gt() {
    autoload -Uz is-at-least
    # is-at-least returns 0 if $2 >= $1, so we need to reverse the logic
    is-at-least "$1" "$2"
    return $((!$?))
}

# Compare and output result only if we have a current version
if [[ -n "$current_zulu_version" ]]; then
    if ver_gt "$latest_zulu_version" "$current_zulu_version"; then
        upgrade_printf "A newer Zulu version is available: $latest_zulu_version"
        printf "   Your current version: %s\n" "$current_zulu_version"
    else
        success_printf "You're already using the latest or a newer Zulu version."
        printf "   Your current version: %s\n" "$current_zulu_version"
    fi
else
    warning_printf "Cannot compare versions - Zulu JDK not detected in your current Java installation"
    printf "   Latest available version: %s\n" "$latest_zulu_version"
fi
