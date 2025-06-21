#!/bin/zsh

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { echo "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Get yes/no input
get_yes_no() {
    local prompt="$1"
    local response
    while true; do
        read "response?$prompt (y/n): "
        case ${response:l} in
            y|yes) return 0 ;;
            n|no)  return 1 ;;
            *) printf "Please answer yes (Y) or no (N).\n" ;;
        esac
    done
}

# Optional key prompt
hit_any_key_prompt() {
    if [[ "${hit_any_key:-false}" == "true" ]]; then
        echo -en "\n\n\t\t\tHit any key to continue"
        read -k 1 _
    fi
}

# List of updater scripts with corresponding package names
updaters=("PyUpdate.sh" "PipUpdate.sh" "VimUpdate.sh" "JavaUpdate.sh" "CopiUpdate.sh")
package_names=("Python" "Pip" "Vim" "Java" "Copilot")

# Header
clear
format_printf "Update All Packages..." "yellow" "bold"
printf "\n"

# Display packages that will be updated
for i in {1..${#updaters[@]}}; do
    update_printf "Will update: ${package_names[$i]}"
done
printf "\n"

# Ask if user wants to run all package updates
if get_yes_no "$(format_printf "Do you want to run All Package Updates?" none "rocket")"; then
    
    # Count the number of updaters
    updater_count=${#updaters[@]}
    
    # Prompt before starting
    hit_any_key="true"
    
    # Run each updater safely
    loop_count=0
    for script in "${updaters[@]}"; do
        ((loop_count++))
        clear
        script_path="$HOME/ShellScripts/$script"
        if [[ -x "$script_path" || -f "$script_path" ]]; then
            "$script_path"
        else
            warning_printf "Warning: $script not found or not executable at $script_path"
        fi
        
        # Only prompt if not the last item
        if [[ $loop_count -lt $updater_count ]]; then
            hit_any_key_prompt
        fi
    done
else
    error_printf "Update All Packages cancelled by user."
fi
