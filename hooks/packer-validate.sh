#!/usr/bin/env bash

set -u
set -o pipefail

TEMP_FILE=''

# Colors, filled in by main()
C_BOLD=''
C_ERROR=''
C_NORMAL=''

trap 'rm -f -- "$TEMP_FILE"' EXIT

function print_error()
{
    printf '%b\n' "$*" >&2
}

function main()
{
    local filepath
    local template_dir
    local exit_code=0

    if [[ -n "${TERM:-}" ]] ; then
        C_BOLD='\e[1m'
        C_ERROR='\e[91m' # Light red
        C_NORMAL='\e[0m'
    fi

    if ! TEMP_FILE="$( mktemp /tmp/pre-commit-packer-validate-XXXXXX.log )" ; then
        print_error 'Error: could not create a temporary file'
        exit 1
    fi

    for filepath in "$@" ; do
        # Packer must run in the template's directory so relative paths
        # can be found (e.g. "../scripts/provision.sh")
        template_dir="$( dirname "$filepath" )"

        if ! pushd "$template_dir" > /dev/null ; then
            print_error "Error: could not enter ${template_dir}"
            exit_code=1
            continue
        fi

        if ! packer validate "$( basename "$filepath" )" > "$TEMP_FILE" 2>&1 ; then
            exit_code=1

            print_error "${C_BOLD}${C_ERROR}==> ${filepath}${C_NORMAL}"
            print_error ''

            # Delete trailing blank lines at end of file and print a new line
            # for consistent readability
            # Ref: https://stackoverflow.com/a/23894449
            tac "$TEMP_FILE" | sed -e '/./,$!d' | tac >&2
            print_error ''
        fi

        if ! popd > /dev/null ; then
            print_error 'Error: could not return to the original directory'
            exit_code=1
        fi
    done

    exit "$exit_code"
}


main "$@"
