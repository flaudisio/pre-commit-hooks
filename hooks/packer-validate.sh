#!/usr/bin/env bash

set -e
set -u
set -o pipefail

# Colors
CBold=''
CError=''
CNormal=''

# Setup
TempFile="$( mktemp /tmp/pre-commit-packer-validate-XXXXXX.log )"

trap 'rm -f "$TempFile"' EXIT

main()
{
    local filepath
    local exit_code=0

    # Configure colors
    if [[ -n "$TERM" ]] ; then
        CBold='\e[1m'
        CError='\e[91m'  # Light red
        CNormal='\e[0m'
    fi

    for filepath in "$@" ; do
        # Packer must run in the template's directory so relative paths
        # can be found (e.g. "../scripts/provision.sh")
        pushd "$( dirname "$filepath" )" > /dev/null

        if ! packer validate "$( basename "$filepath" )" > "$TempFile" 2>&1 ; then
            exit_code=1

            echo -e "${CBold}${CError}==> ${filepath}${CNormal}" >&2
            echo >&2

            # Delete trailing blank lines at end of file and print a new line
            # for consistent readability
            # Ref: https://stackoverflow.com/a/23894449
            tac "$TempFile" | sed -e '/./,$!d' | tac >&2
            echo >&2
        fi

        popd > /dev/null
    done

    exit $exit_code
}


main "$@"
