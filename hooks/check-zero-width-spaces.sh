#!/usr/bin/env bash

set -u
set -o pipefail

ZERO_WIDTH_SPACE="$( printf '%b' '\u200b' )"
readonly ZERO_WIDTH_SPACE

function main()
{
    local filepath
    local exit_code=0

    local found_lines
    local found_line
    local line_number
    local grep_status

    for filepath in "$@" ; do
        found_lines="$( grep -n -- "$ZERO_WIDTH_SPACE" "$filepath" )"
        grep_status=$?

        case "$grep_status" in
            0)
                # Matches found: report them below
            ;;
            1)
                # grep exits 1 when the file is clean
                continue
            ;;
            *)
                printf 'Error: could not scan %s\n' "$filepath" >&2
                exit_code=1
                continue
            ;;
        esac

        exit_code=1

        while IFS= read -r found_line ; do
            # grep -n prefixes the line number to the matching line
            line_number="${found_line%%:*}"

            printf '%s:%s Found one or more zero-width-spaces (U+200B)\n' \
                "$filepath" "$line_number" >&2
        done <<< "$found_lines"
    done

    exit "$exit_code"
}


main "$@"
