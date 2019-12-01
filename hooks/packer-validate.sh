#!/usr/bin/env bash

set -e -u -o pipefail

# Colors
CBold=''
CLightCyan=''
CNormal=''

set_colors()
{
    if [[ -n "$TERM" ]] ; then
        CBold='\e[1m'
        CLightCyan='\e[96m'
        CNormal='\e[0m'
    fi
}

main()
{
    local filepath
    local error=0

    set_colors

    for filepath in "$@" ; do
        pushd "$( dirname "$filepath" )" > /dev/null

        echo -e "${CBold}${CLightCyan}==> Validating: ${filepath}${CNormal}"
        echo

        if ! packer validate "$( basename "$filepath" )" ; then
            error=1
        fi

        echo
        popd > /dev/null
    done

    if [[ $error -ne 0 ]] ; then
        exit 1
    fi
}


main "$@"
