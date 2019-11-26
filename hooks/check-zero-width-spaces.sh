#!/usr/bin/env bash

ZeroWidthSpace="$( printf '%b' '\u200b' )"

main()
{
    local filepath
    local found_lines
    local line_number
    local error=0

    for filepath in "$@" ; do
        found_lines="$( grep --line-number "$ZeroWidthSpace" "$filepath" | cut -d ':' -f 1 )"

        if [[ -n "$found_lines" ]] ; then
            error=1

            while read -r line_number ; do
                echo "${filepath}:${line_number} Found one or more zero-width-spaces (U+200B)"
            done <<< "$found_lines"
        fi
    done

    [[ $error -eq 0 ]] || exit 1
}


main "$@"
