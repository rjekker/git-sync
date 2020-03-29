#!/usr/bin/env bats
# Unit tests for git-monitor
# Depends on the bats testing framework: https://github.com/bats-core/bats-core
# On Mac OS we also assume that coreutils has been installed

load utils

# setup() {
# }

@test current_dir {
    cd "$REPO_NO_REMOTE" || exit 1
    git monitor -1
    [ $status -eq 0 ]
    [ "${lines[0]}" = "Syncing $DIR" ]
}
