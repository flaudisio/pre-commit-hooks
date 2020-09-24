#!/usr/bin/env bash

set -e
set -u
set -o pipefail

ZeroWidthSpace="$( printf '%b' '\u200b' )"

main()
{
    local filepath
    local found_lines
    local line_number
    local exit_code=0

    for filepath in "$@" ; do
        found_lines="$( grep -n "$ZeroWidthSpace" "$filepath" || true )"

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
