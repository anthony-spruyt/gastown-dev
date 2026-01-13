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

| Tool        | Command  | Description                   |
| ----------- | -------- | ----------------------------- |
| Gas Town    | `gt`     | Agent orchestration framework |
| Beads       | `bd`     | AI-native issue tracking      |
| Claude Code | `claude` | Anthropic's CLI for Claude    |

### VS Code Extensions

- Claude Code (official Anthropic extension)
- Prettier, YAML, Terraform, Helm
- Git Graph, Markdown Mermaid, BATS testing

## Project Structure

```
gastown-dev/
├── .devcontainer/       # Container configuration
│   └── devcontainer.json
├── .taskfiles/          # Task definitions
│   └── gt/tasks.yaml
├── scripts/             # Automation scripts
│   ├── bootstrap.sh     # Initializes Gas Town (supports restore from GitHub)
│   ├── post-create.sh   # Runs on container creation
│   ├── sync-crew.sh     # Syncs crew workspaces with remote
│   ├── update.sh        # Updates gt and bd tooling
│   └── dashboard-start.sh
├── gt.config.yaml       # Gas Town configuration (rigs, agents, crew)
├── Taskfile.yml         # Task runner configuration
└── gt/                  # Gas Town HQ (created after bootstrap)
    ├── <rig>/           # Project rigs (e.g., container_images)
    │   └── crew/        # Your working directories
    ├── deacon/          # Background orchestration daemon
    ├── mayor/           # Orchestration coordinator
    └── settings/        # Town-level settings
```

## Configuration

Edit `gt.config.yaml` to customize your Gas Town setup:

```yaml
rigs:
  - name: my_project
    repo: https://github.com/user/repo.git
agents:
  - name: claude
    command: "claude --model opus --dangerously-skip-permissions"
defaultAgent: claude
crew:
  - name: yourname
    rigs:
      - my_project
hqRemote: user/gastown-hq # Optional: GitHub repo for HQ backup/restore
```

## Usage

### Task Commands

```bash
# Bootstrap Gas Town (or restore from existing GitHub HQ)
task gt:bootstrap

# Sync all crew workspaces with remote
task gt:sync-crew

# Update gt and bd tooling to latest
task gt:update

# Start the dashboard
task gt:dash
```

### Start the Dashboard

```bash
task gt:dash
```

Access at http://localhost:8080

### Common Commands

```bash
# Check Gas Town status
gt status

# List rigs
gt rig list

# View issues with Beads
bd list

# Check ready work
bd ready
```

## Related Repositories

- [Gastown](https://github.com/steveyegge/gastown) - The agent orchestration framework
- [Container Images](https://github.com/anthony-spruyt/container-images) - Base dev container image
- [Claude Config](https://github.com/anthony-spruyt/claude-config) - Shared Claude configuration rig
