# pre-commit hooks

Some hooks for [pre-commit](https://pre-commit.com/).

## Hooks available

- `check-zero-width-spaces` - Forbid files which have one or more zero width spaces (U+200B).

- `hadolint` - Run [Hadolint](https://github.com/hadolint/hadolint) on Dockerfiles.
  - You may use any Hadolint CLI argument, e.g. [`--config example.yaml`][hadolint-configure], [`--ignore RULE`][hadolint-rules],
    `--trusted-registry REGISTRY`, etc. See the [example](#full-example) below.

- `packer-validate` - Run [`packer validate`](https://www.packer.io/docs/commands/validate.html) on JSON files.

[hadolint-configure]: https://github.com/hadolint/hadolint#configure
[hadolint-rules]: https://github.com/hadolint/hadolint#rules

## How to install

1. Install dependencies:
   - [pre-commit](https://pre-commit.com/#install)
   - Hadolint (for `hadolint`)
   - Packer (for `packer-validate`)

2. Install the pre-commit hook globally:

    ```console
    $ pre-commit init-templatedir -t pre-commit ~/.git-template
    ```

3. Create the `.pre-commit-config.yaml` file:

    ```console
    $ cd /path/to/my/repo/
    $ vim .pre-commit-config.yaml
    ```

    **Tip:** use the example from the next section as a start point.

4. Run:

    ```console
    $ pre-commit run -a
    ```

## Full example

```yaml
# .pre-commit-config.yaml

repos:
  - repo: git://github.com/flaudisio/pre-commit-hooks
    rev: v0.7.2
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
