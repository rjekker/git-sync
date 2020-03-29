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
    git init . >/dev/null
    touch empty_file
    git add . >/dev/null
    git commit -m "inital commit" >/dev/null
    echo "$DIR"
    set +e
}


#repo_no_remote >/dev/null 2>&1
