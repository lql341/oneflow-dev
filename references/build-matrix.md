# Build matrix

Four configurations are built and tested independently. Replace
`<repo>` with the checkout and `<work>` with a workspace root.

## 1. Main solver (CPU)

```bash
cmake -S <repo> -B <work>/builds/solver-cpu \
  -DCMAKE_BUILD_TYPE=Release \
  -DMPI_ENABLE=ON -DMETIS_ENABLE=ON -DCGNS_ENABLE=ON \
  -DCMAKE_CXX_FLAGS="-DOMPI_SKIP_MPICXX"
cmake --build <work>/builds/solver-cpu --parallel 16
```

Requirements: GCC 9.3.0 or newer (GCC 7 cannot build the tree), an MPI with
development files, METIS, CGNS. Dependency locations are passed through the
`*_HOME_INC` / `*_HOME_LIB` environment variables read by the top-level CMake.

## 2. 1D Euler port — CPU contract test

```bash
cmake -S <repo>/ports/kunshan/oneflow_1d_hip -B <work>/builds/port-cpu \
  -DCMAKE_BUILD_TYPE=Release \
  -DONEFLOW_1D_ENABLE_GTEST=ON -DONEFLOW_1D_ENABLE_HIP=OFF
cmake --build <work>/builds/port-cpu \
  --target oneflow_1d_euler_cpu_backend_test
```

## 3. 1D Euler port — HIP contract test and stateful benchmark

```bash
cmake -S <repo>/ports/kunshan/oneflow_1d_hip -B <work>/builds/port-dcu \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=<clang> -DCMAKE_CXX_COMPILER=<clang++> \
  -DCMAKE_HIP_COMPILER=<clang++> \
  -DCMAKE_HIP_ARCHITECTURES=<target-arch> \
  -Dhsa-runtime64_DIR=<dtk>/.hyhal/lib/cmake/hsa-runtime64 \
  -DHSA_HEADER=<dtk>/.hyhal/include \
  -DONEFLOW_1D_ENABLE_HIP=ON -DONEFLOW_1D_ENABLE_GTEST=ON
```

## 4. 1D Euler port — HIP + MPI benchmark

Same as (3) plus:

```bash
-DONEFLOW_1D_ENABLE_MPI_BENCHMARK=ON
CC=mpicc CXX=mpicxx
# CMake does not forward the amd_comgr/AMDDeviceLibs search paths into the
# HIP try_compile step from cache variables; export them as an environment
# variable before configuring:
export CMAKE_PREFIX_PATH="<dtk>/dcc/comgr/lib64/cmake/amd_comgr:<dtk>/dcc/lib64/cmake/AMDDeviceLibs:<dtk>:<dtk>/.hyhal"
```

## Benchmarks

- `oneflow_1d_euler_stateful_benchmark <nx> <steps> <repeats> <warmup>` —
  single-thread CPU versus single accelerator, full lifecycle.
- `oneflow_1d_euler_mpi_*_benchmark <global_nx> <steps> <repeats> <warmup>` —
  MPI variant; prints per-rank maxima, halo and synchronization counters, and
  a global hash for cross-backend equality checks.

Do not enable rank/device sharing or pinning patterns without reading the port
sources first: rank-to-device mapping is derived from local rank and the
visible device count, and strict modes reject rank counts above the visible
device count.
