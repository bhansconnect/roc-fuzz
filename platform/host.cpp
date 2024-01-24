#include <cstddef>
#include <cstdint>

extern "C" int LLVMFuzzerRunDriver(int *argc, char ***argv,
                  int (*UserCb)(const uint8_t *Data, size_t Size));


int FuzzTarget(const uint8_t* Data, size_t Size) {
  return 0;
}

int main(int argc, char **argv) {
  LLVMFuzzerRunDriver(&argc, &argv, &FuzzTarget);
}
