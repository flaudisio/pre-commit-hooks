#!/usr/bin/env bash

set -e
set -u
set -o pipefail

HADOLINT_ARGS=()

function append_hadolint_arg()
{
    local param
    local value

    if [[ "$1" == *' '* && "$1" != *'='* ]] ; then
        # $1 has a space, e.g. "--param value"
        param="${1%% *}"
        value="${1#* }"

        HADOLINT_ARGS+=("$param" "$value")
    else
        # Use $1 as is, e.g. "--param" or "--param=value"
        HADOLINT_ARGS+=("$1")
    fi
}

function main()
{
    local filepath
    local exit_code=0

    while true ; do
        case "$1" in
            -*)
                # Forward argument to Hadolint
                append_hadolint_arg "$1"
                shift
            ;;

            *) break ;;
        esac
    done

    for filepath in "$@" ; do
        if ! hadolint "${HADOLINT_ARGS[@]}" "$filepath" ; then
            exit_code=1
        fi
    done

    exit $exit_code
}


main "$@"
