#!/usr/bin/env bats
# Unit tests for git-monitor
# Depends on the bats-core testing framework: https://github.com/bats-core
# (Note: don't accidentally install the old 'bats'; use 'bats-core')
# On Mac OS we also assume that coreutils has been installed

# Note: if we use [[ ]] for assertions bats will report the WRONG line on failure

load utils

@test "bad argument" {
    run git monitor --flarpje
    grep -q illegal <<< "${lines[0]}"
    [ "$status" -eq 1 ]
}


@test "no argument; use current dir" {
    make_clone
    cd "$CLONE"
    run git-monitor -1
    [ "$status" -eq 0 ]
    grep -qE "^\\[$CLONE.+?] Starting sync" <<< "${lines[0]}"
    # [ "${lines[${#lines[@]}-1]}" == "Nothing to do." ]
}


@test "Simple repo, no remote" {
    make_repo_no_remote
    cd "$REPO_NO_REMOTE"
    run git-monitor -1q
    grep -q "Cannot get remote" <<< "$output"
    [ "$status" -eq 1 ]
}


@test "Refuse to work outside of a git repo" {
    DIR=$(mktempdir)
    run git-monitor -q1 "$DIR"
    [ $status -eq 128 ]
    grep -q "Not a git repo" <<< "$output"
}


@test "Refuse to work on a bare repo" {
    make_origin
    run git-monitor -q1 "$ORIGIN"
    [ $status -eq 3 ]
    grep -q "Cannot sync because target is a bare repo" <<< "$output"
}


@test "Refuse to work on a git dir" {
    make_clone
    run git-monitor -q1 "$CLONE/.git"
    [ $status -eq 3 ]
    grep -q "Cannot sync because target is a git-dir" <<< "$output"
}


@test "changing a file" {
    make_clone
    cd "$CLONE"
    echo "a new line" >> empty_file
    run git-monitor -q1 .
    [ "$status" -eq 0 ]
    grep -qE "^\\[$CLONE.+?] Starting sync" <<< "${lines[0]}"
    grep -qE "^\\[$CLONE.+?] Committing" <<< "${lines[1]}"
    grep -qE "^\\[$CLONE.+?] Pushing" <<< "${lines[2]}"
    grep -qE "^\\[$CLONE.+?] In sync with origin" <<< "${lines[3]}"

    check_repo_clean
}


@test "deleting a file" {
    make_clone
    cd "$CLONE"
    rm empty_file
    run git-monitor -q1 .
    [ "$status" -eq 0 ]
    grep -qE "^\\[$CLONE.+?] Starting sync" <<< "${lines[0]}"
    grep -qE "^\\[$CLONE.+?] Committing" <<< "${lines[1]}"
    grep -qE "^\\[$CLONE.+?] Pushing" <<< "${lines[2]}"
    grep -qE "^\\[$CLONE.+?] In sync with origin" <<< "${lines[3]}"

    check_repo_clean
}


@test "moving a file" {
    make_clone
    cd "$CLONE"
    mv empty_file moved_file
    run git-monitor -q1 .
    [ "$status" -eq 0 ]
    grep -qE "^\\[$CLONE.+?] Starting sync" <<< "${lines[0]}"
    grep -qE "^\\[$CLONE.+?] Committing" <<< "${lines[1]}"
    grep -qE "^\\[$CLONE.+?] Pushing" <<< "${lines[2]}"
    grep -qE "^\\[$CLONE.+?] In sync with origin" <<< "${lines[3]}"

    check_repo_clean
}

@test "adding a file" {
    make_clone
    cd "$CLONE"
    touch new_file
    run git-monitor -q1 .
    [ "$status" -eq 0 ]
    grep -qE "^\\[$CLONE.+?] Starting sync" <<< "${lines[0]}"
    grep -qE "^\\[$CLONE.+?] Committing" <<< "${lines[1]}"
    grep -qE "^\\[$CLONE.+?] Pushing" <<< "${lines[2]}"
    grep -qE "^\\[$CLONE.+?] In sync with origin" <<< "${lines[3]}"

    check_repo_clean
}


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

# Test other fail scenarios.. go over errors in script
