In order for hooks to work, the commit-msg file must have the content shown below:

```sh
#!/usr/bin/env bash

HERE="$(cd "$(dirname "$0")/../.." && pwd)"

docker run --rm \
	-v $HERE:/project \
	-v /var/run/docker.sock:/var/run/docker.sock \
        --mount "type=volume,source=chatsdlc,target=/config" \
        --mount "type=volume,source=chatsdlc-cache,target=/.cache" \
	vonwig/pre-commit "$@"
```

The commit-msg hooks must have the following content:

```sh
#!/usr/bin/env bash

HERE="$(cd "$(dirname "$0")/../.." && pwd)"

docker run --rm \
	-v $HERE:/project \
	-v /var/run/docker.sock:/var/run/docker.sock \
        --mount "type=volume,source=chatsdlc,target=/config" \
        --mount "type=volume,source=chatsdlc-cache,target=/.cache" \
        --entrypoint /app/result/bin/commit-msg-wrapper \
	vonwig/pre-commit "$@"
```

