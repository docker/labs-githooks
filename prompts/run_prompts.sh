#!/bin/bash

docker run --rm \
           -it \
           -v /var/run/docker.sock:/var/run/docker.sock \
           --mount type=volume,source=docker-prompts,target=/prompts \
           --mount type=bind,source=$HOME/.openai-api-key,target=/root/.openai-api-key \
           vonwig/prompts:local \
                                run \
                                $PWD \
                                $USER \
				"$(uname -o)" \
                                github:docker/labs-githooks?path=prompts/git_hooks_single_step

