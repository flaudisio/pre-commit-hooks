# pre-commit hooks

Some useful hooks for [pre-commit](https://pre-commit.com/).

## Hooks available

- `check-zero-width-spaces` - Forbid files which have one or more zero width spaces (U+200B).

- `hadolint` - Run [Hadolint](https://github.com/hadolint/hadolint) on Dockerfiles.
  - You can use any Hadolint CLI argument, e.g. [`--config`][hadolint-configure], [`--ignore RULE`][hadolint-rules], `--trusted-registry`, etc.
    See the [example](#full-example) below.

- `packer-validate` - Run [`packer validate`](https://www.packer.io/docs/commands/validate.html) on JSON files.

[hadolint-configure]: https://github.com/hadolint/hadolint#configure
[hadolint-rules]: https://github.com/hadolint/hadolint#rules

## Full example

```yaml
---
repos:
  - repo: git://github.com/flaudisio/pre-commit-hooks
    rev: v0.5.1
    hooks:
      - id: check-zero-width-spaces
      - id: hadolint
        args:
          - --config .hadolint.strict.yaml
          - --ignore DL3013
          - --ignore DL3018
          - --trusted-registry registry.example.com:5000
        exclude: ^cookiecutter/
      - id: packer-validate
        files: ^templates/.+\.json$
```

## License

[MIT](LICENSE).
