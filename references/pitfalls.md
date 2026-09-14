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

## OneFLOW main-solver build

- **The root solver and the 1D Euler port are separate CMake projects.** A successful port build or port contract test does not compile or validate the `codes/uns` main solver. Keep `builds/solver-cpu` and `builds/port-*` separate and report them separately.
- **The root CMake reads dependency locations from environment variables.** Before configuring, verify `MPI_HOME_INC`, `MPI_HOME_LIB`, `METIS_HOME_INC`, `METIS_HOME_LIB`, `CGNS_HOME_INC`, and `CGNS_HOME_LIB`; a stale path can surface later as `metis.h` or `HXCgns.h` missing, which is an environment or cache problem rather than a source failure.
- **Do not reuse a contaminated root build directory.** CMake caches include and library paths. If the dependency layout changes, inspect `CMakeCache.txt` or configure a fresh build directory; changing shell variables alone does not reliably replace cached paths.
- **The standard cluster workspace uses a dependency subdirectory.** Treat `deps/metis-install` as a layout convention and avoid scripts that assume a sibling `metis-install` directory. Keep absolute cluster roots in private configuration, not in this skill.
- **Verify the loaded toolchain inside the job.** Record `module list`, `which gcc`, `gcc --version`, `which mpirun`, and `mpirun --version` after module setup. Login-node defaults and batch-node modules can differ.

## OneFLOW runtime and oracle traps

- **Full-solver project arguments are relative to the current case root.** The existing Python harness changes into a suite work directory and invokes the executable with a relative case name. Passing an absolute case path can make OneFLOW concatenate the current directory twice and fail while opening a script file. Reuse the harness convention for ad-hoc cases.
- **The standard five-case CPU suite does not prove the 3D batch seam ran.** Its current cases use Roe or SLAU2; the guarded main-solver seam is enabled only for CPU + five equations + Lax-Friedrichs. Add a dedicated Lax case or an explicit legacy-versus-batch oracle before claiming runtime coverage.
- **Match the legacy Lax-Friedrichs formula, not a generic Rusanov formula.** The legacy path uses Roe-averaged velocity/pressure for the maximum eigenvalue. A generic endpoint-max Rusanov implementation can compile and look plausible while failing an integrated oracle.
- **Output files need numerical comparison, not byte comparison.** Flux ordering and reductions can create tiny last-bit differences. For the 3D CPU oracle, compare the same output files with explicit absolute and relative limits, and record the observed maxima. Keep the legacy path as the reference.
- **`sbatch --test-only` is not completion evidence.** Confirm the real job in `squeue`, then use `sacct` for `COMPLETED` and `0:0`, and inspect the stage logs and machine-readable result file. Scheduler submission output alone is insufficient.

## Lifecycle integration

- **A lifecycle contract is not a production hook.** A standalone `EulerDomainStateLifecycle` test can prove invalidate → create → upload → registry ordering, but E4 is not complete until the production `INIT_FLOWFIELD`/`READ_RESTART` chain passes a real `MRField` view through a context-owned backend. Do not mark the phase complete from contract tests alone.
- **The legacy task chain has no implicit context.** `CmxTask`/`MultiSolverMultiGridTask` currently iterate solver/grid through global state; production integration must add an explicit context-aware seam and preserve the solver/zone/grid key, rather than introducing a hidden global registry pointer.

## Test harness

- `ctest` can exit 0 while discovering zero tests. Require the expected test
  count and a parseable summary; an empty discovery is not a pass.
- Backend-prefixed test names (`CPU.` / `HIP.`) prevent collisions when both
  contract binaries exist in one build tree, and stale discovery files must be
  refreshed after CMake metadata changes.
- A benchmark binary can pass while the device is absent if the failing path
  returns early; check the device count assertion first.

- **CTest filters gtest discovery names, not executable names.** After `gtest_discover_tests`, `ctest -R oneflow_...` may select zero tests; inspect `ctest -N` and filter on the discovered `Suite.Case` names, then require a non-empty expected count.

## Hardware and scheduler

- A node whose device node cannot be opened has no usable accelerator. Probe
  (`rocminfo` or equivalent) before blaming the build, and exclude the node
  from subsequent submissions.
- Accelerator jobs consume scarce resources: never iterate against a cluster
  when a login-node or local build can answer the question.
