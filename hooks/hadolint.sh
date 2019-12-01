#!/usr/bin/env bash

set -e -u -o pipefail

main()
{
    local error=0

    for filepath in "$@" ; do
        if ! hadolint "$filepath" ; then
            error=1
        fi
    done

    if [[ $error -ne 0 ]] ; then
        exit 1
    fi
}


main "$@"
