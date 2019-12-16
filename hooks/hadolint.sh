#!/usr/bin/env bash

set -e -u -o pipefail

HadolintArgs=()

add_hadolint_arg()
{
    local param
    local value

    if [[ "$1" == *' '* && "$1" != *'='* ]] ; then
        # $1 has a space, e.g. "--param value"
        param="${1%% *}"
        value="${1#* }"

        HadolintArgs+=("$param" "$value")
    else
        # Use $1 as is, e.g. "--param" or "--param=value"
        HadolintArgs+=("$1")
    fi
}

main()
{
    local error=0

    while true ; do
        case $1 in
            -*)
                # Forward argument to Hadolint
                add_hadolint_arg "$1"
                shift
            ;;

            *) break ;;
        esac
    done

    for filepath in "$@" ; do
        if ! hadolint "${HadolintArgs[@]}" "$filepath" ; then
            error=1
        fi
    done

    if [[ $error -ne 0 ]] ; then
        exit 1
    fi
}


main "$@"
