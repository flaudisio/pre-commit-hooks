#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# Script-level tests: each hook runs directly against a stubbed tool, so no
# hadolint, packer or nomad binary is required.

REPO_ROOT="$( cd "$BATS_TEST_DIRNAME/.." && pwd )"

setup() {
    export STUB_LOG="$BATS_TEST_TMPDIR/stub.log"
    export PATH="$BATS_TEST_DIRNAME/stubs:$PATH"
}

@test "check-zero-width-spaces: flags U+200B as file:line and exits 1" {
    printf 'a\u200bb\n' > "$BATS_TEST_TMPDIR/bad.txt"

    run --separate-stderr "$REPO_ROOT/hooks/check-zero-width-spaces.sh" "$BATS_TEST_TMPDIR/bad.txt"

    [ "$status" -eq 1 ]
    [[ "$stderr" == *"bad.txt:1:"* ]]
    [[ "$stderr" == *"Found one or more zero-width-spaces (U+200B)"* ]]
}

@test "check-zero-width-spaces: reports every offending line" {
    printf 'a\u200bb\nclean\nc\u200bd\n' > "$BATS_TEST_TMPDIR/bad.txt"

    run --separate-stderr "$REPO_ROOT/hooks/check-zero-width-spaces.sh" "$BATS_TEST_TMPDIR/bad.txt"

    [ "$status" -eq 1 ]
    [[ "$stderr" == *"bad.txt:1:"* ]]
    [[ "$stderr" == *"bad.txt:3:"* ]]
}

@test "check-zero-width-spaces: accepts clean files" {
    printf 'clean\n' > "$BATS_TEST_TMPDIR/ok.txt"

    run "$REPO_ROOT/hooks/check-zero-width-spaces.sh" "$BATS_TEST_TMPDIR/ok.txt"

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "hadolint: splits a spaced arg into two argv entries" {
    run "$REPO_ROOT/hooks/hadolint.sh" "--ignore DL3013" "--config x.yaml" Dockerfile

    [ "$status" -eq 0 ]
    [ "$( cat "$STUB_LOG" )" = $'hadolint|'"$PWD"$'|--ignore DL3013 --config x.yaml Dockerfile' ]
}

@test "hadolint: keeps --flag=value as a single entry" {
    run "$REPO_ROOT/hooks/hadolint.sh" --trusted-registry=registry.example.com:5000 Dockerfile

    [ "$status" -eq 0 ]
    [ "$( cat "$STUB_LOG" )" = \
        "hadolint|$PWD|--trusted-registry=registry.example.com:5000 Dockerfile" ]
}

@test "hadolint: fails when any file fails, having checked all of them" {
    STUB_EXIT=1 run "$REPO_ROOT/hooks/hadolint.sh" a.Dockerfile b.Dockerfile

    [ "$status" -eq 1 ]
    [ "$( grep -c '^hadolint|' "$STUB_LOG" )" -eq 2 ]
}

@test "packer-validate: runs packer from the template's directory" {
    local template_dir="$BATS_TEST_TMPDIR/templates"
    mkdir -p "$template_dir"
    echo '{}' > "$template_dir/main.json"

    run "$REPO_ROOT/hooks/packer-validate.sh" "$template_dir/main.json"

    [ "$status" -eq 0 ]
    [ "$( cat "$STUB_LOG" )" = "packer|$template_dir|validate main.json" ]
}

@test "packer-validate: reports the template and exits 1 on failure" {
    local template_dir="$BATS_TEST_TMPDIR/templates"
    mkdir -p "$template_dir"
    echo '{}' > "$template_dir/main.json"

    STUB_EXIT=1 run --separate-stderr \
        "$REPO_ROOT/hooks/packer-validate.sh" "$template_dir/main.json"

    [ "$status" -eq 1 ]
    [[ "$stderr" == *"==> $template_dir/main.json"* ]]
}

@test "nomad-fmt: forwards the arguments unchanged" {
    run "$REPO_ROOT/hooks/nomad-fmt.sh" a.nomad.hcl

    [ "$status" -eq 0 ]
    [ "$( cat "$STUB_LOG" )" = "nomad|$PWD|fmt a.nomad.hcl" ]
}
