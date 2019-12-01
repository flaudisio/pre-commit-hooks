# pre-commit hooks

Some useful hooks for [pre-commit](https://pre-commit.com/).

## Hooks available

- `check-zero-width-spaces` - Forbid files which have one or more zero width spaces (U+200B).

- `hadolint` - Run [Hadolint](https://github.com/hadolint/hadolint) on Dockerfiles.
  - `--ignore=RULE` (or `--ignore RULE`): a [rule](https://github.com/hadolint/hadolint#rules) to ignore. Can be specified multiple times.

- `packer-validate` - Run `packer validate` on Packer template files.

## License

[MIT](LICENSE).
