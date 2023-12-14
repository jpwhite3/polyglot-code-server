# polyglot-code-server

![Docker](https://github.com/jpwhite3/polyglot-code-server/workflows/Docker/badge.svg)

![Code Server](https://img.shields.io/badge/Powered%20By-coder%2Fcode--server-blue)

A web-based IDE, built using [Codeserver](https://github.com/coder/code-server) on top of a custom-made, multi programming language container, built for interactive development environments.

![Screen shot](https://github.com/jpwhite3/polyglot-code-server/raw/main/images/screenshot.png)

_NOTE:_ The container image is quite large, and can be very resource intensive. Please plan accordingly.

## Included Languages & Tools

| Language Ecosystem | Version | Included Tools                            |
| ------------------ | ------- | ----------------------------------------- |
| Node               | 18.18.0 | nvm, npm                                  |
| Python             | 3.11.5  | Poetry, pipenv                            |
| Java               | 20.0.2  |                                           |
| Dotnet             | 6.0.122 |                                           |
| GO                 | 1.21.1  |                                           |
| Rust               | 1.74.1  |                                           |
| Ruby               | 3.1.2   | gem, rbenv                                |
| code-server        | 4.19.1  | _various vscode plugins (see Dockerfile)_ |

# Installations instructions

## Prerequisites

- Unix based OS (Linux/MacOS)
- Docker Desktop, Docker Engine, or compatible container management system

## Build

```bash
make build
```

## Run

```bash
make run
```
