#include "argparse.hpp"
#include <cstddef>
#include <cstdint>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <string_view>
#include <vector>

extern "C" int LLVMFuzzerRunDriver(const int *argc, const char ***argv,
                                   int (*UserCb)(const uint8_t *Data,
                                                 size_t Size));

struct RocList {
  const uint8_t *bytes;
  size_t len;
  size_t capacity;
};
struct RocStr {
  const uint8_t *bytes;
  size_t len;
  size_t capacity;

  std::string_view as_string_view();
};
struct Out {
  RocStr str;
  uint8_t status;
};

extern "C" void roc__mainForHost_1_exposed_generic(Out *out, RocList *data,
                                                   uint8_t command);

const uint8_t CMD_FUZZ = 0;
const uint8_t CMD_NAME = 1;
const uint8_t CMD_SHOW = 2;

const size_t SLICE_BIT = static_cast<size_t>(1) << (8 * sizeof(size_t) - 1);
const size_t REFCOUNT_MAX = 0;

int fuzz_target(const uint8_t *data, size_t size);
std::vector<uint8_t> read_file(char const *filename);

int call_libfuzzer(std::vector<const char *> args) {
  int argc = static_cast<int>(args.size());
  const char **argv = args.data();

  return LLVMFuzzerRunDriver(&argc, &argv, &fuzz_target);
}

int main(int argc, char **argv) {
  argparse::ArgumentParser program("fuzz-target");

  argparse::ArgumentParser fuzz_command("fuzz");
  fuzz_command.add_description("Run the fuzz target and attempt to find bugs");
  fuzz_command.add_argument("-c", "--corpus")
      .help("The directory where the corpus stored. Defaults to "
            "\"corpus/<target-name>\".");

  argparse::ArgumentParser minimize_command("minimize");
  minimize_command.add_description(
      "Attempt to minimize a test case to the smallest possible input");
  minimize_command.add_argument("file")
      .help("File of raw bytes to be minimized")
      .required();

  argparse::ArgumentParser show_command("show");
  show_command.add_description("Show the crash or test case inputs");
  show_command.add_argument("file")
      .help("File of raw bytes to be formatted and printed")
      .required();

  argparse::ArgumentParser raw_command("raw");
  raw_command.add_description(
      "Allows raw access to the underlying libFuzzer cli");

  program.add_subparser(fuzz_command);
  program.add_subparser(minimize_command);
  program.add_subparser(show_command);
  program.add_subparser(raw_command);

  // No subcommand. Earrly exit with help menu.
  if (argc < 2) {
    std::cerr << program;
    return 1;
  }

  // The raw subcommand doesn't seem to work correctly... just manually handle
  // it.
  auto lib_fuzzer_cli = std::string(argv[0]) + " raw";
  if (std::string(argv[1]) == "raw") {
    std::vector<const char *> fuzz_args = {lib_fuzzer_cli.c_str()};
    fuzz_args.reserve(static_cast<size_t>(argc - 2));
    for (int i = 2; i < argc; ++i) {
      fuzz_args.push_back(argv[i]);
    }
    return call_libfuzzer(fuzz_args);
  }

  try {
    program.parse_args(argc, argv);
  } catch (const std::exception &err) {
    std::cerr << err.what() << '\n' << std::endl;
    if (program.is_subcommand_used(fuzz_command)) {
      std::cerr << fuzz_command;
    } else if (program.is_subcommand_used(minimize_command)) {
      std::cerr << minimize_command;
    } else if (program.is_subcommand_used(show_command)) {
      std::cerr << show_command;
    } else if (program.is_subcommand_used(raw_command)) {
      std::cerr << raw_command;
    } else {
      std::cerr << program;
    }
    return 1;
  }

  if (program.is_subcommand_used(fuzz_command)) {
    std::filesystem::path corpus;
    if (fuzz_command.is_used("-c")) {
      corpus = fuzz_command.get<std::string>("-c");
    } else {
      auto input = RocList{nullptr, 0, 0};
      Out out;
      roc__mainForHost_1_exposed_generic(&out, &input, CMD_NAME);

      auto name = out.str.as_string_view();
      corpus = "corpus";
      corpus = corpus / name;
    }
    std::filesystem::create_directories(corpus);

    std::string artifact_path = "-artifact_prefix=" + (corpus / "").string();
    std::vector<const char *> fuzz_args = {
        lib_fuzzer_cli.c_str(), artifact_path.c_str(), corpus.c_str()};

    return call_libfuzzer(fuzz_args);
  } else if (program.is_subcommand_used(minimize_command)) {
    auto filename = minimize_command.get<std::string>("file");
    std::filesystem::path file_path = filename;

    std::string artifact_path =
        "-artifact_prefix=" + (file_path.remove_filename() / "").string();
    std::vector<const char *> fuzz_args = {
        lib_fuzzer_cli.c_str(), "-runs=10000", "-minimize_crash=1",
        artifact_path.c_str(), filename.c_str()};

    return call_libfuzzer(fuzz_args);
  } else if (program.is_subcommand_used(show_command)) {
    auto filename = show_command.get<std::string>("file");
    auto bytes = read_file(filename.c_str());

    // Create a seamless slice the references the passed in fuzz data.
    size_t rc = REFCOUNT_MAX;
    size_t slice_bits = (reinterpret_cast<size_t>(&rc) >> 1) | SLICE_BIT;
    auto input = RocList{bytes.data(), bytes.size(), slice_bits};

    Out out;
    roc__mainForHost_1_exposed_generic(&out, &input, CMD_SHOW);

    std::cout << out.str.as_string_view() << std::endl;
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

std::string_view RocStr::as_string_view() {
  bool small_str = static_cast<ptrdiff_t>(this->len) < 0;
  const char *data;
  size_t len;
  if (small_str) {
    data = reinterpret_cast<const char *>(this);
    len = static_cast<size_t>(data[sizeof(size_t) * 3 - 1] & 0x7F);
  } else {
    data = reinterpret_cast<const char *>(this->bytes);
    len = this->len;
  }
  return {data, len};
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

extern "C" void roc_panic(RocStr *msg, unsigned int _tag) {
  std::cerr << "Roc panicked: " << msg->as_string_view() << std::endl;
  std::abort();
}

extern "C" void roc_dbg(void *loc, void *msg, void *src) { return; }
