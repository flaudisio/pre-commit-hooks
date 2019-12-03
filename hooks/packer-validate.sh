#!/usr/bin/env bash

set -e -u -o pipefail

# Colors
CBold=''
CError=''
CNormal=''

# Setup
TempFile="$( mktemp /tmp/pre-commit-packer-validate-XXXXXX.log )"

set_colors()
{
    if [[ -n "$TERM" ]] ; then
        CBold='\e[1m'
        CError='\e[91m'  # Light red
        CNormal='\e[0m'
    fi
}

main()
{
    local filepath
    local error=0

    trap "rm -f '$TempFile'" EXIT

    set_colors

    for filepath in "$@" ; do
        # Packer must run in the template's directory so relative paths
        # can be found (e.g. "../scripts/provision.sh")
        pushd "$( dirname "$filepath" )" > /dev/null

        if ! packer validate "$( basename "$filepath" )" > "$TempFile" 2>&1 ; then
            error=1

            echo -e "${CBold}${CError}==> ${filepath}${CNormal}"
            echo

            # Delete trailing blank lines at end of file and print a new line
            # for consistent readability
            # Ref: https://stackoverflow.com/a/23894449
            tac "$TempFile" | sed -e '/./,$!d' | tac
            echo
        fi

        popd > /dev/null
    done

    if [[ $error -ne 0 ]] ; then
        exit 1
    fi
}


main "$@"
