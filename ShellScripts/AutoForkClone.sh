#!/bin/zsh
# AutoForkClone.sh
# Automates GitHub fork → clone → setup (with optional feature branch)
# Repos are cloned into $HOME/Documents/GitHub

# --- CONFIG ---
BASE_DIR="$HOME/Documents/GitHub"

# --- FUNCTIONS ---
usage() {
  cat << EOF
Usage: $0 [<github-repo-url>] [feature-branch-name]

If no URL is provided, you'll be prompted to enter one.

Examples:
  $0 https://github.com/someuser/project
  $0 https://github.com/someuser/project feature/update-readme
  $0  # Interactive mode - prompts for URL

EOF
  exit 1
}

validate_url() {
  local url="$1"
  if [[ ! "$url" =~ ^https://github\.com/[^/]+/[^/]+/?$ ]]; then
    echo "❌ Invalid GitHub URL format. Expected: https://github.com/username/repo"
    return 1
  fi
  return 0
}

check_gh_auth() {
  if ! gh auth status &>/dev/null; then
    echo "❌ Not authenticated with GitHub CLI. Please run: gh auth login"
    exit 1
  fi
}

# --- MAIN ---
[[ "$1" == "-h" || "$1" == "--help" ]] && usage

# Check GitHub CLI authentication first
check_gh_auth

# Get GitHub username
GITHUB_USER=$(gh api user --jq .login 2>/dev/null)
if [[ -z "$GITHUB_USER" ]]; then
  echo "❌ Failed to get GitHub username. Check your authentication."
  exit 1
fi

# Get repo URL (from argument or prompt)
if [[ -z "$1" ]]; then
  read -r "REPO_URL?Enter the GitHub repository URL to fork: "
  REPO_URL="${REPO_URL## }"  # Trim leading whitespace
  REPO_URL="${REPO_URL%% }"  # Trim trailing whitespace
  [[ -z "$REPO_URL" ]] && { echo "❌ No URL provided"; exit 1; }
else
  REPO_URL="$1"
fi

# Remove trailing slash if present
REPO_URL="${REPO_URL%/}"

# Validate URL
validate_url "$REPO_URL" || exit 1

# Parse repo information
REPO_NAME=$(basename "$REPO_URL" .git)
ORIGINAL_USER=$(echo "$REPO_URL" | sed -E 's#https://github\.com/([^/]+)/.*#\1#')

# Check if forking your own repo
if [[ "$ORIGINAL_USER" == "$GITHUB_USER" ]]; then
  read -r "response?⚠️  This is already your repository. Do you want to just clone it? (y/n) "
  if [[ "$response" =~ ^[Yy]$ ]]; then
    FORK_URL="$REPO_URL"
    SKIP_FORK=true
  else
    echo "Operation cancelled."
    exit 0
  fi
else
  FORK_URL="https://github.com/$GITHUB_USER/$REPO_NAME.git"
  SKIP_FORK=false
fi

# Get optional feature branch (from argument or prompt)
if [[ -z "$2" ]]; then
  read -r "FEATURE_BRANCH?Enter feature branch name (press Enter to skip): "
else
  FEATURE_BRANCH="$2"
fi

LOCAL_PATH="$BASE_DIR/$REPO_NAME"

# Display configuration
echo "\n📋 Configuration:"
echo "🔗 Original repo: $REPO_URL"
echo "📦 Repo name: $REPO_NAME"
echo "👤 GitHub user: $GITHUB_USER"
echo "📂 Target directory: $LOCAL_PATH"
[[ -n "$FEATURE_BRANCH" ]] && echo "🌿 Feature branch: $FEATURE_BRANCH"

# Check if directory already exists
if [[ -d "$LOCAL_PATH" ]]; then
  echo "\n⚠️  Directory already exists: $LOCAL_PATH"
  echo "Choose an action:"
  echo "  1) Delete and re-clone"
  echo "  2) Skip cloning and just setup remotes"
  echo "  3) Cancel"
  read -r "choice?Enter choice (1-3): "
  
  case "$choice" in
    1)
      echo "🗑️  Removing existing directory..."
      rm -rf "$LOCAL_PATH"
      ;;
    2)
      SKIP_CLONE=true
      cd "$LOCAL_PATH" || exit 1
      ;;
    *)
      echo "Operation cancelled."
      exit 0
      ;;
  esac
fi

# Ensure base directory exists
mkdir -p "$BASE_DIR"

# --- FORK ---
if [[ "$SKIP_FORK" != true ]]; then
  echo "\n🍴 Forking $REPO_NAME to your account..."
  
  # Check if fork already exists
  if gh repo view "$GITHUB_USER/$REPO_NAME" &>/dev/null; then
    echo "✅ Fork already exists in your account"
  else
    if ! gh repo fork "$REPO_URL" --clone=false --remote=false; then
      echo "❌ Fork failed. Check repository access and permissions."
      exit 1
    fi
    echo "⏳ Waiting for fork to be ready..."
    sleep 3
  fi
fi

# --- CLONE ---
if [[ "$SKIP_CLONE" != true ]]; then
  cd "$BASE_DIR" || { echo "❌ Cannot access $BASE_DIR"; exit 1; }
  
  echo "\n📥 Cloning your fork..."
  if ! git clone "$FORK_URL"; then
    echo "❌ Clone failed. Check network connection and repository access."
    exit 1
  fi
  
  cd "$REPO_NAME" || { echo "❌ Cannot access cloned directory"; exit 1; }
fi

# --- UPSTREAM ---
if [[ "$SKIP_FORK" != true ]]; then
  echo "\n🔗 Adding upstream remote..."
  
  # Remove existing upstream if present
  git remote remove upstream &>/dev/null
  
  if ! git remote add upstream "$REPO_URL"; then
    echo "⚠️  Failed to add upstream remote (may already exist)"
  fi
fi

echo "\n✅ Current remotes:"
git remote -v

# --- OPTIONAL FEATURE BRANCH ---
if [[ -n "$FEATURE_BRANCH" ]]; then
  echo "\n🌿 Creating feature branch: $FEATURE_BRANCH"
  
  # Validate branch name
  if ! git check-ref-format --branch "$FEATURE_BRANCH" &>/dev/null; then
    echo "⚠️  Invalid branch name format. Using default branch."
  elif git rev-parse --verify "$FEATURE_BRANCH" &>/dev/null; then
    echo "⚠️  Branch already exists. Switching to it..."
    git checkout "$FEATURE_BRANCH"
  else
    git checkout -b "$FEATURE_BRANCH"
    echo "✅ Branch '$FEATURE_BRANCH' created and checked out"
  fi
else
  echo "\n💡 No feature branch specified. Staying on default branch."
fi

# --- FINAL SUMMARY ---
cat << EOF

──────────────────────────────────────────────
🎉 Setup Complete!
──────────────────────────────────────────────
📂 Local path : $LOCAL_PATH
🌐 Fork URL   : $FORK_URL
🔗 Upstream   : $REPO_URL
$([ -n "$FEATURE_BRANCH" ] && echo "🌿 Branch     : $FEATURE_BRANCH")
──────────────────────────────────────────────
Next steps:
  cd "$LOCAL_PATH"
  
  # Make your changes, then:
  git add .
  git commit -m "Your descriptive commit message"
  git push origin ${FEATURE_BRANCH:-main}
  
  # Create a pull request:
  gh pr create --web
──────────────────────────────────────────────

EOF
