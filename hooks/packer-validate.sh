#!/usr/bin/env bash

set -e
set -u
set -o pipefail

# Colors
C_BOLD=''
C_ERROR=''
C_NORMAL=''

function _msg()
{
    echo "$*" >&2
}

function main()
{
    local temp_file

    temp_file="$( mktemp /tmp/pre-commit-packer-validate-XXXXXX.log )"

    # shellcheck disable=SC2064
    trap "rm -f -- '$temp_file'" EXIT

    if [[ -n "$TERM" ]] ; then
        C_BOLD='\e[1m'
        C_ERROR='\e[91m' # Light red
        C_NORMAL='\e[0m'
    fi

    local filepath
    local exit_code=0

    for filepath in "$@" ; do
        # Packer must run in the template's directory so relative paths
        # can be found (e.g. "../scripts/provision.sh")
        pushd "$( dirname "$filepath" )" > /dev/null

        if ! packer validate "$( basename "$filepath" )" > "$temp_file" 2>&1 ; then
            exit_code=1

            _msg "${C_BOLD}${C_ERROR}==> ${filepath}${C_NORMAL}"
            _msg

            # Delete trailing blank lines at end of file and print a new line
            # for consistent readability
            # Ref: https://stackoverflow.com/a/23894449
            tac "$temp_file" | sed -e '/./,$!d' | tac >&2
            _msg
        fi

        popd > /dev/null
    done

    exit $exit_code
}


main "$@"
