# Repository workflow

## Remotes

- `origin` — the contributor fork.
- `upstream` — the canonical OneFLOW repository.

Sync before branching; never develop directly on the default branch.

```bash
git fetch upstream
git checkout -b <type>/<short-topic> upstream/master
```

## Change size and commits

- One logical change per commit; the subject states the effect, the body says
  why and how it was checked.
- Do not mix formatting-only edits with behavior changes.
- Keep generated artifacts (`build/`, run logs) out of commits.

## Regression gates by change type

| Change | Required evidence |
|---|---|
| Numerical kernel / backend | Five-case CPU suite, normal `1e-8` + strict `1e-15`; HIP contract test when a device path is touched |
| Port build system / tests | Port CPU contract test; HIP contract test if the HIP targets are touched |
| Documentation / reports only | Link check; keep Markdown and HTML in sync |
| CMake / CI scripts | Local configure+build of the affected target |

## Pull request checklist

1. Local build succeeds for every touched configuration.
2. Relevant test suite passes; paste the summary line, not a screenshot.
3. Push and wait for CI to go green. A PR that fails checks is not ready for
   review.
4. The description states scope, evidence and known limits. Do not claim
   capabilities that were not measured on a target compute node.
5. Rebase on `upstream/master` before asking for review when the base moved.

## Common failure modes to avoid

- Reporting success from a local run while CI is red.
- Quoting performance numbers recorded with different benchmark parameters.
- Assuming the main build covers the port (they are separate CMake projects).
- Letting a PR grow across unrelated topics.
