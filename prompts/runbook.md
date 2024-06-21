# Background

## Prompts Only

Run local prompts - does not require a github push.

```sh
docker run --rm \
           -it \
           -v /var/run/docker.sock:/var/run/docker.sock \
           --mount type=volume,source=docker-prompts,target=/prompts \
           --mount type=bind,source=/Users/slim/docker/labs-githooks/prompts,target=/my-prompts \
           --workdir /my-prompts \
           --env "OPENAI_API_KEY=$(cat /Users/slim/.openai-api-key)" \
           vonwig/prompts:local \
                                /Users/slim/docker/lsp \
                                jimclark106 \
                                darwin \
                                git_hooks
```

## Running the git_hooks prompts


```sh
#docker:command=git_hooks
docker run --rm \
           -it \
           -v /var/run/docker.sock:/var/run/docker.sock \
           --mount type=volume,source=docker-prompts,target=/prompts \
           --env "OPENAI_API_KEY=$(cat /Users/slim/.openai-api-key)" \
           vonwig/prompts:local \
                                run \
                                /Users/slim/docker/lsp \
                                jimclark106 \
                                darwin \
                                "github:docker/labs-githooks?ref=main&path=prompts/git_hooks"
```

```sh
#docker:command=git_hooks_single_step
docker run --rm \
           -it \
           -v /var/run/docker.sock:/var/run/docker.sock \
           --mount type=volume,source=docker-prompts,target=/prompts \
           --env "OPENAI_API_KEY=$(cat /Users/slim/.openai-api-key)" \
           vonwig/prompts:local \
                                run \
                                /Users/slim/docker/lsp \
                                jimclark106 \
                                darwin \
                                "github:docker/labs-githooks?ref=main&path=prompts/git_hooks_single_step"
```

