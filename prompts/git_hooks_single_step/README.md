---
extractors:
  - image: vonwig/go-linguist:latest
    command:
      - -json
    output-handler: linguist
tool_choice: auto
stream: false
functions:
  - name: write_files
    description: Write a set of files to my project
    parameters:
        type: object
        properties:
          files:
            type: array
            items:
              type: object
              properties:
                path:
                  type: string
                  description: the relative path to the file that should be written
                content:
                  type: string
                  description: the content that should be written to a file
    container:
        image: vonwig/function_write_file:latest
---
