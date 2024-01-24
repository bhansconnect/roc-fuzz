# Roc Fuzz

The goal of this project is to make it easy for Roc programmers to write fuzz tests for their projects.
It is a a custom platform and does not support arbitrary tasks.
As such, it is just for testing pure roc code.


Currently, it requires roc built from source on the `fuzz` branch.

Once the compiler is built, simply run targets with the `--fuzz` option.
