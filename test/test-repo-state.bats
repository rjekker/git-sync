#!/usr/bin/env bats
# Unit tests for git-monitor
# Depends on the bats-core testing framework: https://github.com/bats-core
# (Note: don't accidentally install the old 'bats'; use 'bats-core')
# On Mac OS we also assume that coreutils has been installed

# Note: if we use [[ ]] for assertions bats will report the WRONG line on failure

load utils


@test "fail on detached HEAD" {
    make_clone
    cd "$CLONE"
    touch new_file
    git add . >/dev/null 2>&1
    git commit -m "adding a file"  >/dev/null 2>&1
    git checkout 'HEAD~1'  >/dev/null 2>&1
    run git-monitor -q1 .
    [ "$status" -eq 3 ]
    grep -q "No active branch." <<< "$output"

    check_repo_clean
}


@test "Fail when no remote" {
    make_repo_no_remote
    cd "$REPO_NO_REMOTE"
    run git-monitor -1q
    grep -q "Cannot get remote" <<< "$output"
    [ "$status" -eq 1 ]
}


@test "Fail when repo is merging" {
    make_repo_no_remote
    cd "$REPO_NO_REMOTE"
    echo "dinges 1" > empty_file
    git checkout -b "newbranch"
    git commit -am "."
    git checkout master
    echo "dinges 2" > empty_file
    git commit -am ".."
    git merge --no-commit newbranch || true
    run git-monitor -1q
    grep -q "Cannot sync because target in an unsupported state (merging." <<< "$output"
    [ "$status" -eq 3 ]
}
