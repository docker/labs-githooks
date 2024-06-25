#!/bin/bash

docker run --rm \
	   -it \
	   -v /var/run/docker.sock:/var/run/docker.sock \
	   --mount type=volume,source=docker-prompts,target=/prompts \
	   --mount type=bind,source=$HOME/.openai-api-key,target=/root/.openai-api-key \
	   --mount "type=bind,source=$2,target=/project" \
	   vonwig/prompts:latest \
				run \
				"$2" \
				$USER \
				"$(uname -o)" \
				"$1"

