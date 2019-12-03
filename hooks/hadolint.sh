#!/usr/bin/env bash

set -e -u -o pipefail

HadolintArgs=""

add_hadolint_arg()
{
    local param
    local value
    local hadolint_arg

    if [[ "$1" == *' '* ]] ; then
        # $1 has a space, e.g. "--arg value"
        param="${1%% *}"
        value="${1##* }"

        hadolint_arg="$param=$value"
    else
        # Use $1 as is, e.g. "--arg" or "--arg=value"
        hadolint_arg="$1"
    fi

    HadolintArgs="$HadolintArgs $hadolint_arg"
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
        # $HadolintArgs must be used *without* quotes so the arguments are
        # properly forwarded to Hadolint
        if ! hadolint $HadolintArgs "$filepath" ; then
            error=1
        fi
    done

    if [[ $error -ne 0 ]] ; then
        exit 1
    fi
}


main "$@"
