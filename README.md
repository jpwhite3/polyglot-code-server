# polyglot-code-server

![Docker](https://github.com/jpwhite3/polyglot-code-server/workflows/Docker/badge.svg)

![Code Server](https://img.shields.io/badge/Powered%20By-coder%2Fcode--server-blue)

A web-based IDE, built using [Codeserver](https://github.com/coder/code-server) on top of a custom-made, multi programming language container, built for interactive development environments.

![Screen shot](https://github.com/jpwhite3/polyglot-code-server/raw/main/images/screenshot.png)

_NOTE:_ The container image is quite large, and can be very resource intensive. Please plan accordingly.

## Included Languages & Tools

| Language Ecosystem | Version  | Included Tools |
| ------------------ | -------- | -------------- |
| Node               | 20.10.0  | nvm, npm       |
| Python             | 3.11.5   | Poetry, pipenv |
| Ruby               | 3.1.2p20 | gem, rbenv     |
| Java               | 20.0.2   |                |
| Dotnet             | 6.0.122  |                |
| GO                 | 1.21.5   |                |
| Rust               | 1.74.1   |                |
| Docker             | 24.0.7   |                |

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
