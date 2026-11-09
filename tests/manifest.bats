#!/usr/bin/env bats

# Manifest wiring: both runners install the hooks from .pre-commit-hooks.yaml
# in a scratch repository, so the types/files filters are exercised for real.

REPO_ROOT="$( cd "$BATS_TEST_DIRNAME/.." && pwd )"
RUNNERS=( pre-commit prek )

setup() {
    export STUB_LOG="$BATS_TEST_TMPDIR/stub.log"
    export PATH="$BATS_TEST_DIRNAME/stubs:$PATH"

    work="$BATS_TEST_TMPDIR/repo"
    git init -q "$work"
}

# --all-files reads git ls-files, so fixtures must be committed.
commit_fixtures() {
    git -C "$work" add --all
    git -C "$work" -c user.name=test -c user.email=test@example.com \
        commit --quiet --message fixtures
}

try_repo() {
    run "$1" try-repo "$REPO_ROOT" "$2" --all-files --color never
}

@test "manifest: check-zero-width-spaces fails on U+200B" {
    printf 'a\u200bb\n' > "$work/bad.txt"
    commit_fixtures
    cd "$work" || return 1

    for runner in "${RUNNERS[@]}"; do
        try_repo "$runner" check-zero-width-spaces
        [ "$status" -eq 1 ]
    done
}

@test "manifest: check-zero-width-spaces passes clean files" {
    printf 'clean\n' > "$work/ok.txt"
    commit_fixtures
    cd "$work" || return 1

    for runner in "${RUNNERS[@]}"; do
        try_repo "$runner" check-zero-width-spaces
        [ "$status" -eq 0 ]
    done
}

@test "manifest: hadolint runs on Dockerfiles only" {
    printf 'FROM alpine\n' > "$work/Dockerfile"
    printf 'notes\n' > "$work/notes.txt"
    commit_fixtures
    cd "$work" || return 1

    for runner in "${RUNNERS[@]}"; do
        : > "$STUB_LOG"
        try_repo "$runner" hadolint
        [ "$status" -eq 0 ]
        [ "$( grep -c 'Dockerfile' "$STUB_LOG" )" -eq 1 ]
        [ "$( grep -c 'notes.txt' "$STUB_LOG" )" -eq 0 ]
    done
}

@test "manifest: nomad-fmt runs on Nomad manifests only" {
    echo 'job "a" {}' > "$work/main.nomad.hcl"
    printf 'notes\n' > "$work/notes.txt"
    commit_fixtures
    cd "$work" || return 1

    for runner in "${RUNNERS[@]}"; do
        : > "$STUB_LOG"
        try_repo "$runner" nomad-fmt
        [ "$status" -eq 0 ]
        [ "$( grep -c 'main.nomad.hcl' "$STUB_LOG" )" -eq 1 ]
        [ "$( grep -c 'notes.txt' "$STUB_LOG" )" -eq 0 ]
    done
}

@test "manifest: packer-validate runs on JSON files only" {
    echo '{}' > "$work/main.json"
    printf 'notes\n' > "$work/notes.txt"
    commit_fixtures
    cd "$work" || return 1

    for runner in "${RUNNERS[@]}"; do
        : > "$STUB_LOG"
        try_repo "$runner" packer-validate
        [ "$status" -eq 0 ]
        [ "$( grep -c 'main.json' "$STUB_LOG" )" -eq 1 ]
        [ "$( grep -c 'notes.txt' "$STUB_LOG" )" -eq 0 ]
    done
}
