#!/bin/bash
set -euxo pipefail

cd $(dirname "${BASH_SOURCE[0]}")/..

mkdir -p build

# TODO: deal with multiple platforms.

build_target() {
  TARGET=$1
  ROC_TARGET=$2
  zig c++ -std=c++17 -g -O1 -target ${TARGET} \
    -Wall -Wpedantic -Wsign-conversion -Wconversion -Werror -Wextra -Wno-unused-parameter \
    -fsanitize-coverage=inline-8bit-counters \
    -fsanitize-coverage=pc-table \
    -fsanitize-coverage=trace-cmp \
    -I vendor \
    platform/host.cpp -c -o build/platform.${ROC_TARGET}.o

  cp vendor/libclang_rt.fuzzer_no_main.${ROC_TARGET}.a platform/${ROC_TARGET}.a

  zig ar -r platform/${ROC_TARGET}.a build/platform.${ROC_TARGET}.o
}

build_target x86_64-macos macos-x64
build_target aarch64-macos macos-arm64
build_target x86_64-linux linux-x64
build_target aarch64-linux linux-arm64
