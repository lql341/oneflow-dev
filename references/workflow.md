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

## Fork-first collaboration

Work happens in the contributor fork by default, on a single long-lived `dev`
branch:

- `master` mirrors `upstream/master` and serves only as the PR baseline and
  read-only reference;
- `dev` is the single personal branch (fork + local). It carries the
  fork-only todo/handoff document, in-progress features and notes; push it to
  the fork for backup;
- **do not open upstream pull requests proactively.** Open one only when the
  user explicitly asks; until then keep everything in `dev`;
- when a PR is requested: branch from `upstream/master` (**not** from `dev`),
  cherry-pick the feature commits from `dev` excluding the fork-only document
  commits, push, and wait for the checks; delete the temporary branch after
  merge;
- rationale: every push to a PR branch triggers workflows in the base
  repository (noise and review churn); a half-finished PR is hard to reshape;
  a single dev branch rebases freely.

Keep the fork-only document updates as standalone commits so that
`git cherry-pick` can exclude them precisely when preparing a PR.

## Local toolchains

Before downloading a toolchain tarball, check whether the workstation already
provides a user-level Environment Modules tree: look for a `module-init.sh`
next to the project or in the user's workspace, `source` it, then run
`module avail`. Prefer those modules so local versions stay consistent with
the cluster. Do not leave durable tools in `/tmp`; it is often tmpfs and gets
cleared between sessions.

## Fork-only documents

Some repositories keep a development todo/handoff document that must stay in
the contributor fork and never appear in an upstream pull request.

Maintain it on the fork's long-lived `dev` branch:

- update it at the end of every work session: state snapshot, backlog
  checkboxes, completed log;
- never add it to a branch that will be proposed upstream, and never include
  it in an upstream PR;
- after upstream moves, rebase or otherwise synchronize `dev` deliberately;
  do not mix the fork-only todo with an upstream feature branch.

Update flow:

```bash
git checkout dev
# edit doc/plans/oneflow-development-todo.md
git commit -am "Update development todo: <summary>"
# push origin/dev only when explicitly authorized
git checkout <working branch>
```

## Common failure modes to avoid

- Reporting success from a local run while CI is red.
- Quoting performance numbers recorded with different benchmark parameters.
- Assuming the main build covers the port (they are separate CMake projects).
- Letting a PR grow across unrelated topics.
