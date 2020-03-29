#!/usr/bin/env bats
# Unit tests for git-monitor
# Depends on the bats-core testing framework: https://github.com/bats-core
# (Note: don't accidentally install the old 'bats'; use 'bats-core')
# On Mac OS we also assume that coreutils has been installed

# Note: if we use [[ ]] for assertions bats will report the WRONG line on failure

load utils

@test "Fail when adding over 10 files" {
    make_clone
    cd "$CLONE"
    touch {1..11}
    run git-monitor -1q
    grep -q "Too many new files" <<< "$output"
    [ "$status" -eq 6 ]
}


@test "Fail when adding more 10 files in a directory" {
    make_clone
    cd "$CLONE"
    mkdir flarp
    cd flarp
    touch {1..11}
    run git-monitor -1q
    grep -q "Too many new files" <<< "$output"
    [ "$status" -eq 6 ]
}


@test "Fail when adding more than 10 files in multiple dirs" {
    make_clone
    cd "$CLONE"
    mkdir flarp
    cd flarp
    touch {1..4}
    cd ..
    mkdir florp
    cd florp
    touch {5..9}
    cd ..
    touch {10..12}
    run git-monitor -1q
    grep -q "Too many new files" <<< "$output"
    [ "$status" -eq 6 ]
}

@test "Fail when exceeding size limit" {
    make_clone
    cd "$CLONE"
    dd if=/dev/urandom bs=1024 count=1024 > bigfile 2>/dev/null
    run git-monitor -1q
    grep -q "New files are too large " <<< "$output"
    [ "$status" -eq 6 ]
}


@test "Fail when exceeding size limit (multiple files/dirs)" {
    make_clone
    cd "$CLONE"
    mkdir flarp
    dd if=/dev/urandom bs=1024 count=512 > flarp/bigfile 2>/dev/null
    mkdir florp
    dd if=/dev/urandom bs=1024 count=512 > florp/bigfile 2>/dev/null

    run git-monitor -1q
    grep -q "New files are too large " <<< "$output"
    [ "$status" -eq 6 ]
}
