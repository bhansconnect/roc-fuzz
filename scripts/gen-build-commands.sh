#!/bin/bash
set -euo pipefail

cd $(dirname "${BASH_SOURCE[0]}")/..

mkdir -p build

bear --output build/compile_commands.json -- ./scripts/bundle.sh
