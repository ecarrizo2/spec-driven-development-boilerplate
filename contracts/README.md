# Interface Contracts

This directory holds cross-service interface specifications — API schemas, event definitions, and shared protocols that multiple repos must conform to.

## Ownership Model

**The producing service owns the contract.**

- If the producing repo has its own `sdd/`, the contract source of truth lives there
- This directory holds the **hub's reference copy** for planning and cross-repo visibility
- If the producing repo does NOT have `sdd/`, this directory IS the source of truth

## Structure

```
contracts/
├── <producing-repo>/
│   ├── rest-api.yaml          ← OpenAPI spec
│   ├── graphql-schema.graphql ← GraphQL schema
│   ├── events.yaml            ← Event/queue message schemas
│   └── README.md              ← What's here, how to update
└── ...
```

## How to Update

1. The producing team updates the contract in their repo (if they have `sdd/`)
2. The hub reference is updated to match (via `bin/dev repo:sync` or manually)
3. Consuming repos validate against the contract in their own CI

## When Repos Don't Have SDD

If the producing repo has no `sdd/` directory:
- Write and maintain the contract directly in this hub's `contracts/<repo>/` directory
- When that repo eventually adopts SDD (`bin/dev repo:migrate`), move the contract to the producer
