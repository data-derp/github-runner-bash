#!/bin/bash

set -e

script_dir=$(cd "$(dirname "$0")" ; pwd -P)

repo_url=${1}
username=${2}

if [ -z "${repo_url}" ]; then
  echo "REPO_URL not set. Usage <func> REPO_URL GITHUB_USERNAME"
  exit 1
fi

if [ -z "${username}" ]; then
  echo "GITHUB_USERNAME not set. Usage <func> REPO_URL GITHUB_USERNAME"
  exit 1
fi

repo_name=$([[ $repo_url =~ github.com.*[\/|\:](.*[\/|\:].*)$ ]] && echo "${BASH_REMATCH[1]}")

fetch-github-registration-token() {
  username="${1}"

  if [ -z "${username}" ]; then
    echo "USERNAME not set. Usage <func:fetch-github-registration-token> USERNAME"
    exit 1
  fi

  response=$(curl \
    -u $username \
    -X POST \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/${repo_name}/actions/runners/registration-token)

  echo $response | jq -r .token
}

setup_github_runner() {
  if [ ! -d "${script_dir}/actions-runner" ]; then
    mkdir -p ${script_dir}/actions-runner
    pushd "${script_dir}/actions-runner" > /dev/null
      curl -o actions-runner-osx-x64-2.285.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.285.1/actions-runner-osx-x64-2.285.1.tar.gz
      echo "e46c1b305acaffab10a85d417cda804f4721707c85e5353ee3428b385642e6fd  actions-runner-osx-x64-2.285.1.tar.gz" | shasum -a 256 -c
      tar xzf actions-runner-osx-x64-2.285.1.tar.gz
      rm actions-runner-osx-x64-2.285.1.tar.gz
    popd > /dev/null
  fi
}

run_github_runner() {
  pushd "${script_dir}/actions-runner" > /dev/null
    ./config.sh --url ${repo_url} --token ${reg_token} --unattended
    ./run.sh
  popd > /dev/null
}


setup_github_runner
reg_token=$(fetch-github-registration-token $username)
run_github_runner