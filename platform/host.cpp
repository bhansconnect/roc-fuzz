#include "argparse.hpp"
#include <cstddef>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <string_view>

extern "C" int LLVMFuzzerRunDriver(const int *argc, const char ***argv,
                                   int (*UserCb)(const uint8_t *Data,
                                                 size_t Size));

struct RocList {
  uint8_t const *bytes;
  size_t len;
  size_t capacity;
};

struct Out {
  RocList list;
  uint8_t status;
};

extern "C" void roc__mainForHost_1_exposed_generic(Out *out, RocList *data,
                                                   uint8_t command);

const uint8_t CMD_FORMAT = 0;
const uint8_t CMD_FUZZ = 1;

const size_t SLICE_BIT = static_cast<size_t>(1) << (8 * sizeof(size_t) - 1);
const size_t REFCOUNT_MAX = 0;

int fuzz_target(const uint8_t *data, size_t size);
std::vector<uint8_t> read_file(char const *filename);

int main(int argc, char **argv) {
  argparse::ArgumentParser program("fuzz-target");

  // git add subparser
  argparse::ArgumentParser fuzz_command("fuzz");
  fuzz_command.add_description("Run the fuzz target and attempt to find bugs");

  // git commit subparser
  argparse::ArgumentParser fmt_command("fmt");
  fmt_command.add_description(
      "Format a crash or test case for viewing by the user");
  fmt_command.add_argument("file")
      .help("File of raw bytes to be formatted and printed")
      .required();

  program.add_subparser(fuzz_command);
  program.add_subparser(fmt_command);

  try {
    program.parse_args(argc, argv);
  } catch (const std::exception &err) {
    std::cerr << err.what() << '\n' << std::endl;
    if (program.is_subcommand_used(fuzz_command)) {
      std::cerr << fuzz_command;
    } else if (program.is_subcommand_used(fmt_command)) {
      std::cerr << fmt_command;
    } else {
      std::cerr << program;
    }
    return 1;
  }

  if (program.is_subcommand_used(fuzz_command)) {
    std::vector<const char *> fuzz_args = {argv[0]};

    int fuzz_argc = static_cast<int>(fuzz_args.size());
    const char **fuzz_argv = fuzz_args.data();
    LLVMFuzzerRunDriver(&fuzz_argc, &fuzz_argv, &fuzz_target);

  } else if (program.is_subcommand_used(fmt_command)) {
    auto filename = fmt_command.get<std::string>("file");
    auto bytes = read_file(filename.c_str());

    // Create a seamless slice the references the passed in fuzz data.
    size_t rc = REFCOUNT_MAX;
    size_t slice_bits = (reinterpret_cast<size_t>(&rc) >> 1) | SLICE_BIT;
    auto input = RocList{bytes.data(), bytes.size(), slice_bits};

    Out out;
    roc__mainForHost_1_exposed_generic(&out, &input, CMD_FORMAT);

    std::cout << std::string_view(
                     reinterpret_cast<const char *>(out.list.bytes),
                     out.list.len)
              << std::endl;
  } else {
    std::cerr << program;
  }
  return 0;
}

int fuzz_target(const uint8_t *data, size_t size) {
  // Create a seamless slice the references the passed in fuzz data.
  size_t rc = REFCOUNT_MAX;
  size_t slice_bits = (reinterpret_cast<size_t>(&rc) >> 1) | SLICE_BIT;
  auto input = RocList{data, size, slice_bits};

  Out out;
  roc__mainForHost_1_exposed_generic(&out, &input, CMD_FUZZ);
  return out.status;
}

std::vector<uint8_t> read_file(char const *filename) {
  std::ifstream ifs(filename, std::ios::binary | std::ios::in | std::ios::ate);
  std::ifstream::pos_type pos = ifs.tellg();

  if (pos == 0) {
    return std::vector<uint8_t>{};
  }

  std::vector<uint8_t> result(static_cast<size_t>(pos));

  ifs.seekg(0, std::ios::beg);
  ifs.read(reinterpret_cast<char *>(result.data()), pos);

  return result;
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
