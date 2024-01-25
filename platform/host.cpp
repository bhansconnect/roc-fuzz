#include <cstddef>
#include <cstdint>
#include <cstdlib>

extern "C" int LLVMFuzzerRunDriver(int *argc, char ***argv,
                                   int (*UserCb)(const uint8_t *Data,
                                                 size_t Size));

struct RocList {
  uint8_t const *bytes;
  size_t len;
  size_t capacity;
};

extern "C" void roc__mainForHost_1_exposed_generic(uint8_t *out, RocList *data);

const size_t SLICE_BIT = static_cast<size_t>(1) << (8 * sizeof(size_t) - 1);
const size_t REFCOUNT_MAX = 0;

int fuzz_target(const uint8_t *data, size_t size) {
  // Create a seamless slice the references the passed in fuzz data.
  size_t rc = REFCOUNT_MAX;
  size_t slice_bits = (reinterpret_cast<size_t>(&rc) >> 1) | SLICE_BIT;
  auto input = RocList{data, size, slice_bits};

  uint8_t out;
  roc__mainForHost_1_exposed_generic(&out, &input);
  return out;
}

int main(int argc, char **argv) {
  // TODO: command line args handling before passing to libfuzzer.
  // TODO: add a way to pretty print the input.
  LLVMFuzzerRunDriver(&argc, &argv, &fuzz_target);
}

/// ===== Roc Required Functions ==============================================
// TODO: switch to arena allocation per request.
extern "C" void *roc_alloc(size_t size, unsigned int _alignment) {
  return std::malloc(size);
}

extern "C" void *roc_realloc(void *ptr, size_t new_size, size_t _old_size,
                             unsigned int _alignment) {
  return std::realloc(ptr, new_size);
}

extern "C" void roc_dealloc(void *ptr, unsigned int _alignment) {
  std::free(ptr);
}

extern "C" void roc_panic(void *msg, unsigned int _tag) { std::abort(); }

extern "C" void roc_dbg(void *loc, void *msg, void *src) { return; }
