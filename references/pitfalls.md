# Known traps

These were each paid for once; do not rediscover them.

## Toolchain

- **GCC 7.3.1 cannot build the main solver.** It uses `std::filesystem` and
  C++17 exception-specification deduction. Use GCC 9.3.0+.
- **Some cluster modulefiles point at the wrong prefix.** A module for
  `gcc/11.2.0` may prepend `<prefix>/gcc/11.2.0/bin` while the installation
  lives in `<prefix>/gcc-11.2.0/bin`. Verify `which gcc` after loading.
- **OpenMPI 4.x has no C++ bindings**, but its `mpi.h` still pulls the
  compatibility headers. Link errors mentioning `MPI::` are fixed with
  `-DOMPI_SKIP_MPICXX`; the solver only uses the C API.
- **HIP language detection re-runs `find_package` in a `try_compile`
  sub-project.** Dependency search paths must be exported as environment
  variables; `-D` cache entries are not forwarded.
- **METIS is often not installed cluster-wide.** Build it from source with the
  same compiler as the solver.

## Test harness

- `ctest` can exit 0 while discovering zero tests. Require the expected test
  count and a parseable summary; an empty discovery is not a pass.
- Backend-prefixed test names (`CPU.` / `HIP.`) prevent collisions when both
  contract binaries exist in one build tree, and stale discovery files must be
  refreshed after CMake metadata changes.
- A benchmark binary can pass while the device is absent if the failing path
  returns early; check the device count assertion first.

## Hardware and scheduler

- A node whose device node cannot be opened has no usable accelerator. Probe
  (`rocminfo` or equivalent) before blaming the build, and exclude the node
  from subsequent submissions.
- Accelerator jobs consume scarce resources: never iterate against a cluster
  when a login-node or local build can answer the question.
