#!/bin/bash

set -xeuo pipefail

template="refine.ini.template"

if [ -f "$template" ]
then
    envsubst < "$template" > refine.ini
fi

exec "$@"
