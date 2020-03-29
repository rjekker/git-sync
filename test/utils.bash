#!/bin/env bash

mktempdir() {
    mktemp="mktemp"
    [[ $(uname) = "Darwin" ]] && mktemp="gmktemp"
    $mktemp -d || exit 1
}


make_repo() {
    # create a simple repo with a single commit
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


make_origin() {
    # Create a repo that we can use as origin for other repos
    set -e
    ORIGIN="$(make_repo)"
    export ORIGIN
    echo "$ORIGIN"
    set +e
}


repo_no_remote() {
    # Create a repo without a remote
    set -e
    REPO_NO_REMOTE="$(make_repo)"
    export REPO_NO_REMOTE
    set +e
}


make_clone() {
    # Clone $ORIGIN
    set -e
    CLONE="$(mktempdir)"
    git clone "$(make_origin)" "$CLONE" >/dev/null
    export CLONE
    set +e
}
