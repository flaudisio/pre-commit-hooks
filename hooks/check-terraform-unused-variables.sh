#!/usr/bin/env bash

set -e
set -u
set -o pipefail

: "${DEBUG:=""}"

# Colors
CBold=''
CNormal=''

log_debug()
{
    if [[ -z "$DEBUG" ]] ; then
        return 0
    fi

    echo "[DEBUG] $*"
}

main()
{
    local filepath
    local filedir
    local exit_code=0

    local line_number
    local found_lines
    local found_line

    # Configure colors
    if [[ -n "$TERM" ]] ; then
        CBold='\e[1m'
        CNormal='\e[0m'
    fi

    for filepath in "$@" ; do
        filedir="$( dirname "$filepath" )"

        log_debug "Processing: $filepath (filedir: $filedir)"

        found_lines="$( grep -n '^variable' "$filepath" || true )"

        if [[ -z "$found_lines" ]] ; then
            log_debug "No declared variables found in $filepath; ignoring"
            continue
        fi

        # Example: 5:variable "environment" {
        while read -r found_line ; do
            line_number="${found_line%%:*}"
            var_name="$( cut -d '"' -f 2 <<< "$found_line" )"

            if ! grep -E -q "\Wvar\.${var_name}(\W|$)" "$filedir"/*.tf ; then
                echo -e "${filepath}:${line_number} Variable not in use: ${CBold}${var_name}${CNormal}" >&2
                exit_code=1
            fi
        done <<< "$found_lines"
    done

    exit $exit_code
}


main "$@"
