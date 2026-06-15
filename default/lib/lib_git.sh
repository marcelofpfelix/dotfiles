################################################################################
#                                 FILE INFO
# Library for git repository operations
# Supports both normal repos and worktree repos
################################################################################

git_bool() {
    case "${1:-false}" in
        1|true|TRUE|yes|YES|y|Y|on|ON) return 0 ;;
        *) return 1 ;;
    esac
}

# Check if current directory is a git worktree
# Worktrees have .git as a file (not directory) containing "gitdir:" reference
is_worktree() {
    [ -f ".git" ] && grep -q "^gitdir:" .git 2>/dev/null
}

git_repo_path_bool() {
    git_bool "$@"
}

git_repo_path() {
    local owner="${1:?owner is required}"
    local repo="${2:?repo is required}"
    local subpath="${3:-}"
    local git_root="${GIT_REPOS_ROOT:-$HOME/git}"
    local gwt_root="${GWT_REPOS_ROOT:-$HOME/gwt}"
    local path

    if git_repo_path_bool "${WORKTREE:-false}"; then
        path="$gwt_root/$owner/$repo/main"
    else
        path="$git_root/$owner/$repo"
    fi

    if [ -n "$subpath" ]; then
        path="$path/${subpath#/}"
    fi

    printf '%s\n' "$path"
}

git_repo_url() {
    local owner="${1:?owner is required}"
    local repo="${2:?repo is required}"
    local host="${3:-github.com}"

    printf 'git@%s:%s/%s.git\n' "$host" "$owner" "$repo"
}

git_repo_owner_from_url() {
    local repo_url="${1:?repo url is required}"
    repo_url="${repo_url%.git}"
    repo_url="${repo_url%/}"

    printf '%s\n' "$repo_url" | awk -F'[/:]' '{print $(NF-1)}'
}

git_repo_name_from_url() {
    local repo_url="${1:?repo url is required}"
    repo_url="${repo_url%.git}"
    repo_url="${repo_url%/}"

    basename "$repo_url"
}

git_repo_cd() {
    local path
    path="$(git_repo_path "$@")" || return
    cd "$path" || return
}

# Get current branch name
get_current_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || echo ""
}

git_current_branch() {
    get_current_branch "$@"
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

git_default_branch() {
    get_default_branch "$@"
}

git_checkout_default_branch() {
    local branch
    branch="$(git_default_branch)"

    git checkout "$branch"
}

git_checkout_feature_branch() {
    local branch="${1:?branch is required}"
    local default_branch

    default_branch="$(git_default_branch)"
    if [ -z "$branch" ] || [ "$branch" = "$default_branch" ]; then
        return 2
    fi

    git checkout "$default_branch" || return
    git fetch || return
    git pull origin "$default_branch" || return

    if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        git checkout "$branch" || return
        git pull origin "$branch"
        return
    fi

    if git show-ref --verify --quiet "refs/heads/$branch"; then
        git checkout "$branch"
        return
    fi

    git checkout -B "$branch"
}

git_repo_has_worktree_path() {
    local path="${1:?path is required}"

    [ -d "$path" ] && git -C "$path" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

git_repo_ensure_normal() {
    local path="${1:?path is required}"
    local url="${2:?url is required}"
    local branch="${3:-}"

    if git_repo_has_worktree_path "$path"; then
        return 0
    fi

    if [ -e "$path" ]; then
        printf 'Path exists but is not a git repository: %s\n' "$path" >&2
        return 1
    fi

    mkdir -p "$(dirname "$path")" || return
    if [ -n "$branch" ] && [ "$branch" != "default" ]; then
        git clone ${GITFLAGS:-} --branch "$branch" "$url" "$path"
    else
        git clone ${GITFLAGS:-} "$url" "$path"
    fi
}

git_repo_ensure_worktree() {
    local owner="${1:?owner is required}"
    local repo="${2:?repo is required}"
    local path="${3:?path is required}"
    local url="${4:?url is required}"
    local branch="${5:-main}"
    local base="${GWT_REPOS_ROOT:-$HOME/gwt}/$owner/$repo"

    if git_repo_has_worktree_path "$path"; then
        return 0
    fi

    if [ -e "$path" ]; then
        printf 'Path exists but is not a git worktree: %s\n' "$path" >&2
        return 1
    fi

    mkdir -p "$base" || return
    if [ ! -d "$base/.bare" ]; then
        git clone ${GITFLAGS:-} --bare "$url" "$base/.bare" || return
        printf 'gitdir: ./.bare\n' > "$base/.git"
        git -C "$base" config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*" || return
    elif [ ! -f "$base/.git" ]; then
        printf 'gitdir: ./.bare\n' > "$base/.git"
    fi

    git -C "$base" fetch ${GITFLAGS:-} origin || return

    if [ -z "$branch" ] || [ "$branch" = "default" ]; then
        branch="$(git -C "$base" remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}')"
        branch="${branch:-main}"
    fi

    if git -C "$base" show-ref --verify --quiet "refs/heads/$branch"; then
        git -C "$base" worktree add ${GITFLAGS:-} "$path" "$branch"
    elif git -C "$base" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        git -C "$base" worktree add ${GITFLAGS:-} -b "$branch" "$path" "origin/$branch"
    else
        printf 'Branch not found for worktree clone: %s\n' "$branch" >&2
        return 1
    fi
}

git_repo_ensure() {
    local owner="${1:?owner is required}"
    local repo="${2:?repo is required}"
    local path="${3:?path is required}"
    local url="${4:?url is required}"
    local worktree="${5:-false}"
    local branch="${6:-}"

    if git_bool "$worktree"; then
        git_repo_ensure_worktree "$owner" "$repo" "$path" "$url" "$branch"
    else
        git_repo_ensure_normal "$path" "$url" "$branch"
    fi
}

git_repo_pull() {
    local branch="${1:-$(git_default_branch)}"

    git fetch origin "$branch" || return
    git pull origin "$branch"
}

# Sync repository with remote.
# Usage: git_sync <branch> <commit_message> [mode]
# mode=read only fetches/pulls; mode=write also commits and pushes changes.
git_sync() {
    local branch="${1:-$(git_default_branch)}"
    local commit_msg="${2:-auto-update}"
    local mode="${3:-write}"

    git_repo_pull "$branch" || return

    if [ "$mode" = "read" ] || [ "$mode" = "pull" ]; then
        return 0
    fi

    git add .

    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        git commit -m "$commit_msg" || return
        git push origin "$branch" || return
    fi
}
