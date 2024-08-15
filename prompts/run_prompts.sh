#!/bin/bash

docker run --rm \
	   -it \
	   -v /var/run/docker.sock:/var/run/docker.sock \
	   --mount type=volume,source=docker-prompts,target=/prompts \
	   --mount type=bind,source=$HOME/.openai-api-key,target=/root/.openai-api-key \
	   vonwig/prompts:latest \
				run \
				--host-dir "$2" \
				--user $USER \
				--platform "$(uname -o)" \
				--prompts "$1"

