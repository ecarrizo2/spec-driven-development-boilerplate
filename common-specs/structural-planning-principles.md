# Structural Planning Principles

> **Scope:** Applies to plan artifacts (specification.md, stage files, manifest.yaml).
> For acceptance criteria syntax, see `writing-specs.md`.

## The Problem: Plan-Phase Over-Coding

Plans are intended to be architectural blueprints — they define **what** must exist in the codebase and **where**, not **how** the implementation works internally. When plans contain complete function bodies, loops, conditionals, and business logic, they cross from architectural guidance into functional implementation.

This over-coding creates three problems:

1. **Token waste:** A plan with embedded implementation can consume 500–1000+ tokens per stage describing logic that the executing agent could read directly from the source code. Those tokens could better serve contract definitions, verification commands, or cross-module dependencies.

2. **Context bloat:** Plans with detailed implementation become long, complex documents that obscure the essential structural changes. The executing agent must parse through implementation narratives to extract what actually needs to change.

3. **Brittleness:** When a plan tightly couples to implementation details, it breaks whenever the codebase evolves. If the plan says "loop through the array using `.forEach()` and calculate the average," but the existing codebase uses `.reduce()`, the plan and reality diverge. The executing agent must choose: follow the stale plan (introducing inconsistency) or ignore it (defeating its purpose).

**The solution:** Structural planning. Plans specify contracts (interfaces, types, signatures, schemas) and structural mutations (what exists, where) without prescribing internal logic. The executing agent reads the actual source code to understand patterns and applies them.

---

## The Three Pillars

### 1. Signature-Driven Planning (Contract Boundaries)

**Definition:** Plans specify interfaces, types, function signatures, and API schemas — the contracts between modules — without prescribing internal implementation logic.

**Include:**
- Function signatures with parameter types and return types
- TypeScript interfaces and type aliases
- GraphQL schema definitions
- Prisma schema model fields (structure, not constraints logic)
- API request/response shapes
- Database schema additions (columns, indexes)

**Omit:**
- Complete function bodies with internal logic
- Loops, conditionals, variable assignments
- Business logic calculations
- Data transformation algorithms
- Error handling implementation details (specify the contract: "returns Either<Error, T>", not how to build Either)

**Rationale:** Treating the plan as an architectural linker guarantees type safety at module boundaries without wasting tokens on implementation details. The executing agent can read the actual source code to understand how existing patterns work and apply them. The plan ensures new code integrates correctly (types match, contracts align) without over-specifying.

**Examples:**

✅ **Passing (Structural):**
```markdown
Inject method into class `VendorResolver`:
```typescript
async getVendorReviews(vendorId: string): Promise<Review[]>
```
This method delegates to `ReviewService.fetchByVendor()` and returns the raw array. Verification: GraphQL query `{ vendor(id: "test") { reviews { id rating } } }` returns array.
```

❌ **Failing (Over-Coded):**
```markdown
Add a new method to VendorResolver:
```typescript
async getVendorReviews(vendorId: string): Promise<Review[]> {
  const reviews = await this.reviewService.fetchByVendor(vendorId);
  if (!reviews || reviews.length === 0) {
    return [];
  }
  return reviews.filter(r => r.rating >= 3).sort((a, b) => b.createdAt - a.createdAt);
}
```
```

---

### 2. AST-Targeted Instructions (Structural Mutations)

**Definition:** Plan instructions describe changes as Abstract Syntax Tree mutations using a controlled verb vocabulary (Inject, Wrap, Delete, Rename, Append, Extract) that specifies **what** to change and **where**, not **how** to implement.

**Include:**
- AST verbs targeting specific code locations ("Inject method into class X", "Wrap function Y with error boundary")
- Structural descriptions of code placement ("after the `updatedAt` field", "before the exports array")
- Mutation targets (class names, function names, module paths, AST node types)
- Verification conditions tied to the structural change ("method exists in class", "import statement added")

**Omit:**
- Procedural narratives ("First do X, then do Y, finally do Z")
- Implementation details ("loop through the array", "check if the value is null")
- Algorithm descriptions ("calculate the average by summing and dividing")
- Internal logic flow ("if X, then Y, otherwise Z")

**Rationale:** AST-targeted mutations are location-specific and verification-focused. They tell the executing agent exactly what structural change to make without prescribing the implementation approach. This reduces brittleness (the plan doesn't break if internal logic changes) and token waste (no need to describe what the code does, only what exists and where).

**AST Verb Vocabulary:**
- **Inject:** Add new code into an existing structure (class, module, array)
- **Wrap:** Surround existing code with a new construct (try/catch, error boundary, async wrapper)
- **Delete:** Remove code (method, import, line)
- **Rename:** Change an identifier (variable, class, function, file)
- **Append:** Add to the end of a list/array/block
- **Extract:** Factor out code into a separate unit (function, module, component)

**Examples:**

✅ **Passing (Structural):**
```markdown
Inject fields into Prisma model `Place` immediately after `updatedAt`:
```prisma
externalIdValidatedAt   DateTime? @map("external_id_validated_at") @db.Timestamptz(3)
externalIdInvalidatedAt DateTime? @map("external_id_invalidated_at") @db.Timestamptz(3)
needsFullRefresh        Boolean   @default(false) @map("needs_full_refresh")
```
Verification: `pnpm prisma format` succeeds without errors.
```

❌ **Failing (Procedural):**
```markdown
Open prisma/schema.prisma. Scroll down to the Place model. Find the updatedAt field. Add three new fields below it. Make sure the formatting is correct. Run prisma format. Check that it compiles.
```

---

### 3. Strict Format Constraints (Syntactic Guardrails)

**Definition:** Plans enforce syntactic constraints on code blocks, narrative length, and structure to prevent implementation details from creeping in.

**Include:**
- Pure type definitions (TypeScript interfaces, Prisma models, GraphQL schemas)
- Signatures without bodies
- Tabular blueprints for multi-file dependencies (table format showing file → contract → verification)
- Verification commands (shell commands, GraphQL queries, curl invocations)
- Commit message templates (not full bodies)

**Omit:**
- Multi-line code blocks with implementation logic
- Complete code file listings ("The entire file should look like...")
- Narrative explanations of what the code does internally
- Step-by-step tutorials
- Complete commit message bodies with Co-authored-by lines (use templates instead)

**Rationale:** Format constraints act as syntactic guardrails. If you find yourself writing a 30-line code block with loops and conditions, the constraint forces you to stop and ask: "Is this a contract or implementation?" Contract → keep it. Implementation → describe structurally.

**Examples:**

✅ **Passing (Type Definition):**
```markdown
Define GraphQL type in `schema.graphql`:
```graphql
type VendorReview {
  id: ID!
  vendorId: String!
  text: String!
  rating: Float!
  createdAt: DateTime!
}
```
```

❌ **Failing (Implementation Block):**
```markdown
Update the resolver:
```typescript
const resolvers = {
  Query: {
    vendorReviews: async (_, { vendorId }, { dataSources }) => {
      const reviews = await dataSources.reviewsAPI.getReviewsByVendor(vendorId);
      if (!reviews) {
        throw new Error('Vendor not found');
      }
      return reviews.map(r => ({
        id: r.id,
        vendorId: r.vendor_id,
        text: r.review_text,
        rating: r.rating,
        createdAt: new Date(r.created_at)
      }));
    }
  }
};
```
```

---

## Reference: SDD Failure Modes

The structural planning principles exist to prevent plan-phase over-coding, which is a specific manifestation of the three SDD failure modes documented in `writing-specs.md`:

| Failure Mode | Manifestation in Plans | Pillar That Prevents It |
|---|---|---|
| **Intent drift** | Plan prescribes implementation approach that doesn't match the request's actual intent | Signature-Driven Planning (focus on contracts keeps intent at the boundary level) |
| **Context decay** | Plan includes implementation details that become stale when codebase changes | AST-Targeted Instructions (structural mutations don't depend on internal logic) |
| **Unverifiable output** | Plan narratives like "make sure it works correctly" with no concrete verification | Strict Format Constraints (verification commands over narrative validation) |

---

## Guidelines for Agents

When writing a plan:

1. **Signature test:** Can you see complete function bodies (with logic inside `{ }`)? If yes, extract the signature and describe the change structurally.

2. **Code block test:** Does any code block exceed 10 lines (excluding pure type definitions)? If yes, ask: is this a contract or implementation? Keep contracts; describe implementation structurally.

3. **Verification test:** Does each step include a concrete verification command or condition? If no, add it.

4. **AST verb test:** Do step descriptions use structural verbs (Inject, Wrap, Delete, etc.) or implementation details ("loop through", "calculate", "set variable")? Use structural verbs.

5. **Token estimate:** Would the executing agent need to read 1000+ tokens to understand a single stage? If yes, focus on contracts and omit implementation details.

When executing a plan:

1. **Read the contracts:** Internalize the signatures, types, and boundaries specified in the plan.

2. **Read the source code:** Understand how the existing codebase implements similar patterns.

3. **Apply the pattern:** Implement the new contract following the established pattern.

4. **Verify:** Run the verification command specified in the plan to confirm the structural change succeeded.
