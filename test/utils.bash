#!/bin/env bash

mktempdir() {
    mktemp="mktemp"
    readlink="readlink"
    if [[ $(uname) = "Darwin" ]]; then
        mktemp="gmktemp"
        readlink="greadlink"
    fi
    $readlink -f "$($mktemp -d)" || exit 1
}


make_repo() {
    # create a simple repo with a single commit
    DIR=$(mktempdir)
    cd "$DIR" || exit 1
    git init . >/dev/null
    touch empty_file
    git add . >/dev/null
    git commit -m "inital commit" >/dev/null
    echo "$DIR"
}


make_origin() {
    # Create a repo that we can use as origin for other repos
    ORIGIN="$(make_repo)"
    export ORIGIN
}


make_repo_no_remote() {
    # Create a repo without a remote
    REPO_NO_REMOTE="$(make_repo)"
    export REPO_NO_REMOTE
}


make_clone() {
    # Clone $ORIGIN
    make_origin
    CLONE="$(mktempdir)"
    git clone "$ORIGIN" "$CLONE" >/dev/null 2>&1
    export CLONE
}
