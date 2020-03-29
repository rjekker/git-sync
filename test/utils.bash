#!/bin/env bash

mktempdir() {
    mktemp="mktemp"
    [[ $(uname) = "Darwin" ]] && mktemp="gmktemp"
    $mktemp -d || exit 1
}


repo_no_remote() {
    set -e
    DIR=$(mktempdir)
    cd "$DIR"
    git init .
    touch empty_file
    git add .
    git commit -m "inital commit"
    export REPO_NO_REMOTE="$DIR"
    set +e
}


repo_no_remote >/dev/null 2>&1
