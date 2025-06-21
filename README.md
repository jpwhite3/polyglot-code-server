# polyglot-code-server

![Docker](https://github.com/jpwhite3/polyglot-code-server/workflows/Docker/badge.svg)

![Code Server](https://img.shields.io/badge/Powered%20By-coder%2Fcode--server-blue)

A web-based IDE, built using [Codeserver](https://github.com/coder/code-server) on top of a custom-made, multi programming language container, built for interactive development environments.

![Screen shot](https://github.com/jpwhite3/polyglot-code-server/raw/main/images/screenshot.png)

_NOTE:_ The container image is quite large, and can be very resource intensive. Please plan accordingly.

## Included Languages & Tools

| Language Ecosystem | Version | Included Tools       |
| ------------------ | ------- | -------------------- |
| Node               | 22.16.0 | nvm, npm             |
| Python             | 3.11.5  | poetry, pipenv, pipx |
| Java               | 21.0.7  |                      |
| Dotnet             | 8.0.117 |                      |
| GO                 | 1.24.4  |                      |
| Ruby               | 3.2.3   | rbenv, gem           |
| Rust               | 1.87.0  |                      |
| Docker             | 28.2.2  |                      |

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
