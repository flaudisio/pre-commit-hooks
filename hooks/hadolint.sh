#!/usr/bin/env bash

set -e -u -o pipefail

main()
{
    local hadolintOpts=""
    local error=0

    while true ; do
        case $1 in
            --ignore*)
                if [[ "$1" == *=* ]] ; then
                    # Example $1: --ignore=DL3018
                    hadolintOpts="$hadolintOpts $1"
                else
                    # Example $1: --ignore DL3018
                    hadolintOpts="$hadolintOpts ${1%% *}=${1##* }"
                fi

                shift
            ;;

            *)
                break
            ;;
        esac
    done

    for filepath in "$@" ; do
        if ! hadolint $hadolintOpts "$filepath" ; then
            error=1
        fi
    done

    if [[ $error -ne 0 ]] ; then
        exit 1
    fi
}


main "$@"
