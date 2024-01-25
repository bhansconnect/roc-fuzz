#!/bin/bash
set -euo pipefail

cd $(dirname "${BASH_SOURCE[0]}")/..

mkdir -p build

# TODO: deal with multiple platforms.

clang++ -std=c++17 -g -O1 \
  -Wall -Wpedantic -Wsign-conversion -Wconversion -Werror -Wextra -Wno-unused-parameter \
  -fsanitize-coverage=inline-8bit-counters \
  -fsanitize-coverage=pc-table \
  -fsanitize-coverage=trace-cmp \
  -I vendor \
  platform/host.cpp -c -o build/platform.o

cp vendor/libclang_rt.fuzzer_no_main_osx.arm64.a platform/macos-arm64.a

ar -r platform/macos-arm64.a build/platform.o
