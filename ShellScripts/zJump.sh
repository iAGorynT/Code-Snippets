# Function to quickly change directories (zjump)
# Usage: source zJump.zsh

# Directory mappings - easier to maintain and extend
typeset -A ZJUMP_DIRS=(
    [hom]="$HOME"
    [doc]="$HOME/Documents"
    [log]="$HOME/.logs"
    [dt]="$HOME/Desktop"
    [dl]="$HOME/Downloads"
    [ss]="$HOME/ShellScripts"
    [sst]="$HOME/ShellScripts/zTests"
    [py]="$HOME/PythonCode"
    [gha]="$HOME/Documents/GitHub/Brew-Autoupdate"
    [ghs]="$HOME/Documents/GitHub/Code-Snippets"
    [mcp]="$HOME/mcp-servers"
    [peek]="$HOME/Library/GroupContainersAlias/9V456WSURS.com.bigzlabs.peekgroup/Library/Application Support/Styles"
    [oc]="$HOME/Desktop/opencode_workspace"
)

zjump() {
    local target_dir=""
    
    # Show help if no argument or --help flag
    if [[ -z "$1" ]] || [[ "$1" == "--help" ]]; then
        print -P "%F{blue}Usage:%f zjump <shortcut>"
        print -P "%F{blue}Available shortcuts:%f"
        # Sort and display shortcuts
        for key in "${(k)ZJUMP_DIRS[@]}"; do
            printf "  %-12s - %s\n" "$key" "${ZJUMP_DIRS[$key]}"
        done
        print -P "  %F{cyan}<directory_path>%f - Any valid directory path (relative or absolute)"
        return 0
    fi

    # Check if shortcut exists in mappings
    if (( ${+ZJUMP_DIRS[$1]} )); then
        target_dir="${ZJUMP_DIRS[$1]}"
    # Try as direct path if not a shortcut
    elif [[ -d "$1" ]]; then
        target_dir="$1"
    else
        print -P "%F{red}zjump:%f Shortcut '%F{yellow}$1%f' not found or invalid directory."
        return 1
    fi

    # Change directory and show confirmation
    if [[ -n "$target_dir" ]]; then
        cd "$target_dir" && clear && print -P "%F{green}Changed to:%f $target_dir" && echo && ls -a
    fi
}

# Optional: Add command completion
_zjump() {
    local -a shortcuts
    shortcuts=(${(k)ZJUMP_DIRS})
    _describe 'command' shortcuts
}
compdef _zjump zjump
