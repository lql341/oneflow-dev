# oneflow-dev

An agent skill for developing [OneFLOW](https://github.com/eric2003/OneFLOW),
focused on the one-dimensional Euler CPU/DCU port and its validation workflow.

It packages the rules and hard-won environment knowledge around:

- **workflow** — fork/upstream branching, regression gates per change type and
  a pull-request checklist;
- **test suites** — four standard suites with resource tuples and pass
  criteria, plus the comparability rule that keeps benchmark numbers honest;
- **build matrix** — the main CPU solver and the 1D Euler port in its CPU,
  HIP and HIP+MPI configurations;
- **reports** — naming, expected content, publication boundary and errata
  handling;
- **pitfalls** — toolchain traps (compiler version floors, MPI C++ bindings,
  CMake dependency forwarding) and test-harness traps (silent zero-test
  passes, backend prefixes).

Cluster connectivity is intentionally out of scope: use the companion
[`scnet-hpc`](https://github.com/lql341/scnet-hpc) skill for SSH, Slurm
profiles and node probing. This repository contains no credentials, account
names or private paths.

## Install

```bash
mkdir -p ~/.claude/skills   # or ~/.codex/skills, depending on your agent
git clone https://github.com/lql341/oneflow-dev.git
cp -r oneflow-dev ~/.claude/skills/
```

The skill is a plain directory with a `SKILL.md`; any agent that discovers
skills by scanning a directory can load it.

## Layout

```text
oneflow-dev/
├── SKILL.md                  entry point (front matter + routing table)
├── references/
│   ├── workflow.md
│   ├── kunshan-suites.md
│   ├── build-matrix.md
│   ├── reports.md
│   └── pitfalls.md
└── tests/validate.sh         structural checks
```

## License

MIT
