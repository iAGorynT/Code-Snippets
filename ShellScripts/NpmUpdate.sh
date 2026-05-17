#!/bin/zsh
# Enhanced npm package update script with simplified menu

# Source function library with error handling

SCRIPT_DIR="${0:a:h}"
FORMAT_LIBRARY="$SCRIPT_DIR/FLibFormatPrintf.sh"

if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    printf "Error: Required library not found: %s\n" "$FORMAT_LIBRARY" >&2
    printf "Searched in script directory: %s\n" "$SCRIPT_DIR" >&2
    exit 1
fi

source "$FORMAT_LIBRARY"

SCRIPT_DIR=""
HAS_PACKAGE_JSON=false
HAS_NCU=false
HAS_LOCKFILE=false
LOCKFILE_TYPE=""
CACHED_OUTDATED_OUTPUT=""
OUTDATED_CACHE_VALID=false

display_header() {
    clear
    format_printf "Npm/Bun Package Update..." "yellow" "bold" "package"
}

# Sanitize input from package.json to prevent command injection
sanitize_json_string() {
    local input="$1"
    # Remove any characters that could be dangerous in shell context
    # Keep only alphanumeric, spaces, dots, hyphens, underscores, and forward slashes
    printf "%s" "$input" | sed 's/[^a-zA-Z0-9 .\/_-]//g'
}

# Safely read package.json field using jq with sanitization
safe_jq_read() {
    local file="$1"
    local field="$2"
    local default="$3"
    
    if [[ ! -f "$file" ]]; then
        printf "%s" "$default"
        return 1
    fi
    
    # Validate that file is actually readable and appears to be JSON
    if ! head -n 1 "$file" 2>/dev/null | grep -q '^[[:space:]]*{' ; then
        printf "%s" "$default"
        return 1
    fi
    
    local result
    result=$(jq -r "$field // \"$default\"" "$file" 2>/dev/null)
    
    # Sanitize the output
    sanitize_json_string "$result"
}

# Validate and canonicalize path to prevent path traversal
validate_path() {
    local path="$1"
    local base_path="$2"
    
    # Resolve to absolute path
    local abs_path
    abs_path=$(cd "$path" 2>/dev/null && pwd) || return 1
    
    # Ensure path is under base_path
    if [[ "$abs_path" != "$base_path"* ]]; then
        return 1
    fi
    
    printf "%s" "$abs_path"
    return 0
}

# Cache outdated results for reuse
get_outdated() {
    if [[ "$OUTDATED_CACHE_VALID" == true ]]; then
        printf "%s" "$CACHED_OUTDATED_OUTPUT"
        return 0
    fi

    local cmd
    if [[ "$LOCKFILE_TYPE" == "bun" ]]; then
        cmd="bun outdated"
    else
        cmd="npm outdated"
    fi

    CACHED_OUTDATED_OUTPUT=$($cmd 2>/dev/null || true)
    OUTDATED_CACHE_VALID=true

    printf "%s" "$CACHED_OUTDATED_OUTPUT"
}

# Invalidate the outdated cache (call after updates)
invalidate_outdated_cache() {
    OUTDATED_CACHE_VALID=false
    CACHED_OUTDATED_OUTPUT=""
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

    if ! command -v npm &> /dev/null && ! command -v bun &> /dev/null; then
        error_printf "Neither npm nor bun is installed or not in PATH" true
    fi

    if command -v bun &> /dev/null; then
        info_printf "bun is available"
    fi

    if [[ -f "bun.lock" ]]; then
        HAS_LOCKFILE=true
        LOCKFILE_TYPE="bun"
        info_printf "Detected bun.lock (Bun project)"
    elif [[ -f "package-lock.json" ]]; then
        HAS_LOCKFILE=true
        LOCKFILE_TYPE="npm"
        info_printf "Detected package-lock.json (npm project)"
    elif [[ -f "yarn.lock" ]]; then
        HAS_LOCKFILE=true
        LOCKFILE_TYPE="yarn"
        info_printf "Detected yarn.lock (Yarn project)"
        warning_printf "This script is optimized for npm - yarn operations may behave differently"
    fi

    if command -v npm &> /dev/null; then
        if command -v ncu &> /dev/null; then
            HAS_NCU=true
            success_printf "npm-check-updates (ncu) is available"
        elif [[ "$LOCKFILE_TYPE" != "bun" ]]; then
            warning_printf "npm-check-updates (ncu) is not installed"
            warning_printf "Major version updates via ncu will not be available"
            warning_printf "Install with: npm install -g npm-check-updates"
        fi
    fi
    printf "\n"
}

# Get yes/no input
get_yes_no() {
    local prompt="$1"
    local response
    while true; do
        read -k 1 "response?$prompt (y/n): "
        printf '\n'  # <-- newline using printf
        case ${response:l} in
            y) return 0 ;;
            n) return 1 ;;
            *) error_printf "Please answer yes (Y) or no (N)." ;;
        esac
    done
}

show_package_info() {
    if [[ ! -f "package.json" ]]; then return 1; fi
    info_printf "Current project information:"
    if command -v jq &> /dev/null; then
        local name=$(safe_jq_read "package.json" ".name" "unnamed")
        local version=$(safe_jq_read "package.json" ".version" "unknown")
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

    if command -v npm &> /dev/null || command -v bun &> /dev/null; then
        info_printf "Current package status:"
        local outdated_output=$(get_outdated)
        if [[ -n "$outdated_output" ]]; then
            printf "%s\n" "$outdated_output"
        else
            success_printf "All packages appear to be up to date"
        fi
    fi
}

select_mcp_server() {
    # Validate and canonicalize base path
    local mcp_base="$HOME/mcp-servers"
    local validated_base
    
    if [[ ! -d "$mcp_base" ]]; then
        error_printf "Directory $mcp_base not found"
        return 1
    fi
    
    validated_base=$(cd "$mcp_base" 2>/dev/null && pwd) || {
        error_printf "Failed to access $mcp_base"
        return 1
    }
    
    info_printf "Scanning for MCP servers in $validated_base..."
    
    local servers=()
    local server_names=()
    
    # Find directories containing package.json with optimized single-pass reading
    for dir in "$validated_base"/*/; do
        # Validate each subdirectory path
        local validated_dir
        validated_dir=$(validate_path "$dir" "$validated_base") || continue
        
        if [[ -f "$validated_dir/package.json" ]]; then
            local dir_name=$(basename "$validated_dir")
            servers+=("$validated_dir")
            
            # Use safe_jq_read to get the name with sanitization
            if command -v jq &> /dev/null; then
                local name=$(safe_jq_read "$validated_dir/package.json" ".name" "$dir_name")
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
    for i in {1..${#servers[@]}}; do
        printf "%d) %s\n" "$i" "${server_names[$i]}"
    done
    printf "\n"
    
    local choice
    while true; do
        read -k 1 "choice?Enter your choice (1-${#servers[@]}): "
        printf "\n"
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#servers[@]} ]]; then
            local selected_dir="${servers[$choice]}"
            success_printf "Selected: ${server_names[$choice]}"
            success_printf "Changing to directory: $selected_dir"
            cd "$selected_dir" || {
                error_printf "Failed to change to directory: $selected_dir"
                return 1
            }
            # Invalidate cache when changing directories
            invalidate_outdated_cache
            return 0
        else
            warning_printf "Invalid choice. Please enter a number between 1 and ${#servers[@]}."
        fi
    done
}

run_standard_update() {
    local cmd="npm"
    local label="npm"
    if [[ "$LOCKFILE_TYPE" == "bun" ]]; then
        cmd="bun"
        label="Bun"
    fi

    update_printf "Starting standard ${label} update (minor/patch versions)..."
    info_printf "Checking for available updates..."
    local outdated_output=$(get_outdated)
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
    update_printf "Running ${cmd} update..."
    if $cmd update; then
        success_printf "Standard ${label} update completed successfully!"
        invalidate_outdated_cache
        return 0
    else
        local exit_code=$?
        error_printf "${cmd} update failed with exit code: $exit_code"
        return $exit_code
    fi
}

run_major_update() {
    if [[ "$LOCKFILE_TYPE" == "bun" ]]; then
        upgrade_printf "Starting major version update check via bun update --latest..."
        local outdated_output=$(get_outdated)
        if [[ -z "$outdated_output" ]]; then
            success_printf "All packages are already up to date!"
            return 0
        else
            printf "%s\n" "$outdated_output"
        fi
        printf "\n"
        warning_printf "Major updates can break your project!"
        warning_printf "This will modify your package.json and bun.lock"
        if ! get_yes_no "Do you want to proceed with major updates?"; then
            warning_printf "Major update cancelled by user"
            return 1
        fi
        if get_yes_no "Create backup of package.json before updating?"; then
            local backup_file="package.json.backup.$(date +%Y%m%d_%H%M%S)"
            cp package.json "$backup_file" && success_printf "Backup created: $backup_file"
        fi
        upgrade_printf "Running bun update --latest..."
        if bun update --latest; then
            success_printf "Major version update completed successfully!"
            invalidate_outdated_cache
            return 0
        else
            error_printf "Update failed. You may need to resolve conflicts manually."
            return 1
        fi
    fi

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
    warning_printf "Major updates can break your project!"
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
        invalidate_outdated_cache
        return 0
    else
        error_printf "Update failed. You may need to resolve conflicts manually."
        return 1
    fi
}

run_audit() {
    local cmd="npm"
    local label="npm"
    if [[ "$LOCKFILE_TYPE" == "bun" ]]; then
        cmd="bun"
        label="Bun"
    fi

    update_printf "Starting ${label} audit..."
    local audit_output
    local audit_exit_code
    audit_output=$($cmd audit 2>&1)
    audit_exit_code=$?

    if [[ $audit_exit_code -eq 0 ]]; then
        success_printf "No vulnerabilities found"
        return 0
    else
        warning_printf "${label} audit found vulnerabilities"
        printf "\n"
        printf "%s\n" "$audit_output"
        printf "\n"

        if [[ "$LOCKFILE_TYPE" == "bun" ]]; then
            if ! get_yes_no "Do you want to run 'bun update' to attempt repairs?"; then
                warning_printf "bun update cancelled by user"
                return 1
            fi
            if get_yes_no "Use --latest flag? (May introduce breaking changes)"; then
                update_printf "Running bun update --latest..."
                if bun update --latest; then
                    success_printf "bun update completed successfully!"
                    invalidate_outdated_cache
                    return 0
                else
                    error_printf "bun update failed"
                    return 1
                fi
            else
                update_printf "Running bun update..."
                if bun update; then
                    success_printf "bun update completed successfully!"
                    invalidate_outdated_cache
                    return 0
                else
                    error_printf "bun update failed"
                    return 1
                fi
            fi
        else
            local audit_force_flag=""
            if ! get_yes_no "Do you want to run 'npm audit fix' to attempt repairs?"; then
                warning_printf "npm audit fix cancelled by user"
                return 1
            fi
            if get_yes_no "Do you want to append --force to the npm audit fix command? (May introduce breaking changes)"; then
                audit_force_flag="--force"
            fi
            update_printf "Running npm audit fix..."
            if npm audit fix $audit_force_flag; then
                success_printf "npm audit fix completed successfully!"
                info_printf "Remember: perform updates, create new MCPB, and update Claude desktop"
                invalidate_outdated_cache
                return 0
            else
                local fix_exit_code=$?
                error_printf "npm audit fix failed with exit code: $fix_exit_code"
                warning_printf "Some vulnerabilities may require manual intervention"
                return $fix_exit_code
            fi
        fi
    fi
}

update_version_number() {
    upgrade_printf "Version Number Update..."
    
    # Show current version
    if command -v jq &> /dev/null && [[ -f "package.json" ]]; then
        local current_version=$(safe_jq_read "package.json" ".version" "unknown")
        info_printf "Current version: $current_version"
    fi
    
    printf "\n"; info_printf "Select version update type:"
    printf "1) Patch version (bug fixes) - Example: 1.0.0 → 1.0.1\n"
    printf "2) Minor version (new features) - Example: 1.0.0 → 1.1.0\n"
    printf "3) Major version (breaking changes) - Example: 1.0.0 → 2.0.0\n"
    printf "4) Set specific version\n"
    printf "0) Cancel\n"
    printf "\n"
    
    local choice
    read -k 1 "choice?Enter your choice (0-4): "
    
    if [[ -z "$choice" ]]; then
        choice=0
    fi
    
    printf "\n"
    
    case $choice in
        1)
            info_printf "Updating patch version..."
            if npm version patch --silent; then
                success_printf "Patch version updated successfully!"
                return 0
            else
                error_printf "Failed to update patch version"
                return 1
            fi
            ;;
        2)
            info_printf "Updating minor version..."
            if npm version minor --silent; then
                success_printf "Minor version updated successfully!"
                return 0
            else
                error_printf "Failed to update minor version"
                return 1
            fi
            ;;
        3)
            warning_printf "Major version updates indicate breaking changes!"
            if ! get_yes_no "Are you sure you want to update the major version?"; then
                warning_printf "Major version update cancelled"
                return 1
            fi
            info_printf "Updating major version..."
            if npm version major --silent; then
                success_printf "Major version updated successfully!"
                return 0
            else
                error_printf "Failed to update major version"
                return 1
            fi
            ;;
        4)
            local new_version
            read "new_version?Enter specific version (format: X.Y.Z): "
            if [[ -z "$new_version" ]]; then
                warning_printf "No version specified. Operation cancelled."
                return 1
            fi
            # Basic validation for version format
            if [[ ! "$new_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                error_printf "Invalid version format. Please use X.Y.Z format (e.g., 2.1.3)"
                return 1
            fi
            info_printf "Setting version to $new_version..."
            if npm version "$new_version" --silent; then
                success_printf "Version set to $new_version successfully!"
                return 0
            else
                error_printf "Failed to set version to $new_version"
                return 1
            fi
            ;;
        0)
            warning_printf "Version update cancelled"
            return 0
            ;;
        *)
            warning_printf "Invalid choice. Please enter 0, 1, 2, 3, or 4."
            return 0
            ;;
    esac
}

create_mcpb_file() {
    rocket_printf "Creating Claude Extension File (MCPB)..."
    printf "\n"
    
    # Check if npx is available
    if ! command -v npx &> /dev/null; then
        error_printf "npx is not installed or not in PATH"
        error_printf "npx is required to run @anthropic-ai/mcpb"
        return 1
    fi
    
    # Get current directory info
    local current_dir=$(pwd)
    local dir_name=$(basename "$current_dir")
    
    info_printf "Current directory: $current_dir"
    info_printf "This will create a MCPB file from the current directory contents"
    printf "\n"
    
    if ! get_yes_no "Do you want to create a MCPB file from the current directory?"; then
        warning_printf "MCPB creation cancelled by user"
        return 0
    fi
    
    update_printf "Running: npx @anthropic-ai/mcpb pack"
    printf "\n"
    
    # Run the mcpb pack command
    if npx @anthropic-ai/mcpb pack; then
        success_printf "MCPB file created successfully!"
        
        # Look for the generated MCPB file
        local mcpb_files=(*.mcpb)
        if [[ -f "${mcpb_files[1]}" ]]; then
            success_printf "Generated MCPB file: ${mcpb_files[1]}"
        fi
        
        return 0
    else
        local exit_code=$?
        error_printf "MCPB creation failed with exit code: $exit_code"
        return $exit_code
    fi
}

mcp_server_test() {
    rocket_printf "MCP Server Test..."
    printf "\n"

    local current_dir=$(pwd)
    info_printf "Current directory: $current_dir"

    local cmd="npm"
    local label="npm"
    if [[ "$LOCKFILE_TYPE" == "bun" ]]; then
        cmd="bun"
        label="Bun"
    fi

    info_printf "MCP Server Test will perform the following:"
    printf "  1) Run ${cmd} install\n"
    printf "  2) Run ${cmd} test\n"
    printf "  3) Run ${cmd} start (press Ctrl-C to stop)\n"
    printf "\n"

    if ! get_yes_no "Do you want to run MCP Server Test?"; then
        warning_printf "MCP Server Test cancelled by user"
        return 0
    fi

    # Check that the required package manager exists
    if ! command -v "$cmd" &> /dev/null; then
        error_printf "${cmd} is not installed or not in PATH"
        error_printf "${cmd} is required for MCP Server Test"
        return 1
    fi

    # For npm projects, check if tsx is available
    if [[ "$LOCKFILE_TYPE" != "bun" ]]; then
        if ! command -v tsx &> /dev/null; then
            error_printf "tsx is not installed. Please run 'npm install' first."
            return 1
        fi
    fi

    if [ ! -f "test.ts" ]; then
        error_printf "test.ts not found in current directory."
        return 1
    fi
    printf "\n"

    # Step 1: install
    update_printf "Step 1: Running ${cmd} install..."
    if $cmd install; then
        success_printf "${cmd} install completed successfully!"
    else
        local exit_code=$?
        error_printf "${cmd} install failed with exit code: $exit_code"
        return $exit_code
    fi
    printf "\n"

    # Step 2: Run the mcp server tests
    update_printf "Step 2: Running mcp server tests..."
    if [[ "$LOCKFILE_TYPE" == "bun" ]]; then
        bun run test
    else
        npm test
    fi
    printf "\n"

    # Step 3: start - improved process management
    update_printf "Step 3: Starting ${cmd} start for 3-4 seconds..."
    printf "\n"

    update_printf "Running ${cmd} start..."

    # Start in a new process group
    setsid $cmd start > /dev/null 2>&1 &
    local server_pid=$!

    sleep 4

    info_printf "Stopping ${cmd} start process (PID: $server_pid)..."

    local pgid
    pgid=$(ps -o pgid= -p $server_pid 2>/dev/null | tr -d ' ')

    if [[ -n "$pgid" ]]; then
        if kill -TERM -$pgid 2>/dev/null; then
            local timeout=0
            while kill -0 -$pgid 2>/dev/null && [[ $timeout -lt 20 ]]; do
                sleep 0.1
                ((timeout++))
            done

            if kill -0 -$pgid 2>/dev/null; then
                kill -KILL -$pgid 2>/dev/null
                warning_printf "${cmd} start process force-killed"
            else
                success_printf "${cmd} start process stopped successfully"
            fi
        else
            warning_printf "${cmd} start process may have already terminated"
        fi
    else
        warning_printf "Could not determine process group - process may have already terminated"
    fi

    pkill -P $server_pid 2>/dev/null || true

    sleep 1

    success_printf "MCP Server Test completed!"
    return 0
}

main() {

    display_header
    # Ask if user wants to run npm package update
    if ! get_yes_no "$(format_printf "Do you want to run Npm/Bun Package Update?" none "rocket")"; then
        error_printf "Npm/Bun Package Update cancelled by user"
        return 0
    fi
    printf "\n"
    select_mcp_server

    while true; do
        display_header
        printf "\n"
        validate_environment
        show_package_info

        printf "\n"; info_printf "Choose an option:"
        printf "1) Standard package update\n"
        printf "2) Major version update\n"
        printf "3) Update Package Version Number\n"
        printf "4) MCP Server Test\n"
        printf "5) Create Claude Extension File (MCPB)\n"
        printf "6) Run security audit\n"
        printf "7) Set MCP Server\n"
        printf "0) Exit\n"
        printf "\n"
        printf "Enter your choice (0-7): "
        read -k 1 choice
	
        # Remove any whitespace
        choice=$(echo $choice | tr -d '[:space:]')

        # Check for exit by user
        if [[ -z "$choice" ]]; then
            choice=0
            printf "\n"
        elif [[ "$choice" == "0" ]]; then
            printf "\n\n"
        else
            printf "\n"
        fi

        case $choice in
            1) run_standard_update ;;
            2) run_major_update ;;
            # Use || true to ignore the exit code
            3) update_version_number || true ;;
            4) mcp_server_test ;;
            5) create_mcpb_file ;;
            6) run_audit ;;
            7) select_mcp_server ;;
            0) warning_printf "Exiting without making any updates"; break ;;
            *) warning_printf "Invalid choice. Please enter 1, 2, 3, 4, 5, 6, 7, or 0." ;;
        esac
        printf "\n"
        if ! get_yes_no "Would you like to perform another operation?"; then break; fi
    done

    success_printf "Npm/Bun Package Update completed..."
}

trap '
    exit_code=$?
    # Ignore intentional "return 1" (used for user cancel or expected branch)
    if [[ $exit_code -ne 0 && $exit_code -ne 1 ]]; then
        error_printf "An unexpected error occurred (exit code: $exit_code)"
        exit $exit_code
    fi
' ERR
trap 'error_printf "Script interrupted by user" && exit 130' INT

main "$@"
