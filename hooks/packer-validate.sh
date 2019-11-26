#!/usr/bin/env bash

set -e -u -o pipefail

main()
{
    local filepath
    local error=0

    for filepath in "$@" ; do
        if ! grep -q '"builders"' "$filepath" ; then
            # Not a Packer template file, ignore it.
            continue
        fi

        pushd "$( dirname "$filepath" )" > /dev/null

        echo "Validating: $filepath"

        if ! packer validate "$( basename "$filepath" )" ; then
            error=1
        fi

        popd > /dev/null
    done

    if [[ $error -ne 0 ]] ; then
        exit 1
    fi
}


main "$@"
