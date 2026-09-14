# Standard test suites

Four suites cover correctness and performance. Names double as artifact
directory names under a dated run root.

| Suite | Partition | Resources | Content | Pass criteria |
|---|---|---|---|---|
| `cpu-regression` | CPU partition | 16 CPU, ~54G | five-case normal + strict; port CPU contract test | 5/5 normal, 5/5 strict, 8/8 contract |
| `dcu-single` | accelerator partition | 8 CPU, ~27G, 1 DCU | HIP contract test; stateful benchmark, four sizes | 6/6 contracts; max abs error 0; CPU/HIP checksums equal |
| `cpu-mpi` | CPU partition | 32 ranks × 1 CPU | 32-rank CPU MPI benchmark, four sizes | exit 0; hashes valid |
| `dcu-mpi` | accelerator partition | 4 ranks × 8 CPU, 4 DCU | 1-rank and 4-rank DCU MPI benchmark | exit 0; hashes match `cpu-mpi`; `visible_devices=4` |

Common benchmark scale and parameters:

```text
nx     = 65536 / 262144 / 1048576 / 4194304
steps  = 100
repeats= 2
warmup = 1
```

## Reporting contract for every run

Record next to the artifacts:

- source revision under test;
- toolchain versions (compiler, MPI, DTK, CMake, Python);
- Slurm resource tuple actually allocated;
- per-stage logs and a machine-readable `result.txt`;
- for accelerator runs, the device probe output (`gfx` architecture, visible
  device count).

## Comparability rule

`lifecycle_*_ms` sums over `repeats`. Two datasets are comparable only when
`steps`, `repeats`, `warmup` and the resource tuple match. When in doubt,
re-run the baseline rather than reusing a historical number.

## CPU regression suites (project-level)

The five serial CPU cases are defined by the project's `test/suites` list and
compared against checked-in baselines in both a normal (`1e-8`) and a strict
(`1e-15`, full-precision output) profile. An empty test discovery or a zero
exit code without the expected summary is not a pass.

## Main-solver CPU batch oracle

The standard suite is not sufficient to prove the guarded 3D batch seam because
its cases currently use Roe or SLAU2. Use the repository's
`ci/kunshan/e3-cpu-oracle.slurm` with an already-built CPU solver to run the
same 3D case twice: once with the legacy path and once with
`ONEFLOW_ENABLE_UNS_CPU_BATCH=1`, using Lax-Friedrichs. Compare the resulting
`aero.dat`, `wallaero.dat`, `res.dat`, and `turbres.dat` numerically, and accept
the job only when both the file comparison and Slurm accounting pass.
