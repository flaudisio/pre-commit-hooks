.PHONY: help lint bump-version/major bump-version/minor bump-version/patch

help:  ## Show available commands
	@echo "Available commands:"
	@echo
	@sed -n -E -e 's|^([A-Za-z0-9/_-]+):.+## (.+)|\1@\2|p' $(MAKEFILE_LIST) | column -s '@' -t

lint:  ## Run lint commands
	pre-commit run --all-files --verbose --show-diff-on-failure --color always

bump-version/major:  ## Increment the major version (X.y.z)
	bump2version major

bump-version/minor:  ## Increment the minor version (x.Y.z)
	bump2version minor

bump-version/patch:  ## Increment the patch version (x.y.Z)
	bump2version patch
