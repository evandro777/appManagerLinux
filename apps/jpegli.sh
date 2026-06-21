#!/usr/bin/env bash
set -euo pipefail

readonly IS_APT_PACKAGE=0
readonly APPLICATION_NAME="jpegli [compiled from source: bug]"
readonly APPLICATION_ID="jpegli"
readonly APPLICATION_BINARIES=("/usr/local/bin/cjpegli" "/usr/local/bin/djpegli")

function perform_install() {
    package_update
    package_install git cmake ninja-build clang pkg-config

    local build_dir
    build_dir=$(mktemp -d "/tmp/${APPLICATION_ID}-build.XXXXXX")

    function cleanup() {
        rm -rf "$build_dir"
    }
    trap cleanup EXIT

    git clone --depth=1 https://github.com/google/jpegli.git "$build_dir/$APPLICATION_ID"
    cd "$build_dir/$APPLICATION_ID"

    ./deps.sh

    mkdir -p build
    cd build

    export CC=clang
    export CXX=clang++

    cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF ..
    ninja -j"$(nproc)"

    for target in "${APPLICATION_BINARIES[@]}"; do
        local name
        name=$(basename "$target")
        sudo install -m 755 "tools/$name" "$target"
    done

    echo
    echo "Installed ${APPLICATION_NAME} binaries to /usr/local/bin"
    for target in "${APPLICATION_BINARIES[@]}"; do
        echo "  $target"
    done
}

function perform_uninstall() {
    sudo rm -f "${APPLICATION_BINARIES[@]}"
}

function perform_check() {
    for target in "${APPLICATION_BINARIES[@]}"; do
        if [[ ! -x "$target" ]]; then
            echo 0
            return
        fi
    done
    echo 1
}

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../includes/header_packages.sh"

exit 0
