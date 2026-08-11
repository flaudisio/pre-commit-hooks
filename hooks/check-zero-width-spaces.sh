#!/usr/bin/env bash

set -e
set -u
set -o pipefail

ZERO_WIDTH_SPACE="$( printf '%b' '\u200b' )"

function main()
{
    local filepath
    local exit_code=0

    local found_lines
    local line_number

    for filepath in "$@" ; do
        found_lines="$( grep -n "$ZERO_WIDTH_SPACE" -- "$filepath" || true )"

        if [[ -z "$found_lines" ]] ; then
            continue
        fi

        exit_code=1

        while read -r line_number ; do
            echo "${filepath}:${line_number} Found one or more zero-width-spaces (U+200B)" >&2
        done <<< "$found_lines"
    done

    exit $exit_code
}


main "$@"
