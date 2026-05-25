# Copilot Instructions for <Repo Name>

> **Replace** the placeholders below with your actual repository details.

## Repository Overview

<What this service does, key domain concepts. 2-3 sentences.>

## Tech Stack

- Language: TypeScript
- Framework: NestJS 10
- Database: PostgreSQL + Prisma 5
- Package manager: pnpm

## Build & Verify Commands

- Install: `pnpm install`
- Build: `pnpm build`
- Test: `pnpm test`
- Lint: `pnpm lint`
- Typecheck: `pnpm tsc --noEmit`
- Full verify: `pnpm lint && pnpm tsc --noEmit && pnpm test`

## Architecture

<Key modules, directory structure, patterns used. Keep concise.>

## SDD Workflow Rules

This repo follows Spec-Driven Development. Key rules:

- Plans live in `sdd/plans/<task-name>/`
- When creating a Plan PR: only write documentation/plan files, NO code
- When creating a Code PR: read the approved plan from main, implement exactly what it specifies
- Commit convention: `<type>(<scope>): <JIRA-ID> <description>`
- Always run verification before marking ready for review
- Do not modify files outside the plan's declared blast radius

## Coding Standards

<Key rules specific to this repo: no `any`, path aliases, testing patterns, etc.>
