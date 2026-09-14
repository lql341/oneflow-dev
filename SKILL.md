---
name: oneflow-dev
description: OneFLOW development and Kunshan DCU validation workflow. Use when working in an OneFLOW repository (fork/upstream model), preparing or reviewing pull requests, building the 1D Euler port, running CPU/DCU regression suites on SCNet Kunshan, or writing and auditing performance reports. Enforces regression-first verification, same-basis performance comparisons, and a reproducible workspace layout.
---

# OneFLOW development

Development workflow, build matrix, cluster test suites and reporting rules for
the OneFLOW CFD project, with emphasis on the one-dimensional Euler CPU/DCU
port and its Kunshan validation.

## How to route the task

| Task | Read |
|---|---|
| Branch, PR, CI, regression gates | `references/workflow.md` |
| Cluster test suites, resources, pass criteria | `references/kunshan-suites.md` |
| Building the CPU solver or the 1D Euler port (CPU/HIP/HIP+MPI) | `references/build-matrix.md` |
| Writing or auditing reports, naming, publication boundary | `references/reports.md` |
| Known environment and toolchain traps | `references/pitfalls.md` |

Cluster connection details (hosts, ports, SSH setup, profiles) are out of scope
here — use the `scnet-hpc` skill for that and keep this repository free of
credentials and personal paths.

## Resuming work (start of every session)

Personal, non-upstream work lives on the fork's `dev` branch. Begin a session
with:

```bash
git fetch origin
git checkout dev && git pull --ff-only
cat doc/plans/oneflow-development-todo.md
```

If the working tree must stay on another branch, read the todo without
switching:

```bash
git show dev:doc/plans/oneflow-development-todo.md
```

The todo document is the session entry point: current state snapshot,
prioritized backlog, cold-start context and the definition of done. Update it
before ending the session, and keep its updates as standalone commits so PR
branches can exclude them.

## Non-negotiable rules

1. **Regression before pull request.** Numerical-kernel or backend changes
   require the CPU five-case suite (normal `1e-8` and strict `1e-15`) and, for
   DCU/HIP changes, the HIP contract test on a real compute node. Do not call a
   change validated on the strength of a build alone.
2. **Green CI before "done".** Push, wait for the repository checks, then
   report. A closed PR for failing checks is a wasted review cycle.
3. **Same-basis comparisons only.** Benchmark `lifecycle_*_ms` values sum over
   `repeats`; never divide datasets recorded with different `repeats`.
4. **Markdown is the source of truth.** When a report has a matching HTML,
   update both in the same change.
5. **The port is built separately from the main solver.** A root-build result
   says nothing about DCU capability.
