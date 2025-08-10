#!/bin/zsh
# Enhanced npm package update script with simplified menu
FORMAT_LIBRARY="$(dirname "$0")/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

cd "$(dirname "$0")/../mcp-servers/date-generator" 2>/dev/null || true

SCRIPT_DIR=""
HAS_PACKAGE_JSON=false
HAS_NCU=false
HAS_LOCKFILE=false
LOCKFILE_TYPE=""

display_header() {
    clear
    format_printf "Npm Package Update..." "yellow" "bold" "package"
}

validate_environment() {
    info_printf "Validating environment..."
    SCRIPT_DIR=$(pwd)
    
    if [[ -f "package.json" ]]; then
        HAS_PACKAGE_JSON=true
        success_printf "Found package.json in current directory"
    else
        error_printf "No package.json found in current directory: $SCRIPT_DIR" true
    fi

    if ! command -v npm &> /dev/null; then
        error_printf "npm is not installed or not in PATH" true
    fi

    if command -v ncu &> /dev/null; then
        HAS_NCU=true
        success_printf "npm-check-updates (ncu) is available"
    else
        warning_printf "npm-check-updates (ncu) is not installed"
        warning_printf "Major version updates will not be available"
        warning_printf "Install with: npm install -g npm-check-updates"
    fi

    if [[ -f "package-lock.json" ]]; then
        HAS_LOCKFILE=true
        LOCKFILE_TYPE="npm"
        info_printf "Detected package-lock.json (npm project)"
    elif [[ -f "yarn.lock" ]]; then
        HAS_LOCKFILE=true
        LOCKFILE_TYPE="yarn"
        info_printf "Detected yarn.lock (Yarn project)"
        warning_printf "This script is optimized for npm - yarn operations may behave differently"
    fi
    printf "\n"
}

get_yes_no() {
    local prompt="$1"
    local response
    while true; do
        read -p "$prompt (y/n): " response
        case ${response:l} in
            y|yes|1) return 0 ;;
            n|no|0)  return 1 ;;
            "") warning_printf "Please provide an answer." ;;
            *) warning_printf "Please answer yes (y) or no (n)." ;;
        esac
    done
}

show_package_info() {
    if [[ ! -f "package.json" ]]; then return 1; fi
    info_printf "Current project information:"
    if command -v jq &> /dev/null; then
        local name=$(jq -r '.name // "unnamed"' package.json 2>/dev/null)
        local version=$(jq -r '.version // "unknown"' package.json 2>/dev/null)
        printf "  Project: %s (v%s)\n" "$name" "$version"
    else
        printf "  Location: %s\n" "$SCRIPT_DIR"
    fi
    local dep_count=0
    local dev_dep_count=0
    if command -v jq &> /dev/null; then
        dep_count=$(jq -r '.dependencies // {} | length' package.json 2>/dev/null || echo "0")
        dev_dep_count=$(jq -r '.devDependencies // {} | length' package.json 2>/dev/null || echo "0")
    fi
    printf "  Dependencies: %d regular, %d development\n" "$dep_count" "$dev_dep_count"
    printf "\n"

    if command -v npm &> /dev/null; then
        info_printf "Current package status:"
        local outdated_output
        # Use || true to ignore the exit code
        outdated_output=$(npm outdated 2>/dev/null || true)
        if [[ -n "$outdated_output" ]]; then
            printf "%s\n" "$outdated_output"
        else
            success_printf "All packages appear to be up to date"
        fi
    fi
}

select_mcp_server() {
    local mcp_servers_dir="$(dirname "$0")/../mcp-servers"
    info_printf "Scanning for MCP servers in $mcp_servers_dir..."
    
    if [[ ! -d "$mcp_servers_dir" ]]; then
        error_printf "Directory $mcp_servers_dir not found"
        return 1
    fi
    
    local servers=()
    local server_names=()
    
    # Find directories containing package.json
    for dir in "$mcp_servers_dir"/*/; do
        if [[ -f "$dir/package.json" ]]; then
            local dir_name=$(basename "$dir")
            servers+=("$dir")
            
            # Get the name from package.json using same logic as show_package_info
            if command -v jq &> /dev/null; then
                local name=$(jq -r '.name // "unnamed"' "$dir/package.json" 2>/dev/null)
                server_names+=("$name")
            else
                server_names+=("$dir_name")
            fi
        fi
    done
    
    if [[ ${#servers[@]} -eq 0 ]]; then
        warning_printf "No MCP servers found with package.json files"
        return 1
    fi
    
    printf "\n"; info_printf "Select a MCP Server:"
    for (( i=0; i<${#servers[@]}; i++ )); do
        printf "%d) %s\n" "$((i+1))" "${server_names[$i]}"
    done
    printf "\n"
    
    local choice
    while true; do
        read -p "Enter your choice (1-${#servers[@]}): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#servers[@]} ]]; then
            local selected_dir="${servers[$((choice-1))]}"
            success_printf "Selected: ${server_names[$((choice-1))]}"
            success_printf "Changing to directory: $selected_dir"
            cd "$selected_dir"
            return 0
        else
            warning_printf "Invalid choice. Please enter a number between 1 and ${#servers[@]}."
        fi
    done
}

run_standard_update() {
    update_printf "Starting standard npm update (minor/patch versions)..."
    info_printf "Checking for available updates..."
    # Use || true to ignore the exit code
    local outdated_output=$(npm outdated 2>/dev/null || true)
    if [[ -z "$outdated_output" ]]; then
        success_printf "All packages are already up to date!"
        return 0
    else
        printf "%s\n" "$outdated_output"
    fi
    printf "\n"
    if ! get_yes_no "Proceed with standard update?"; then
        warning_printf "Standard update cancelled by user"
        return 1
    fi
    update_printf "Running npm update..."
    if npm update; then
        success_printf "Standard npm update completed successfully!"
        return 0
    else
        local exit_code=$?
        error_printf "npm update failed with exit code: $exit_code"
        return $exit_code
    fi
}

run_major_update() {
    if [[ $HAS_NCU == false ]]; then
        error_printf "npm-check-updates (ncu) is required for major version updates"
        return 1
    fi
    upgrade_printf "Starting major version update check..."
    if ! ncu; then
        warning_printf "No major updates available or ncu check failed"
        return 1
    fi
    printf "\n"
    warning_printf "⚠️  Major updates can break your project!"
    if [[ $HAS_LOCKFILE == true ]]; then
        warning_printf "This will modify your package.json and $LOCKFILE_TYPE lock file"
    fi
    if ! get_yes_no "Do you want to proceed with major updates?"; then
        warning_printf "Major update cancelled by user"
        return 1
    fi
    if get_yes_no "Create backup of package.json before updating?"; then
        local backup_file="package.json.backup.$(date +%Y%m%d_%H%M%S)"
        cp package.json "$backup_file" && success_printf "Backup created: $backup_file"
    fi
    upgrade_printf "Updating package.json with major versions..."
    if ncu -u && npm install; then
        success_printf "Major version update completed successfully!"
        return 0
    else
        error_printf "Update failed. You may need to resolve conflicts manually."
        return 1
    fi
}

update_version_number() {
    upgrade_printf "Starting version number update..."
    
    # Show current version
    if command -v jq &> /dev/null; then
        local current_version=$(jq -r '.version // "unknown"' package.json 2>/dev/null)
        info_printf "Current version: $current_version"
    fi
    printf "\n"
    
    info_printf "Select version update type:"
    printf "1) Patch version (bug fixes) - e.g., 1.0.0 → 1.0.1\n"
    printf "2) Minor version (new features) - e.g., 1.0.0 → 1.1.0\n"
    printf "3) Major version (breaking changes) - e.g., 1.0.0 → 2.0.0\n"
    printf "4) Set specific version\n"
    printf "0) Cancel\n"
    printf "\n"
    
    local choice
    read -p "Enter your choice (0-4): " choice
    
    case $choice in
        1)
            info_printf "Updating patch version..."
            if get_yes_no "Proceed with patch version update?"; then
                if npm version patch; then
                    success_printf "Patch version updated successfully!"
                    return 0
                else
                    error_printf "Failed to update patch version"
                    return 1
                fi
            else
                warning_printf "Patch update cancelled"
                return 1
            fi
            ;;
        2)
            info_printf "Updating minor version..."
            if get_yes_no "Proceed with minor version update?"; then
                if npm version minor; then
                    success_printf "Minor version updated successfully!"
                    return 0
                else
                    error_printf "Failed to update minor version"
                    return 1
                fi
            else
                warning_printf "Minor update cancelled"
                return 1
            fi
            ;;
        3)
            warning_printf "⚠️  Major version updates indicate breaking changes!"
            if get_yes_no "Proceed with major version update?"; then
                if npm version major; then
                    success_printf "Major version updated successfully!"
                    return 0
                else
                    error_printf "Failed to update major version"
                    return 1
                fi
            else
                warning_printf "Major update cancelled"
                return 1
            fi
            ;;
        4)
            local custom_version
            read -p "Enter the specific version (e.g., 2.1.3): " custom_version
            if [[ -z "$custom_version" ]]; then
                warning_printf "No version specified. Cancelled."
                return 1
            fi
            info_printf "Setting version to: $custom_version"
            if get_yes_no "Proceed with setting custom version?"; then
                if npm version "$custom_version"; then
                    success_printf "Version updated to $custom_version successfully!"
                    return 0
                else
                    error_printf "Failed to update to version $custom_version"
                    return 1
                fi
            else
                warning_printf "Custom version update cancelled"
                return 1
            fi
            ;;
        0)
            warning_printf "Version update cancelled"
            return 1
            ;;
        *)
            warning_printf "Invalid choice. Please enter 0, 1, 2, 3, or 4."
            return 1
            ;;
    esac
}

main() {

    display_header
    printf "\n"
    select_mcp_server

    while true; do
        display_header
        printf "\n"
        validate_environment
        show_package_info

        printf "\n"; info_printf "Choose an option:"
        printf "1) Standard npm update\n"
        printf "2) Major version update\n"
        printf "3) Set MCP Server\n"
        printf "4) Update Version Number\n"
        printf "0) Exit\n"
	printf "\n"
        read -p "Enter your choice (0-4): " choice

	# Default to exit if no input
        if [[ -z "$choice" ]]; then
            choice=0
        fi
        printf "\n"
        case $choice in
            1) run_standard_update ;;
            2) run_major_update ;;
            3) select_mcp_server ;;
            4) update_version_number ;;
            0) warning_printf "Exiting without making any updates"; break ;;
            *) warning_printf "Invalid choice. Please enter 0, 1, 2, 3, or 4." ;;
        esac
        printf "\n"
        if ! get_yes_no "Would you like to perform another operation?"; then break; fi
    done

    success_printf "Npm Package Update completed..."
}

trap 'error_printf "Script interrupted by user" && exit 130' INT
trap 'error_printf "An unexpected error occurred" && exit 1' ERR

main "$@"
