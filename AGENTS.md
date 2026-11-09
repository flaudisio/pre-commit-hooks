# AGENTS.md

Published pre-commit hook collection (`flaudisio/pre-commit-hooks`). There is no application code:
four scripts in `hooks/` plus YAML manifests that consumers pin by git tag (`rev: vX.Y.Z`).

## Layout

- `hooks/*.sh` — hook entrypoints. pre-commit appends the selected filenames as trailing argv,
  after any `args:` the consumer configured.
- `.pre-commit-hooks.yaml` — the published contract (id, entry, `types`/`files` filters).
  Editing it changes behavior for downstream repos.
- `.pre-commit-config.yaml` — lints *this* repo, not consumers: shellcheck, `yamllint --strict`,
  and pre-commit-hooks.
- `VERSION`, `.bumpversion.toml` (`current_version`), README `rev:` example — one version in three
  places, kept in sync only by the bump tool.

## Checks

- `mise run lint` — the only test suite (repo has no unit tests); runs `prek run --all-files` and
  reads the unchanged `.pre-commit-config.yaml`.
- A hook change is verified by running the script directly on a sample file and checking the exit
  code and stderr, since pre-commit's own filters are what the manifest provides.
- `yamllint` uses `--strict`, so warnings fail the build.
- `nomad-fmt.sh` is deliberately POSIX `sh`; the other scripts are `bash` with
  `set -u -o pipefail` (via separate `set` lines).

## Hook script conventions

- Exit non-zero on any failure but keep scanning the remaining files; `hadolint.sh`,
  `check-zero-width-spaces.sh` and `packer-validate.sh` accumulate `exit_code` instead of exiting
  early.
- `hadolint.sh` parses leading `-*` arguments because the runner passes consumer `args:` before the
  file list; `add_hadolint_arg` splits a single `"--param value"` token into two argv entries.
- `packer-validate.sh` `pushd`s into each template's directory because Packer resolves relative
  paths from there.
- New scripts need the executable bit — `language: script` fails without it — plus an entry in
  `.pre-commit-hooks.yaml` and a bullet in the README hook list.

## Releases

- `mise run bump-version:patch` (or `:minor`, `:major`) bumps `VERSION` and the README `rev:` line,
  commits, and tags `vX.Y.Z`. Do not hand-edit those files.
- `mise run git-push` pushes the branch with tags. Only push or open a PR when asked.
- Dependabot covers GitHub Actions only; `rev:` pins in `.pre-commit-config.yaml` are bumped
  manually with `prek autoupdate`.
