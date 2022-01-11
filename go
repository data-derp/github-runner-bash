#!/usr/bin/env bash

set -e
script_dir=$(cd "$(dirname "$0")" ; pwd -P)


goal_run() {
  pushd "${script_dir}" > /dev/null
    ${script_dir}/run.sh "$@"
  popd > /dev/null
}

TARGET=${1:-}
if type -t "goal_${TARGET}" &>/dev/null; then
  "goal_${TARGET}" ${@:2}
else
  echo "Usage: $0 <goal>

goal:
    run                         - runs Github Runner
"
  exit 1
fi
