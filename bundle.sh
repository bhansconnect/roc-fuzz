#!/bin/sh
set -e

mkdir -p build

# TODO: deal with multiple platforms.

clang++ -g -O1 -c \
  -fsanitize-coverage=inline-8bit-counters \
  -fsanitize-coverage=pc-table \
  -fsanitize-coverage=trace-cmp \
  platform/host.cpp -o build/platform.o

cp vendor/libclang_rt.fuzzer_no_main_osx.arm64.a platform/macos-arm64.a

ar -r platform/macos-arm64.a build/platform.o
