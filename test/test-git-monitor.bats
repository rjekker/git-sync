#!/usr/bin/env bats
# Unit tests for git-monitor
# Depends on the bats testing framework: https://github.com/bats-core/bats-core
# On Mac OS we also assume that coreutils has been installed

load utils

setup() {
    export PATH="..:$PATH"
}

@test "Simple repo, no remote" {
    #cd "$(repo_no_remote)"
    run ../git-monitor -1q
    [ "$status" -eq 0 ]
    [[ "${lines[${#lines[@]}-1]}" =~ "Error: Cannot get remote for branch 'master'$" ]]
}

@test "bad argument" {
    run git monitor --flarpje
    [ $status -eq 1 ]
    [[ "${lines[0]}" =~ /illegal/ ]]
}

@test ok {
    run ls
    [ $status -eq 0 ]
}

@test find {
    which git-monitor
}
