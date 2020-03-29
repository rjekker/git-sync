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
