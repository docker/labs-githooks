# Background

* requires a docker socket to run extractors and functions
* requires the docker-prompts volume just in case we're using github refs and they need to be cached
* use a bind mount to a local prompts folder if testing unpushed prompts
  * if using this bind mount, the workdir needs to be set to this mount for `pwd`
* the OPENAI_API_KEY is required when running in the container
* if `--identity-token TOKEN` is supplied, extractor and function containers will run

## Prompts Only

Run local prompts - does not require a github push.

```sh
docker run --rm \
           -it \
           -v /var/run/docker.sock:/var/run/docker.sock \
           --mount type=volume,source=docker-prompts,target=/prompts \
           --mount type=bind,source=/Users/slim/docker/labs-githooks/prompts,target=/my-prompts \
           --workdir /my-prompts \
           vonwig/prompts:local \
                                /Users/slim/docker/lsp \
                                $USER \
                                "$(uname -o)" \
                                git_hooks_single_step
```

## Running the git_hooks prompts through OPENAI

```sh
docker run --rm \
           -it \
           -v /var/run/docker.sock:/var/run/docker.sock \
           --mount type=volume,source=docker-prompts,target=/prompts \
           --mount type=bind,source=$HOME/.openai-api-key,target=/root/.openai-api-key \
           vonwig/prompts:local \
                                run \
                                /Users/slim/docker/lsp \
                                $USER \
                                "$(uname -o)" \
                                "github:docker/labs-githooks?ref=main&path=prompts/git_hooks"
```

```sh
docker run --rm \
           -it \
           -v /var/run/docker.sock:/var/run/docker.sock \
           --mount type=volume,source=docker-prompts,target=/prompts \
           --mount type=bind,source=$HOME/.openai-api-key,target=/root/.openai-api-key \
           vonwig/prompts:local \
                                run \
                                /Users/slim/docker/lsp \
                                $USER \
                                $(uname -o) \
                                "github:docker/labs-githooks?ref=slim/prompts/input&path=prompts/git_hooks_single_step"
```

