# pre-commit

Trying locally

```
python -m venv .venv
source .venv/bin/activate
pip install pre-commit
```

`pre-commit` event only runs on staged changes.
It does this by staging any working copy changes and then unstaging afterwards.

Hooks always receive whatever has defined as it's own `args`
and then a list of staged files.

Running pre_hook

* `autoupdate` updates repos in the .cache
* `clean` clean out cache
* `install` is used to create the precommit hook
* `install-hooks` downloads all the repos for the cache
* `run [hook-id]` to run one hook
* `hook-impl`

Trying locally

```sh
python -m venv .venv
source .venv/bin/activate
pip install pre-commit
```

## Dockerize

```sh
docker build -t vonwig/pre-commit .
```

### running pre-commit hook

```sh
# docker:command=run-pre-commit
docker run -it --rm \
           --ulimit nofile=1024 \
           -v $PWD:/project \
           -v /var/run/docker.sock:/var/run/docker.sock \
           --mount "type=volume,source=chatsdlc,target=/config" \
           --mount "type=volume,source=chatsdlc-cache,target=/.cache" \
           vonwig/pre-commit
```

* if we were to set `XDG_CACHE_HOME` then our chatsdlc-cache will need to use that
  (which is probably `$HOME/.cache`).  We could override this with `PRE_COMMIT_HOME`
  but what we have here is probably optimal.

`pre-commit` event only runs on staged changes.
It does this by staging any working copy changes and then unstaging afterwards.

Hooks always receive whatever has defined as it's own `args` and then a
list of staged files.

### running commit-msg hook

When this hook runs, the filename containing the proposed commit
message is passed in.

```sh
# docker:command=run-commit-msg
cat <<EOF > commit-msg.txt
good message

body message - what did I actually change?
EOF
docker run -it --rm \
           --ulimit nofile=1024 \
           -v $PWD:/project \
           -v /var/run/docker.sock:/var/run/docker.sock \
           --mount "type=volume,source=chatsdlc,target=/config" \
           --mount "type=volume,source=chatsdlc-cache,target=/.cache" \
           --entrypoint /app/result/bin/commit-msg-wrapper \
           vonwig/pre-commit commit-msg.txt
rm commit-msg.txt
```

### other tasks

* `autoupdate` updates repos in the .cache
* `clean` clean out cache
* `install` is used to create the precommit hook
* `install-hooks` downloads all the repos for the cache
* `run [hook-id]` to run one hook
* `hook-impl`

## Setting up an initial pre-commit config

```sh
# docker:command=update-config
docker container create --name aasdflkjasdf -v chatsdlc:/config alpine
cat <<EOF > pre-commit-config.yaml
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v2.3.0
    hooks:
    -   id: check-yaml
    -   id: trailing-whitespace
    -   id: check-merge-conflict
-   repo: https://github.com/jorisroovers/gitlint
    rev: main
    hooks:
    -   id: gitlint
-   repo: local
    hooks:
    -   id: docker-policy
        name: Docker Policy
        language: docker_image
        entry: vonwig/docker-policy
    -   id: eslint
        name: eslint in Docker
        language: docker_image
        entry: cytopia/eslint:latest
        files: \.[jt]sx?$
        types: [file]
    -   id: golangcli-lint
        name: golang cli
        language: docker_image
        entry: golangci/golangci-lint
        files: \.go$
    -   id: markdownlint
        name: markdown linter
        language: docker_image
        entry: markdownlint/markdownlint
        files: \.md$
    -   id: actionlint
        name: actionlint
        language: docker_image
        entry: rhysd/actionlint
        types: [yaml]
        files: ^.github/workflows/
EOF
docker cp - aasdflkjasdf:/config < <(tar -c -f - pre-commit-config.yaml)
docker rm aasdflkjasdf
rm pre-commit-config.yaml
```

## Local versus GitHub definition

For Docker images, local definitions are probably good enough.  But we _can_
put docker image definitions in GitHub too.  Local definitions were supposed
to be for project specific linters but they're kind of perfect for docker packaged
linters too.

```yaml
-   repo: https://github.com/slimslenderslacks/pre-commit-hooks
    rev: main
    hooks:
    -   id: docker-policy
```

## Eslint

Not using this one because we should use the eslint that's defined by the project.

```yaml
-   repo: https://github.com/pre-commit/mirrors-eslint
    rev: main
    hooks:
    -   id: eslint
        files: \.[jt]sx?$  # *.js, *.jsx, *.ts and *.tsx
        types: [file]
```

## Plan

* [ ] create the `.git/hooks/pre-commit` script with the correct docker command
   * what about core.hooksPath
      * $GIT_DIR/hooks is the normal location unless `core.hooksPath`
   * backup existing script to pre-commit.legacy
   * use hook template to generate pre-commit
   * `description`: run pre commit checks in this repo
* [ ] what is the hook we use to manage the entries
      in the `pre-commit-config.yaml` file?
   * `description`: figure out which hooks I should install, based on the project
* [ ] have some linters ready to go
   * do the ones from below
* [ ] show that a repo with a Dockerfile and README.md is
      sufficient to document your linter and have
      automatically part of githooks and lsps
* [ ] remember the job is to represent this as an agent so I should be able to chat
      with this to set it up
* [ ] the global `init.templateDir` can point at a
      directory with a `hooks/pre-commit` that will automatically
      configure freshly cloned repos.
* [ ] a single linter should be able to configure itself
      into the pre-commit-config.yaml` file
* [ ] the linter should also be able to bind itself to the LSP

## Linters

* parse the content [here](https://pre-commit.com/hooks.html) - html
* tflint
* actionlint for GHA
* markdownlint
* pylint
* yamllint
* hadolint
* golangcli-lint
* vale doc lint
* gitlint
* ansible lint

## Fixes

How much can we auto-fix?

## Moby Devcontainer

* gopls
* group:user is docker:docker
* seed a .bashrc and a /usr/local/completion/bash/docker
* add a `safe.directory` to the git config
* apt-get apparmor, bash-completion, bzip2, inetutils-ping,
          iproute2, iptables, jq, libcap2-bin, libnet1, libnl-3-200
          libprotobuf-c1, libyajl2, net-tools, patch, pigz, sudo,
          systemd-journal-remote, thin-provisioning-tools,
          uidmap, vim, vim-common, xfsprogs, xz-utils, zip, zstd
   * some `update-alternatives` for iptables-legacy, ip6tables-legacy, arptables-legacy
   * add gcc, yamllint, pkg-config, dpkg-dev
* copy in `/usr/local/cli` and `/usr/local/cli-integration` from the build
           -v $PWD:/project \
           -v /var/run/docker.sock:/var/run/docker.sock \
           --mount "type=volume,source=chatsdlc,target=/config" \
           --mount "type=volume,source=chatsdlc-cache,target=/.cache" \
           vonwig/pre-commit
