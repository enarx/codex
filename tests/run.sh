#!/bin/sh

if [ "$#" -lt 2  ]; then
    echo "Usage: $0 GOLDEN [enarx run arguments]"
    exit 1
fi

golden="${1}"
shift 1

set -ex
enarx run "${@}" | { read line; while read line; do echo $line; done } | diff "${golden}" -
