#!/usr/bin/env bash

set -e -u -o pipefail

ZeroWidthSpace="$( printf '%b' '\u200b' )"

main()
{
    local filepath
    local found_lines
    local line_number
    local error=0

    for filepath in "$@" ; do
        found_lines="$( grep -n "$ZeroWidthSpace" "$filepath" || true )"

        if [[ -z "$found_lines" ]] ; then
            continue
        fi

        error=1

        while read -r line_number ; do
            echo "${filepath}:${line_number} Found one or more zero-width-spaces (U+200B)"
        done <<< "$found_lines"
    done

    if [[ $error -ne 0 ]] ; then
        exit 1
    fi
}


main "$@"
