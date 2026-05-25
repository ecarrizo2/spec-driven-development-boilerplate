# Architectural Schemas

This directory contains system-level documentation — how services connect, data flows between them, and the overall topology of the system managed by this hub.

## Contents

| File | Purpose |
|------|---------|
| `system-overview.md` | Mermaid diagram showing all services and their connections |
| `data-flow.md` | Event flows, queue topologies, data pipelines |
| Additional files | As needed for specific subsystems or complex flows |

## When to Update

- When a new repo is added to the hub
- When service-to-service communication patterns change
- When new queues, events, or shared infrastructure is introduced
- During epic planning (to verify understanding of the system)

## Relationship to Other Docs

- `config/repos.yaml` → topology section defines runtime dependencies (machine-readable)
- This directory → human/agent-readable diagrams and explanations of the same topology
- `contracts/` → specific interface details (schemas, payloads)
- This directory → big-picture how everything fits together
