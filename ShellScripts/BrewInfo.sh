#!/bin/zsh

# Brew Info Viewer
# This script provides an interactive menu to view detailed information about Homebrew packages (formulae and casks).

# ============================================================================
# CONFIGURATION
# ============================================================================

# Source function library with error handling
readonly FORMAT_LIBRARY="${FORMAT_LIBRARY:-$HOME/ShellScripts/FLibFormatPrintf.sh}"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Debug mode (set DEBUG=1 to enable verbose output)
readonly DEBUG="${DEBUG:-0}"

# Menu length options
readonly MENU_LENGTH_OPTIONS=(5 10 20)

# ============================================================================
# GLOBAL STATE
# ============================================================================

# Navigation state
scroll_offset=0
MENU_LENGTH=10

# Package data
formulae=()
casks=()
all_packages=()
filtered_packages=()

# Caches for performance
typeset -A package_types
typeset -A outdated_packages
typeset -A info_cache

# Filter state
current_filter="all"  # all|formulae|casks
search_term=""

# Function to display script header
display_header() {
    clear
    format_printf "Brew Info Viewer..." "yellow" "bold"
    printf "\n"
    
    # Show current filter and search state
    local filter_display=""
    case "$current_filter" in
        formulae) filter_display="[Formulae] " ;;
        casks) filter_display="[Casks] " ;;
        *) filter_display="[All] " ;;
    esac
    
    if [[ -n "$search_term" ]]; then
        filter_display="${filter_display}Search: $search_term "
    fi
    
    if [[ -n "$filter_display" ]]; then
        printf "%s\n" "$filter_display"
        printf "\n"
    fi
}

# Function to prompt for menu length
prompt_menu_length() {
    local choice
    local i
    
    printf "Select menu length (items per page):\n"
    i=1
    for opt in "${MENU_LENGTH_OPTIONS[@]}"; do
        printf "%d) %s items\n" "$i" "$opt"
        ((i++))
    done
    printf "\n"
    
    while true; do
        read "choice?Enter choice (default: 3): "
        if [[ -z "$choice" ]]; then
            choice=3
        fi
        if [[ "$choice" =~ ^[1-3]$ ]]; then
            MENU_LENGTH=${MENU_LENGTH_OPTIONS[$((choice))]}
            info_printf "Menu length set to $MENU_LENGTH items per page."
            return 0
        else
            warning_printf "Invalid choice. Please enter a number between 1 and 3."
        fi
    done
}

# Function to get terminal size
get_terminal_size() {
    local lines
    local cols
    
    lines=$(tput lines 2>/dev/null)
    cols=$(tput cols 2>/dev/null)
    
    [[ -z "$lines" || "$lines" -lt 1 ]] && lines=30
    [[ -z "$cols" || "$cols" -lt 1 ]] && cols=80
    
    echo "$lines $cols"
}

# Function to display paged menu
show_paged_menu() {
    local total=${#filtered_packages[@]}
    local page_size=$MENU_LENGTH
    local max_offset
    local end
    local i
    local package
    local display_num
    local outdated_marker

    # Ensure scroll_offset is valid
    [[ $scroll_offset -lt 0 ]] && scroll_offset=0
    max_offset=$((total - page_size))
    [[ $max_offset -lt 0 ]] && max_offset=0
    [[ $scroll_offset -gt $max_offset ]] && scroll_offset=$max_offset

    end=$((scroll_offset + page_size))
    [[ $end -gt $total ]] && end=$total

    # Show page info
    local total_all=${#all_packages[@]}
    if [[ "$current_filter" != "all" || -n "$search_term" ]]; then
        printf "--- Showing %d-%d of %d (filtered from %d) ---\n" $((scroll_offset + 1)) "$end" "$total" "$total_all"
    else
        printf "--- Showing %d-%d of %d ---\n" $((scroll_offset + 1)) "$end" "$total"
    fi

    # Display packages with outdated indicators
    i=1
    for package in "${filtered_packages[@]}"; do
        if (( i > scroll_offset && i <= end )); then
            display_num=$i
            outdated_marker=""
            
            # Check if outdated
            if [[ -n "${outdated_packages[$package]}" ]]; then
                outdated_marker=" [OUTDATED]"
            fi
            
            printf "%d) %s%s\n" "$display_num" "$package" "$outdated_marker"
        fi
        ((i++))
    done

    printf "\n"
    printf "Navigation: g=top G=bottom u=up d=down j=down k=up :=jump 0=exit\n"
    printf "Filters: f=formulae c=casks a=all /=search h=help r=refresh\n"
    printf "\n"
}

# Function to fetch installed packages
fetch_packages() {
    local pkg
    
    info_printf "Fetching installed formulae..."
    formulae=($(brew list --formula 2>/dev/null))
    info_printf "Fetching installed casks..."
    casks=($(brew list --cask 2>/dev/null))
    all_packages=("${formulae[@]}" "${casks[@]}")

    # Populate package type cache
    package_types=()
    for pkg in "${formulae[@]}"; do
        package_types[$pkg]="formula"
    done
    for pkg in "${casks[@]}"; do
        package_types[$pkg]="cask"
    done
    
    # Initialize filtered_packages to show all
    filtered_packages=("${all_packages[@]}")
    
    info_printf "Fetching outdated packages..."
    refresh_outdated_cache
}

# Function to refresh outdated packages cache
refresh_outdated_cache() {
    local outdated_pkg
    
    outdated_packages=()
    while IFS= read -r outdated_pkg; do
        [[ -n "$outdated_pkg" ]] && outdated_packages[$outdated_pkg]=1
    done < <(brew outdated --formula 2>/dev/null; brew outdated --cask 2>/dev/null)
}

# Function to display package counts
show_package_counts() {
    stats_printf "Number of formulae: ${#formulae[@]}"
    stats_printf "Number of casks: ${#casks[@]}"
    stats_printf "Total number of packages: ${#all_packages[@]}"
    if [[ "$current_filter" != "all" || -n "$search_term" ]]; then
        stats_printf "Filtered packages: ${#filtered_packages[@]}"
    fi
    printf "\n"
}

# Function to get package type (formulae or cask)
get_package_type() {
    local package=$1
    local pkg_type=${package_types[$package]}
    
    if [[ -n "$pkg_type" ]]; then
        echo "$pkg_type"
    elif [[ " ${casks[*]} " =~ " ${package} " ]]; then
        echo "cask"
    else
        echo "formula"
    fi
}

# Function to apply current filter and search
apply_filter() {
    local pkg
    
    filtered_packages=()
    
    for pkg in "${all_packages[@]}"; do
        # Apply type filter
        case "$current_filter" in
            formulae)
                [[ "${package_types[$pkg]}" != "formula" ]] && continue
                ;;
            casks)
                [[ "${package_types[$pkg]}" != "cask" ]] && continue
                ;;
        esac
        
        # Apply search filter
        if [[ -n "$search_term" ]]; then
            [[ "${pkg:l}" != *"${search_term:l}"* ]] && continue
        fi
        
        filtered_packages+=("$pkg")
    done
    
    # Reset scroll offset when filter changes
    scroll_offset=0
}

# Function to perform cleanup before exit
cleanup_and_exit() {
    local exit_code=${1:-0}
    
    info_printf "Running brew cleanup..."
    brew cleanup --prune=7d 2>/dev/null
    success_printf "Cleanup complete."
    
    exit $exit_code
}

# Trap handler for clean exit
trap_handler() {
    printf "\n"
    warning_printf "Interrupted by user"
    cleanup_and_exit 1
}

# Function to display package information
show_package_info() {
    local package=$1
    local type
    local type_display
    local prefix_path
    local resolved_path
    local info_output
    
    type=$(get_package_type "$package")
    
    printf "\n"
    info_printf "=== ${package} Information ==="
    printf "\n"
    
    type_display="formula"
    [[ "$type" == "cask" ]] && type_display="cask"
    printf "Type: %s\n" "$type_display"
    
    # Check if outdated
    if [[ -n "${outdated_packages[$package]}" ]]; then
        warning_printf "Status: OUTDATED - Update available"
    fi
    
    if [[ "$type" == "cask" ]]; then
        # For casks, check Caskroom locations
        local caskroom_base=""
        if [[ -d "/opt/homebrew/Caskroom" ]]; then
            caskroom_base="/opt/homebrew/Caskroom"
        elif [[ -d "/usr/local/Caskroom" ]]; then
            caskroom_base="/usr/local/Caskroom"
        fi
        
        if [[ -n "$caskroom_base" && -d "$caskroom_base/$package" ]]; then
            prefix_path="$caskroom_base/$package"
            # Get the version directory (usually the first/only subdirectory)
            resolved_path=$(find "$prefix_path" -mindepth 1 -maxdepth 1 -type d | head -1)
        else
            prefix_path=""
            resolved_path=""
        fi
    else
        prefix_path=$(brew --prefix "$package" 2>/dev/null)
        if [[ -n "$prefix_path" ]]; then
            resolved_path="$prefix_path"
            if [[ -L "$prefix_path" ]]; then
                resolved_path=$(readlink -f "$prefix_path")
            fi
        fi
    fi
    
    if [[ -n "$resolved_path" ]]; then
        printf "Install Path: %s\n" "$resolved_path"
        
        if [[ "$type" == "cask" ]]; then
            # For casks, extract version from path
            if [[ "$resolved_path" =~ /Caskroom/[^/]+/([^/]+)$ ]]; then
                printf "Version: %s\n" "${match[1]}"
            else
                printf "Version: Unknown\n"
            fi
        elif [[ "$resolved_path" =~ /Cellar/([^/]+)/([^/]+)$ ]]; then
            printf "Version: %s\n" "${match[2]}"
        elif [[ "$resolved_path" =~ /opt/homebrew/Cellar/([^/]+)/([^/]+)$ ]]; then
            printf "Version: %s\n" "${match[2]}"
        else
            printf "Version: Unknown\n"
        fi
    else
        printf "Install Path: Not found\n"
        printf "Version: Unknown\n"
    fi
    
    printf "\n"
    info_printf "--- brew info output ---"
    printf "\n"
    
    # Check cache first
    if [[ -n "${info_cache[$package]}" ]]; then
        info_output="${info_cache[$package]}"
    else
        # Fetch and cache with colors enabled
        if [[ "$type" == "cask" ]]; then
            info_output=$(HOMEBREW_COLOR=1 brew info --cask "$package" 2>&1)
        else
            info_output=$(HOMEBREW_COLOR=1 brew info "$package" 2>&1)
        fi
        info_cache[$package]="$info_output"
    fi
    
    printf "%s\n" "$info_output"
    printf "\n"
}

# Function to display help screen
show_help() {
    clear
    format_printf "Brew Info Viewer - Help" "yellow" "bold"
    printf "\n\n"
    
    format_printf "Navigation" "cyan" "bold"
    printf "  g          Jump to top of list\n"
    printf "  G          Jump to bottom of list\n"
    printf "  u          Scroll up half a page\n"
    printf "  d          Scroll down half a page\n"
    printf "  k or ↑     Scroll up one item\n"
    printf "  j or ↓     Scroll down one item\n"
    printf "  :<number>  Jump to specific item number\n"
    printf "  0          Exit the program\n"
    printf "\n"
    
    format_printf "Filters" "cyan" "bold"
    printf "  f          Show formulae only\n"
    printf "  c          Show casks only\n"
    printf "  a          Show all packages\n"
    printf "  /          Search within current filter\n"
    printf "  ESC        Clear search\n"
    printf "\n"
    
    format_printf "Other Commands" "cyan" "bold"
    printf "  r          Refresh package lists and caches\n"
    printf "  h or ?     Show this help screen\n"
    printf "\n"
    
    format_printf "Indicators" "cyan" "bold"
    printf "  [OUTDATED] Package has an update available\n"
    printf "\n"
    
    printf "Press any key to return to the menu..."
    read -k1
}

# Function to handle search input
handle_search() {
    local search_input=""
    local char
    
    # Disable terminal echo to prevent double characters
    stty -echo
    
    # Ensure echo is re-enabled on exit
    trap 'stty echo; trap_handler' INT TERM
    
    printf "\n"
    printf "Search: "
    
    while true; do
        read -k1 char
        
        # Handle special keys
        case "$char" in
            $'\n'|"\r")
                # Enter - apply search
                search_term="$search_input"
                apply_filter
                stty echo
                trap trap_handler INT TERM
                return 0
                ;;
            $'\e')
                # ESC - cancel search
                search_term=""
                apply_filter
                printf "\nSearch cancelled."
                stty echo
                trap trap_handler INT TERM
                sleep 0.5
                return 1
                ;;
            $'\177'|$'\b')
                # Backspace
                if [[ ${#search_input} -gt 0 ]]; then
                    search_input="${search_input:0:-1}"
                    printf "\b \b"
                    search_term="$search_input"
                    apply_filter
                fi
                ;;
            *)
                # Regular character
                if [[ "$char" =~ [a-zA-Z0-9._-] ]]; then
                    search_input="${search_input}${char}"
                    printf "%s" "$char"
                    search_term="$search_input"
                    apply_filter
                fi
                ;;
        esac
    done
}

# Function to handle direct jump
handle_jump() {
    local jump_num=""
    local char
    
    # Disable terminal echo to prevent double characters
    stty -echo
    
    # Ensure echo is re-enabled on exit
    trap 'stty echo; trap_handler' INT TERM
    
    printf "\n"
    printf "Jump to number: "
    
    while true; do
        read -k1 char
        
        case "$char" in
            $'\n'|"\r")
                if [[ "$jump_num" =~ ^[0-9]+$ ]]; then
                    local target=$((jump_num - 1))
                    local max_offset=$((${#filtered_packages[@]} - MENU_LENGTH))
                    [[ $max_offset -lt 0 ]] && max_offset=0
                    
                    if [[ $target -lt 0 ]]; then
                        target=0
                    elif [[ $target -gt $max_offset ]]; then
                        target=$max_offset
                    fi
                    
                    scroll_offset=$target
                fi
                stty echo
                trap trap_handler INT TERM
                return 0
                ;;
            $'\e')
                stty echo
                trap trap_handler INT TERM
                return 1
                ;;
            $'\177'|$'\b')
                if [[ ${#jump_num} -gt 0 ]]; then
                    jump_num="${jump_num:0:-1}"
                    printf "\b \b"
                fi
                ;;
            [0-9])
                jump_num="${jump_num}${char}"
                printf "%s" "$char"
                ;;
        esac
    done
}

# Main script
main() {
    local choice
    local selected_package
    local max_offset
    
    # Check for brew
    if ! command -v brew &>/dev/null; then
        printf "Error: Homebrew (brew) is not installed or not in PATH\n" >&2
        exit 1
    fi
    
    # Set up signal handlers
    trap trap_handler INT TERM
    
    display_header
    fetch_packages
    scroll_offset=0

    if [[ ${#all_packages[@]} -eq 0 ]]; then
        warning_printf "No Homebrew packages found. Exiting."
        cleanup_and_exit 0
    fi

    printf "\n"
    prompt_menu_length

    while true; do
        display_header
        show_package_counts

        if [[ ${#all_packages[@]} -eq 0 ]]; then
            warning_printf "No Homebrew packages found. Exiting."
            cleanup_and_exit 0
        fi

        info_printf "Installed Homebrew packages:"
        show_paged_menu

        # Single-key input
        printf "Command: "
        read -k1 choice
        
        # Handle multi-character inputs
        case "$choice" in
            "g")
                scroll_offset=0
                ;;
            "G")
                max_offset=$((${#filtered_packages[@]} - MENU_LENGTH))
                ((max_offset < 0)) && max_offset=0
                scroll_offset=$max_offset
                ;;
            "u")
                ((scroll_offset -= MENU_LENGTH / 2))
                ((scroll_offset < 0)) && scroll_offset=0
                ;;
            "d")
                max_offset=$((${#filtered_packages[@]} - MENU_LENGTH))
                ((max_offset < 0)) && max_offset=0
                ((scroll_offset += MENU_LENGTH / 2))
                [[ $scroll_offset -gt $max_offset ]] && scroll_offset=$max_offset
                ;;
            "j")
                ((scroll_offset++))
                max_offset=$((${#filtered_packages[@]} - MENU_LENGTH))
                ((max_offset < 0)) && max_offset=0
                [[ $scroll_offset -gt $max_offset ]] && scroll_offset=$max_offset
                ;;
            "k")
                ((scroll_offset--))
                ((scroll_offset < 0)) && scroll_offset=0
                ;;
            "f")
                current_filter="formulae"
                search_term=""
                apply_filter
                info_printf "Filter: Formulae only"
                sleep 0.5
                ;;
            "c")
                current_filter="casks"
                search_term=""
                apply_filter
                info_printf "Filter: Casks only"
                sleep 0.5
                ;;
            "a")
                current_filter="all"
                search_term=""
                apply_filter
                info_printf "Filter: All packages"
                sleep 0.5
                ;;
            "/")
                handle_search
                ;;
            $'\e')
                # Check for ESC (may be followed by other chars in some terminals)
                search_term=""
                apply_filter
                ;;
            "r")
                info_printf "Refreshing package data..."
                formulae=()
                casks=()
                all_packages=()
                filtered_packages=()
                package_types=()
                outdated_packages=()
                info_cache=()
                fetch_packages
                apply_filter
                scroll_offset=0
                success_printf "Refresh complete!"
                sleep 0.5
                ;;
            "h"|"?")
                show_help
                ;;
            ":")
                handle_jump
                ;;
            "0"|"q")
                printf "\n"
                info_printf "Exiting. Brew Info Viewer completed."
                cleanup_and_exit 0
                ;;
            [1-9])
                # Read remaining digits
                local num="$choice"
                local next_char
                while true; do
                    read -t 0.1 -k1 next_char 2>/dev/null || break
                    if [[ "$next_char" =~ [0-9] ]]; then
                        num="${num}${next_char}"
                    else
                        break
                    fi
                done
                
                if [[ "$num" =~ ^[0-9]+$ ]]; then
                    local selection=$num
                    if (( selection <= ${#filtered_packages[@]} )); then
                        selected_package=${filtered_packages[$selection]}
                        
                        display_header
                        show_package_info "$selected_package"
                        
                        printf "\n"
                        printf "Press any key to continue..."
                        read -k1
                    else
                        printf "\n"
                        warning_printf "Invalid selection: $selection"
                        sleep 1
                    fi
                fi
                ;;
            *)
                # Ignore unknown keys
                ;;
        esac
    done
}

# Start the script
main "$@"