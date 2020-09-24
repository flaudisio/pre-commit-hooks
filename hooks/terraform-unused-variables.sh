#!/usr/bin/env bash

set -e
set -u
set -o pipefail

: "${DEBUG:=""}"

# Setup
TempFile="$( mktemp /tmp/pre-commit-terraform-unused-variables-XXXXXX.txt )"

trap "rm -f '$TempFile'" EXIT

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

    for filepath in "$@" ; do
        filedir="$( dirname "$filepath" )"

        log_debug "Processing: $filepath (filedir: $filedir)"

        if ! grep '^variable' "$filepath" | cut -d '"' -f 2 > "$TempFile" ; then
            log_debug "No declared variables found in $filepath; ignoring"
            continue
        fi

        while read -r var_name ; do
            if ! grep -E -q "\Wvar\.${var_name}(\W|$)" "$filedir"/*.tf ; then
                echo "${filepath}: variable not in use: $var_name" >&2
                exit_code=1
            fi
        done < "$TempFile"
    done

    exit $exit_code
}


main "$@"
