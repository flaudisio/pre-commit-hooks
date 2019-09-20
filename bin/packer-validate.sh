#!/usr/bin/env bash

set -e

main()
{
    local filepath

    for filepath in "$@"; do
        if ! grep -q '"builders"' "$filepath" ; then
            echo "NOTICE: ignoring '$filepath' (not a Packer template)"
            continue
        fi

        echo "Checking '$filepath' ..."

        pushd "$( dirname "$filepath" )" > /dev/null

        packer validate "$( basename "$filepath" )"

        popd > /dev/null
    done
}


main "$@"
