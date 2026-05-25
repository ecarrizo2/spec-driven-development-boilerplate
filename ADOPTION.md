# Adding a Repo to This Hub

> **Audience:** Developer adding a new repository to an existing multirepo hub.
> **Time:** ~5 minutes mechanical setup + one agent conversation for bootstrapping context.

---

## When to Add a Repo

Add a repo to the hub when:
- It participates in cross-repo features (epics that span services)
- You want centralized planning for work affecting this service
- You need agent context about this service for cross-repo task planning

## Steps

### 1. Register the Submodule

```bash
bin/dev repo:add <repo-name> <git-url>
```

This command:
- Adds the git submodule under `repos/<repo-name>/`
- Creates `fallback-sdd/<repo-name>/` if the repo lacks its own `sdd/`

### 2. Update `config/repos.yaml`

Add the full entry for the new repo. At minimum:

```yaml
repositories:
  new-repo:
    display_name: "New Repo"
    description: "What it does"
    git_url: "git@github.com:org/new-repo.git"
    submodule_path: "repos/new-repo"

    branches:
      main: "main"
      production: null
      staging: null

    deployment:
      system: helm              # helm | serverless | umd | ecs | static | manual
      pipeline: gha             # gha | jenkins | circleci | gitlab-ci | manual
      pipeline_file: ".github/workflows/deploy.yml"
      environments: []

    tech_stack:
      language: typescript
      framework: nestjs
      package_manager: pnpm

    sdd:
      has_own_sdd: false        # true if repo has its own sdd/ directory
      agent_specs_path: null
      architecture_docs_path: null
```

### 3. Update Topology (if needed)

If this repo has runtime dependencies on or from other repos, add it to the `topology` section:

```yaml
topology:
  dependencies:
    new-repo:
      depends_on: [infra-repo]
      interface: "infrastructure"
    frontend:
      depends_on: [new-repo, other-api]
      interface: "REST"
```

### 4. Bootstrap Agent Context

If the repo does NOT have its own `sdd/`:

1. Open an agent conversation
2. Point the agent at `repos/<repo-name>/` source code
3. Have it generate specs in `fallback-sdd/<repo-name>/agent-development/agent-specs/`:
   - `application-overview.md`
   - `architecture-breakdown.md`
   - `agent-instructions.md` (coding standards)
   - `git-workflow.md`
   - `agent-workflow.md`
4. Create `fallback-sdd/<repo-name>/config/commands.yaml` with the repo's build/test commands

If the repo HAS its own `sdd/`, skip this — the agent will read from the repo directly.

### 5. Add Documentation

Create `documentation/<repo-name>/`:
- `overview.md` — What the service does, domain concepts
- `architecture.md` — How it's built, patterns, modules (optional if agent-specs exist)

### 6. Add Contracts (if applicable)

If this repo exposes APIs or events consumed by other repos:
- Create `contracts/<repo-name>/`
- Add OpenAPI specs, event schemas, or interface documentation

### 7. Update System Topology Diagram

Edit `architectural-schemas/system-overview.md` to include the new service in the Mermaid diagram.

### 8. Commit

```bash
git add .
git commit -m "chore: add <repo-name> to hub"
```

---

## Migrating a Repo to Have Its Own SDD

When a repo's team decides to adopt SDD internally:

```bash
bin/dev repo:migrate <repo-name>
```

This creates a branch in the child repo with the full `sdd/` structure and prepares a PR. After the PR is merged:
1. Update `config/repos.yaml`: set `has_own_sdd: true`
2. The `fallback-sdd/<repo-name>/` directory is automatically removed
3. Future work uses the repo's own `sdd/` directly

---

## Removing a Repo

If a repo no longer participates in cross-repo work:

```bash
bin/dev repo:remove <repo-name>
```

Then manually:
1. Remove its entry from `config/repos.yaml`
2. Remove `documentation/<repo-name>/` and `contracts/<repo-name>/` if present
3. Remove from `topology.dependencies`
4. Update `architectural-schemas/system-overview.md`
