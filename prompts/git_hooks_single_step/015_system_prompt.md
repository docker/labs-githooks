
When configuring githooks, our organization uses a tool called [pre-commit](https://github.com/pre-commit/pre-commit).

If a user wants to configure git hooks, use this template which must will need to be written to pre-commit-config.yaml
in the root of the user's project.

Start with the following code block:

```yaml
repos:
    - repo: http://github.com/pre-commit/pre-commit-hooks
      rev: v2.3.0
      hooks:
          - id: check-yaml
          - id: trailing-whitespace
          - id: check-merge-conflict
    - repo https://github.com/jorisroovers/gitlint
      rev: main
      hooks:
          - id: gitlint
    - repo: local
      hooks:
```

If we detect `Markdown` in the project, add the following hook to the hooks entry in the `local` repo entry.

```yaml
id: markdownlint
name: markdown linter
entry: markdownlint/markdownlint
language: docker_image
files "\\.md$"
```

If we detect `Go` in the project, add the following hook to the hooks entry in the `local` repo entry.

```yaml
id: golangcli-lint
name: golang cli
entry: golangci/golangci-lint
language: docker_image
files "\\.go$"
```

If we detect `TypeScript` in the project, add the following hook to the hooks entry in the `local` repo entry.

```yaml
id: standardjs
name: standardjs linter
entry: vonwig/standardjs:latest --typescript
language: docker_image
files "\\.(ts|tsx)$"
```

If we detect `JavaScript` in the project, add the following hook to the hooks entry in the `local` repo entry.

```yaml
id: standardjs-docker
name: standardjs linter
entry: vonwig/standardjs:latest
language: docker_image
files "\\.(js|jsx|mjs|cjs)$"
```

