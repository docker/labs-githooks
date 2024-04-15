## pre-commit

Trying locally

```
python -m venv .venv
source .venv/bin/activate
pip install pre-commit
```

Running pre_hook
* `autoupdate` updates repos in the .cache
* `clean` clean out cache
* `install` is used to create the precommit hook
* `install-hooks` downloads all the repos for the cache
* `run [hook-id]` to run one hook
* `hook-impl`

```sh
docker build -t vonwig/pre-commit .
```

```sh
docker run -it --rm \
           -v $PWD:/project \
           -v /var/run/docker.sock:/var/run/docker.sock \
           --mount "type=volume,source=chatsdlc,target=/config" \
           --mount "type=volume,source=chatsdlc-cache,target=/.cache" \
           vonwig/pre-commit
```

### Setting up an initial pre-commit config

```sh
docker container create --name aasdflkjasdf -v chatsdlc:/config alpine
cat <<EOF > pre-commit-config.yaml
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v2.3.0
    hooks:
    -   id: check-yaml
#    -   id: trailing-whitespace
#-   repo: https://github.com/slimslenderslacks/pre-commit-hooks
#    rev: main
#    hooks:
#    -   id: docker-policy
-   repo: local
    hooks:
    -   id: docker-policy
        name: Docker Policy
        language: docker_image
        entry: vonwig/docker-policy
         
EOF
docker cp - aasdflkjasdf:/config < <(tar -c -f - pre-commit-config.yaml)
docker rm aasdflkjasdf
rm pre-commit-config.yaml
```

## Plan

- [ ] create the `.git/hooks/pre-commit` script with the correct docker command
    * what about core.hooksPath
        * $GIT_DIR/hooks is the normal location unless `core.hooksPath`
    * backup existing script to pre-commit.legacy 
    * use hook template to generate pre-commit
- [ ] what is the hook we use to manage the entries in the `pre-commit-config.yaml` file?
- [ ] a single linter should be able to configure itself 
      into the pre-commit-config.yaml` file
- [ ] the linter should also be able to bind itself to the LSP
- [ ] have some linters ready to go
- [ ] show that a repo with a Dockerfile and README.md is 
      sufficient to document your linter and have
      automatically part of githooks and lsps
- [ ] remember the job is to represent this as an agent so I should be able to chat
      with this to set it up

### Linters

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

### Fixes

How much can we auto-fix?
