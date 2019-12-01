#!/usr/bin/env bash

set -e -u -o pipefail

HadolintArgs=""

add_hadolint_arg()
{
    local arg
    local value

    if [[ "$1" == *=* ]] ; then
        # $1 is like --arg=VALUE
        HadolintArgs="$HadolintArgs $1"
    else
        # $1 is like --arg VALUE  (including the space)
        arg="${1%% *}"
        value="${1##* }"

        HadolintArgs="$HadolintArgs $arg=$value"
    fi
}

main()
{
    local error=0

    while true ; do
        case $1 in
            --ignore*)
                add_hadolint_arg "$1"
                shift
            ;;

            *)
                break
            ;;
        esac
    done

    for filepath in "$@" ; do
        if ! hadolint $HadolintArgs "$filepath" ; then
            error=1
        fi
    done

    if [[ $error -ne 0 ]] ; then
        exit 1
    fi
}


main "$@"
