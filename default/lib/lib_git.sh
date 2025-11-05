################################################################################
#                                 FILE INFO
# Library for git repository operations
# Supports both normal repos and worktree repos
################################################################################

# Check if current directory is a git worktree
# Worktrees have .git as a file (not directory) containing "gitdir:" reference
is_worktree() {
    [ -f ".git" ] && grep -q "^gitdir:" .git 2>/dev/null
}

# Get current branch name
get_current_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || echo ""
}

# Get default branch for repository
# Works for both normal repos and worktrees
get_default_branch() {
    local branch=""

    # Method 1: For worktrees, read from .bare/HEAD
    if is_worktree && [ -f ".git" ]; then
        local gitdir=$(grep "^gitdir:" .git | cut -d' ' -f2)
        local bare_dir=$(dirname $(dirname "$gitdir"))
        if [ -f "$bare_dir/HEAD" ]; then
            local ref=$(cat "$bare_dir/HEAD")
            branch="${ref##*/}"
            [ -n "$branch" ] && echo "$branch" && return 0
        fi
    fi

    # Method 2: Check remote HEAD (works for normal repos)
    branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    [ -n "$branch" ] && echo "$branch" && return 0

    # Method 3: Query remote
    branch=$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}')
    [ -n "$branch" ] && echo "$branch" && return 0

    # Fallback
    echo "main"
}

# Sync repository with remote
# Usage: git_sync <branch> <commit_message>
git_sync() {
    local branch="${1:-$(get_default_branch)}"
    local commit_msg="${2:-auto-update}"

    # Fetch and pull
    git fetch origin "$branch" 2>&1 || return 1
    git pull origin "$branch" 2>&1 || return 1

    # Stage all changes
    git add .

    # Commit if there are changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        git commit -m "$commit_msg" 2>&1 || return 1
        git push origin "$branch" 2>&1 || return 1
    fi

    return 0
}
