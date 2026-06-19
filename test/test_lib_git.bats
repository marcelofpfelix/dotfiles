#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  export HOME="$TEST_DIR/home"
  mkdir -p "$HOME"

  source "$(dirname "$BATS_TEST_FILENAME")/../default/lib/lib_git.sh"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "git_repo_path defaults to gwt worktree path" {
  unset WORKTREE GIT_REPOS_ROOT GWT_REPOS_ROOT

  run git_repo_path marcelofpfelix homework

  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/gwt/marcelofpfelix/homework/main" ]
}

@test "git_repo_path resolves WORKTREE=true to gwt main path" {
  WORKTREE=true run git_repo_path marcelofpfelix homelab

  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/gwt/marcelofpfelix/homelab/main" ]
}

@test "git_repo_path appends optional subpath" {
  WORKTREE=true run git_repo_path team-telnyx tel-proxy home

  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/gwt/team-telnyx/tel-proxy/main/home" ]
}

@test "git_repo_path custom roots are honored" {
  WORKTREE=false GIT_REPOS_ROOT="$TEST_DIR/gitroot" run git_repo_path marcelofpfelix homework

  [ "$status" -eq 0 ]
  [ "$output" = "$TEST_DIR/gitroot/marcelofpfelix/homework" ]

  WORKTREE=true GWT_REPOS_ROOT="$TEST_DIR/gwtroot" run git_repo_path marcelofpfelix homework

  [ "$status" -eq 0 ]
  [ "$output" = "$TEST_DIR/gwtroot/marcelofpfelix/homework/main" ]
}

@test "git_repo_url builds github ssh url" {
  run git_repo_url marcelofpfelix dotfiles

  [ "$status" -eq 0 ]
  [ "$output" = "git@github.com:marcelofpfelix/dotfiles.git" ]
}

@test "git_repo_url supports custom git host" {
  run git_repo_url team-telnyx tel-proxy gitlab.com

  [ "$status" -eq 0 ]
  [ "$output" = "git@gitlab.com:team-telnyx/tel-proxy.git" ]
}

@test "git_repo_ssh_url_from_url converts github https urls" {
  run git_repo_ssh_url_from_url https://github.com/team-telnyx/tel-proxy-alerts.git

  [ "$status" -eq 0 ]
  [ "$output" = "git@github.com:team-telnyx/tel-proxy-alerts.git" ]
}

@test "git_repo_normalize_origin_url rewrites github https origin" {
  mkdir -p "$TEST_DIR/repo"
  git -C "$TEST_DIR/repo" init --quiet
  git -C "$TEST_DIR/repo" remote add origin https://github.com/team-telnyx/tel-proxy-alerts.git

  run git_repo_normalize_origin_url "$TEST_DIR/repo"

  [ "$status" -eq 0 ]
  [ "$(git -C "$TEST_DIR/repo" remote get-url origin)" = "git@github.com:team-telnyx/tel-proxy-alerts.git" ]
}

@test "git repo owner and name are parsed from ssh urls" {
  run git_repo_owner_from_url git@github.com:marcelofpfelix/dotfiles.git

  [ "$status" -eq 0 ]
  [ "$output" = "marcelofpfelix" ]

  run git_repo_name_from_url git@github.com:marcelofpfelix/dotfiles.git

  [ "$status" -eq 0 ]
  [ "$output" = "dotfiles" ]
}

@test "git_repo_cd changes to resolved path" {
  mkdir -p "$HOME/gwt/marcelofpfelix/homework/main"

  run bash -c "
    source '$(dirname "$BATS_TEST_FILENAME")/../default/lib/lib_git.sh'
    git_repo_cd marcelofpfelix homework
    pwd
  "

  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/gwt/marcelofpfelix/homework/main" ]
}
