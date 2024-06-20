## Running the git_hooks prompts

```sh
bb uberjar prompts.jar -m prompts
bb -m prompts run /Users/slim/docker/lsp jimclark106 darwin git_hooks_pre
```

```sh
bb uberjar prompts.jar -m prompts
bb -m prompts run /Users/slim/docker/lsp jimclark106 darwin git_hooks_pre1
```

```sh
#docker:command=git_hooks_pre
docker run --rm \
           -it \
           -v /var/run/docker.sock:/var/run/docker.sock \
           --env "OPENAI_API_KEY=$(cat /Users/slim/.openai-api-key)" \
           vonwig/prompts:local \
                                run \
                                /Users/slim/docker/lsp \
                                jimclark106 \
                                darwin \
                                github:docker/labs-githooks?path=prompts/git_hooks_pre
```

```sh
#docker:command=run-githooks
bb -m prompts run /Users/slim/docker/lsp jimclark106 darwin git_hooks
```

```sh
#docker:command=run-githooks-single-step
bb -m prompts run /Users/slim/docker/lsp jimclark106 darwin git_hooks_single_step
```

