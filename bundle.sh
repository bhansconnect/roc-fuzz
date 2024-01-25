#!/bin/sh
set -e

mkdir -p build

# TODO: deal with multiple platforms.

clang++ -std=c++17 -g -O1 -c \
  -Wall -Wpedantic -Wsign-conversion -Wconversion -Werror -Wextra -Wno-unused-parameter \
  -fsanitize-coverage=inline-8bit-counters \
  -fsanitize-coverage=pc-table \
  -fsanitize-coverage=trace-cmp \
  platform/host.cpp -o build/platform.o

cp vendor/libclang_rt.fuzzer_no_main_osx.arm64.a platform/macos-arm64.a

ar -r platform/macos-arm64.a build/platform.o
