#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  export HOME="$TEST_DIR/home"
  mkdir -p "$HOME"

  source "$(dirname "$BATS_TEST_FILENAME")/lib_git.sh"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "git_repo_path defaults to git checkout path" {
  unset WORKTREE GIT_REPOS_ROOT GWT_REPOS_ROOT

  run git_repo_path marcelofpfelix homework

  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/git/marcelofpfelix/homework" ]
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
  GIT_REPOS_ROOT="$TEST_DIR/gitroot" run git_repo_path marcelofpfelix homework

  [ "$status" -eq 0 ]
  [ "$output" = "$TEST_DIR/gitroot/marcelofpfelix/homework" ]

  WORKTREE=true GWT_REPOS_ROOT="$TEST_DIR/gwtroot" run git_repo_path marcelofpfelix homework

  [ "$status" -eq 0 ]
  [ "$output" = "$TEST_DIR/gwtroot/marcelofpfelix/homework/main" ]
}

@test "git_repo_cd changes to resolved path" {
  mkdir -p "$HOME/git/marcelofpfelix/homework"

  run bash -c "
    source '$(dirname "$BATS_TEST_FILENAME")/lib_git.sh'
    git_repo_cd marcelofpfelix homework
    pwd
  "

  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/git/marcelofpfelix/homework" ]
}
