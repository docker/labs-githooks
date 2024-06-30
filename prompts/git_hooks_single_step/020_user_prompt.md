How do I setup githooks?

{{# linguist }}

This project contains code from the language {{ language }} so if you have any
recommendations pertaining to {{ language }}, please include them.

{{/ linguist }}

Write three files to the project:

* Write the final yaml content to our project at the path pre-commit-config.yaml.
* Write the commit-msg content to our project at the path .git/hooks/commit-msg and make it executable.
* Write the pre-commit content to our project at the path .git/hooks/pre-commit and make it executable.
