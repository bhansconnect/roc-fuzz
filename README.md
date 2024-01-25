# Roc Fuzz

The goal of this project is to make it easy for Roc programmers to write fuzz tests for their projects.
It is a a custom platform and does not support arbitrary tasks.
As such, it is just for testing pure roc code.


Currently, it requires roc built from source on the `fuzz` branch.

Once the compiler is built, simply run targets with the `--fuzz` option.
Ok, that doesn't quite work yet.
If building locally, run as:
```
ROC_LINK_FLAGS="-lc++" roc run --linker=legacy --fuzz --prebuilt-platform app.roc
```

If running from distribution, `--prebuilt-platform` can be omitted.

### Current TODOs

1. Exposes runs and max_total_time in fuzz and minimize.
1. Exposes control over jobs and dictionary.
1. Exposes shrink corpus command.
1. Expand arbitrary to all builtin types (also Arbitrary.raw to just get all of the bytes?).
1. Add other helpers like Arbitrary.choose.
1. Vendor and build for more architecture/os pairs.
1. If possible, think of a way to enable seeding the corpus.
1. Docs and tooling to make it awesome to use.
