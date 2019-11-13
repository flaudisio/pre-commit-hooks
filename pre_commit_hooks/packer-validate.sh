#!/usr/bin/env bash

set -e

main()
{
    local filepath

    for filepath in "$@"; do
        if ! grep -q '"builders"' "$filepath" ; then
            # Not a Packer template file, ignore it.
            continue
        fi

        pushd "$( dirname "$filepath" )" > /dev/null

        echo "Validating: $filepath"
        packer validate "$( basename "$filepath" )"

        popd > /dev/null
    done
}


main "$@"
