package blueprint

import (
    "path"
    "tool/file"
    "encoding/yaml"
)

buildDirectory: string @tag(out)

command: build: {
    outFiles: [for _, f in files {
        file.Create & {
            filename: path.Join([buildDirectory, f.name])
            contents: yaml.Marshal(f.contents)
        }
    }]
}