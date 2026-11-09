# Hooks for pre-commit and prek

Miscellaneous hooks for [pre-commit](https://pre-commit.com/) and
[prek](https://github.com/j178/prek), its Rust drop-in replacement. Both consume the same
`.pre-commit-hooks.yaml` manifest, so every hook below works with either runner.

## Hooks available

- `check-zero-width-spaces` - Forbid files which have one or more zero width spaces (U+200B).

- `hadolint` - Run [Hadolint](https://github.com/hadolint/hadolint) on Dockerfiles.
  - You may use any Hadolint CLI argument, e.g.
    [`--config example.yaml`](https://github.com/hadolint/hadolint#configure),
    [`--ignore RULE`](https://github.com/hadolint/hadolint#rules),
    `--trusted-registry REGISTRY`, etc. See the [example](#full-example) below.

- `nomad-fmt` - Run [`nomad fmt`](https://developer.hashicorp.com/nomad/commands/fmt) on Nomad
  manifests.

- `packer-validate` - Run
  [`packer validate`](https://developer.hashicorp.com/packer/docs/commands/validate) on JSON files.

## How to install

The steps are the same for both runners; substitute `prek` for `pre-commit` where you see it.

1. Install dependencies:
   - [pre-commit](https://pre-commit.com/#install) or
     [prek](https://github.com/j178/prek#installation)
   - [Hadolint](https://github.com/hadolint/hadolint/releases) (for `hadolint`)
   - [Nomad](https://developer.hashicorp.com/nomad/install) (for `nomad-fmt`)
   - [Packer](https://developer.hashicorp.com/packer/install) (for `packer-validate`)

1. Enable the hook. With pre-commit, globally for future repos:

    ```bash
    pre-commit init-templatedir -t pre-commit ~/.git-template
    ```

    With prek, inside each repository:

    ```bash
    prek install
    ```

1. Create the `.pre-commit-config.yaml` file:

    ```bash
    cd /path/to/my/repo/
    vim .pre-commit-config.yaml
    ```

    **Tip:** use the example from the next section as a start point: prek reads it unchanged.

1. Run:

    ```bash
    pre-commit run -a
    # or
    prek run -a
    ```

## Full example

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/flaudisio/pre-commit-hooks
    rev: v0.11.1
    hooks:
      - id: check-zero-width-spaces
      - id: hadolint
        args:
          - --config .hadolint.strict.yaml
          - --ignore DL3013
          - --ignore DL3018
          - --trusted-registry registry.example.com:5000
        exclude: ^cookiecutter/.+/Dockerfile$
      - id: packer-validate
        files: ^templates/.+\.json$
```

## License

[MIT](LICENSE).
