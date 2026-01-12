# gastown-dev

A VS Code dev container environment for [Gastown](https://github.com/steveyegge/gastown) - an agent orchestration framework for managing Claude-powered AI agents across multiple repositories.

## Overview

This repository provides a ready-to-use development environment that:

- Uses a custom dev container image with all dependencies pre-installed
- Bootstraps Gastown (gt CLI) for orchestrating Claude agents
- Includes Beads (bd CLI) for AI-native issue tracking
- Pre-configures Claude Code CLI with multiple agent profiles (opus, sonnet, haiku)
- Sets up security tooling including safe-chain npm protection

## Prerequisites

- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Docker](https://www.docker.com/get-started)
- SSH key configured with GitHub (for git operations and rig sync)

## Getting Started

1. Clone this repository:
   ```bash
   git clone https://github.com/anthony-spruyt/gastown-dev.git
   cd gastown-dev
   ```

2. Open in VS Code and reopen in container:
   - Open the folder in VS Code
   - Press `F1` and select "Dev Containers: Reopen in Container"
   - Wait for the container to build (the post-create script automatically bootstraps everything)

That's it! The container automatically installs all tools and initializes Gas Town HQ in the `gt/` directory.

## What's Included

| Tool | Command | Description |
|------|---------|-------------|
| Gas Town | `gt` | Agent orchestration framework |
| Beads | `bd` | AI-native issue tracking |
| Claude Code | `claude` | Anthropic's CLI for Claude |

### VS Code Extensions
- Claude Code (official Anthropic extension)
- Prettier, YAML, Terraform, Helm
- Git Graph, Markdown Mermaid, BATS testing

## Project Structure

```
gastown-dev/
├── .devcontainer/       # Container config and bootstrap scripts
│   ├── devcontainer.json
│   ├── post-create.sh   # Runs on container creation
│   ├── bootstrap.sh     # Initializes Gastown
│   └── dashboard-start.sh
└── gt/                  # Gas Town HQ (created after bootstrap)
    ├── rig_claude_config/  # Claude configuration rig
    ├── deacon/          # Background orchestration daemon
    ├── mayor/           # Orchestration coordinator
    ├── polecats/        # Transient worker management
    └── plugins/         # Town-level plugins
```

## Usage

### Start the Dashboard
```bash
./.devcontainer/dashboard-start.sh
```
Access at http://localhost:8080

### Common Commands
```bash
# Check Gas Town status
gt status

# List available agents
gt agents

# View issues with Beads
bd list
```

## Related Repositories

- [Gastown](https://github.com/steveyegge/gastown) - The agent orchestration framework
- [Container Images](https://github.com/anthony-spruyt/container-images) - Base dev container image
- [Claude Config](https://github.com/anthony-spruyt/claude-config) - Shared Claude configuration rig
