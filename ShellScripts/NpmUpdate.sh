#!/bin/zsh
# Enhanced npm package update script with simplified menu
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
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
    format_printf "Npm Package Update..." "yellow" "bold" "package"
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

# Cache npm outdated results for reuse
get_npm_outdated() {
    if [[ "$OUTDATED_CACHE_VALID" == true ]]; then
        printf "%s" "$CACHED_OUTDATED_OUTPUT"
        return 0
    fi
    
    # Run npm outdated and cache the result
    CACHED_OUTDATED_OUTPUT=$(npm outdated 2>/dev/null || true)
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
        read "response?$prompt (y/n): "
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

    if command -v npm &> /dev/null; then
        info_printf "Current package status:"
        local outdated_output=$(get_npm_outdated)
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
        read "choice?Enter your choice (1-${#servers[@]}): "
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
    update_printf "Starting standard npm update (minor/patch versions)..."
    info_printf "Checking for available updates..."
    local outdated_output=$(get_npm_outdated)
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
        # Invalidate cache after successful update
        invalidate_outdated_cache
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
        # Invalidate cache after successful update
        invalidate_outdated_cache
        return 0
    else
        error_printf "Update failed. You may need to resolve conflicts manually."
        return 1
    fi
}

run_npm_audit() {
    update_printf "Starting npm audit..."
    
    # Run npm audit and capture output
    local audit_output
    local audit_exit_code
    audit_output=$(npm audit 2>&1)
    audit_exit_code=$?
    
    # Check if vulnerabilities were found (exit code 0 means no vulnerabilities)
    if [[ $audit_exit_code -eq 0 ]]; then
        success_printf "No vulnerabilities found"
        return 0
    else
        # Vulnerabilities were found - ask user if they want to fix
        warning_printf "npm audit found vulnerabilities"
        printf "\n"
        # Display the audit results
        printf "%s\n" "$audit_output"
        printf "\n"
        if ! get_yes_no "Do you want to run 'npm audit fix' to attempt repairs?"; then
            warning_printf "npm audit fix cancelled by user"
            return 1
        fi
        update_printf "Running npm audit fix..."
        if npm audit fix; then
            success_printf "npm audit fix completed successfully!"
	    info_printf "Remember: perform updates, create new MCPB, and update Claude desktop"
            # Invalidate cache after successful audit fix
            invalidate_outdated_cache
            return 0
        else
            local fix_exit_code=$?
            error_printf "npm audit fix failed with exit code: $fix_exit_code"
            warning_printf "Some vulnerabilities may require manual intervention"
            return $fix_exit_code
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
    read "choice?Enter your choice (0-4): "
    
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

compile_typescript() {
    rocket_printf "Compiling TypeScript..."
    printf "\n"
    
    # Get current directory info
    local current_dir=$(pwd)
    info_printf "Current directory: $current_dir"
    
    # Check if package.json exists
    if [[ ! -f "package.json" ]]; then
        error_printf "No package.json found in current directory: $current_dir"
        return 1
    fi
    
    # Check if src/index.ts exists
    if [[ ! -f "src/index.ts" ]]; then
        error_printf "No src/index.ts found in current directory: $current_dir"
        error_printf "TypeScript compilation requires src/index.ts"
        return 1
    fi
    
    # Check if server directory exists
    if [[ ! -d "server" ]]; then
        warning_printf "No server directory found in current directory: $current_dir"
        warning_printf "npm run build may not work as expected"
    fi
    
    info_printf "This will compile TypeScript (src/index.ts) to JavaScript (server/index.js)"
    printf "\n"
    
    if ! get_yes_no "Do you want to compile TypeScript?"; then
        warning_printf "TypeScript compilation cancelled by user"
        return 0
    fi
    
    # Step 1: npm install
    update_printf "Step 1: Running npm install to ensure all dependencies are present..."
    if npm install; then
        success_printf "npm install completed successfully!"
    else
        local exit_code=$?
        error_printf "npm install failed with exit code: $exit_code"
        return $exit_code
    fi
    printf "\n"
    
    # Step 2: npm run build
    update_printf "Step 2: Running npm run build"
    printf "\n"
    
    # Run the build command
    if npm run build; then
        success_printf "TypeScript compilation completed successfully!"
        
        # Check if server/index.js was created
        if [[ -f "server/index.js" ]]; then
            success_printf "Generated output file: server/index.js"
        fi
        
        return 0
    else
        local exit_code=$?
        error_printf "TypeScript compilation failed with exit code: $exit_code"
        return $exit_code
    fi
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
    
    # Get current directory info
    local current_dir=$(pwd)
    info_printf "Current directory: $current_dir"
    
    # Check if required utilities exist
    if ! command -v npm &> /dev/null; then
        error_printf "npm is not installed or not in PATH"
        error_printf "npm is required for MCP Server Test"
        return 1
    fi
    
    if ! command -v node &> /dev/null; then
        error_printf "node is not installed or not in PATH"
        error_printf "node is required for MCP Server Test"
        return 1
    fi
    
    # Check if required files exist
    if [[ ! -f "package.json" ]]; then
        error_printf "No package.json found in current directory: $current_dir"
        error_printf "MCP Server Test requires a valid Node.js project"
        return 1
    fi
    
    if [[ ! -f "test.js" ]]; then
        error_printf "No test.js found in current directory: $current_dir"
        error_printf "MCP Server Test requires a test.js file"
        return 1
    fi
    
    if [[ ! -f "server/index.js" ]]; then
        warning_printf "No server/index.js found in current directory: $current_dir"
        warning_printf "npm start may not work properly without a main entry point"
    fi
    
    info_printf "MCP Server Test will perform the following steps:"
    printf "  1) Run npm install\n"
    printf "  2) Run node test.js\n"
    printf "  3) Run npm start (press Ctrl-C to stop)\n"
    printf "\n"
    
    if ! get_yes_no "Do you want to run MCP Server Test?"; then
        warning_printf "MCP Server Test cancelled by user"
        return 0
    fi
    
    # Step 1: npm install
    update_printf "Step 1: Running npm install..."
    if npm install; then
        success_printf "npm install completed successfully!"
    else
        local exit_code=$?
        error_printf "npm install failed with exit code: $exit_code"
        return $exit_code
    fi
    printf "\n"
    
    # Step 2: node test.js
    update_printf "Step 2: Running node test.js..."
    if node test.js; then
        success_printf "node test.js completed successfully!"
    else
        local exit_code=$?
        error_printf "node test.js failed with exit code: $exit_code"
        warning_printf "Continuing to npm start despite test failure..."
    fi
    printf "\n"
    
    # Step 3: npm start - improved process management
    update_printf "Step 3: Starting npm start for 3-4 seconds..."
    printf "\n"
    
    update_printf "Running npm start..."
    
    # Start npm in a new process group
    setsid npm start > /dev/null 2>&1 &
    local npm_pid=$!
    
    # Let it run for 3-4 seconds
    sleep 4
    
    # Kill the npm process and its entire process group
    info_printf "Stopping npm start process (PID: $npm_pid)..."
    
    # Get the process group ID
    local pgid
    pgid=$(ps -o pgid= -p $npm_pid 2>/dev/null | tr -d ' ')
    
    if [[ -n "$pgid" ]]; then
        # Kill the entire process group
        if kill -TERM -$pgid 2>/dev/null; then
            # Wait up to 2 seconds for graceful shutdown
            local timeout=0
            while kill -0 -$pgid 2>/dev/null && [[ $timeout -lt 20 ]]; do
                sleep 0.1
                ((timeout++))
            done
            
            # Force kill if still running
            if kill -0 -$pgid 2>/dev/null; then
                kill -KILL -$pgid 2>/dev/null
                warning_printf "npm start process force-killed"
            else
                success_printf "npm start process stopped successfully"
            fi
        else
            warning_printf "npm start process may have already terminated"
        fi
    else
        warning_printf "Could not determine process group - process may have already terminated"
    fi
    
    # Additional cleanup: find and kill any remaining node processes from this test
    pkill -P $npm_pid 2>/dev/null || true
    
    # Wait a moment for cleanup
    sleep 1
    
    success_printf "MCP Server Test completed!"
    return 0
}

main() {

    display_header
    # Ask if user wants to run npm package update
    if ! get_yes_no "$(format_printf "Do you want to run Npm Package Update?" none "rocket")"; then
        error_printf "Npm Package Update cancelled by user"
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
        printf "1) Standard npm update\n"
        printf "2) Major version update\n"
        printf "3) Update Package Version Number\n"
        printf "4) Compile TypeScript\n"
        printf "5) MCP Server Test\n"
        printf "6) Create Claude Extension File (MCPB)\n"
        printf "7) Set MCP Server\n"
        printf "8) Run npm audit\n"
        printf "0) Exit\n"
        printf "\n"
        read "choice?Enter your choice (0-8): "

	# Default to exit if no input
        if [[ -z "$choice" ]]; then
            choice=0
        fi
        printf "\n"
        case $choice in
            1) run_standard_update ;;
            2) run_major_update ;;
            # Use || true to ignore the exit code
            3) update_version_number || true ;;
            4) compile_typescript ;;
            5) mcp_server_test ;;
            6) create_mcpb_file ;;
            7) select_mcp_server ;;
            8) run_npm_audit ;;
            0) warning_printf "Exiting without making any updates"; break ;;
            *) warning_printf "Invalid choice. Please enter 1, 2, 3, 4, 5, 6, 7, 8, or 0." ;;
        esac
        printf "\n"
        if ! get_yes_no "Would you like to perform another operation?"; then break; fi
    done

    success_printf "Npm Package Update completed..."
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
