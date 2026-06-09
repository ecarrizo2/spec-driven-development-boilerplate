# Structural Planning Examples — Before & After

> **Purpose:** Teach agents to write structural plans by showing real transformations
> from over-coded (legacy) to structural (v2.0) stage instructions.
>

---

## Before: Over-Coded Stage Instructions (Legacy Format)

### Step 1.1: Update Prisma Schema

**File:** `prisma/schema.prisma`
**Action:** modify

Add the following three fields to the `Place` model, immediately after the `updatedAt` field:

```prisma
  externalIdValidatedAt   DateTime? @map("external_id_validated_at") @db.Timestamptz(3)
  externalIdInvalidatedAt DateTime? @map("external_id_invalidated_at") @db.Timestamptz(3)
  needsFullRefresh        Boolean   @default(false) @map("needs_full_refresh")
```

The complete `Place` model should look like:

```prisma
model Place {
  id                      String                  @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  externalId              String                  @map("external_id") @db.VarChar(256)
  name                    String?
  businessStatus          BusinessStatus?         @map("business_status")
  latitude                Float?
  longitude               Float?
  rating                  Float?
  totalReviewCount        Int?                    @map("total_review_count")
  lastFetchedAt           DateTime                @default(now()) @map("last_fetched_at")
  createdAt               DateTime                @default(now()) @map("created_at")
  updatedAt               DateTime                @updatedAt @map("updated_at")
  externalIdValidatedAt   DateTime?               @map("external_id_validated_at") @db.Timestamptz(3)
  externalIdInvalidatedAt DateTime?               @map("external_id_invalidated_at") @db.Timestamptz(3)
  needsFullRefresh        Boolean                 @default(false) @map("needs_full_refresh")
  reviews                 Review[]
  placeSearch             PlaceSearch[]
  vendorToPlaceRelation   VendorToPlaceRelation[]

  @@map("places")
}
```

**Commit 1:** After this step, commit the schema change:
```
feat(prisma): PROJ-XXXXX add Place ID validation columns to Place model

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

---

### Step 1.3: Add Partial Index to Migration SQL

**File:** `prisma/migrations/<timestamp>_add_place_id_validation_columns/migration.sql`
**Action:** modify

Append the following at the end of the generated migration SQL:

```sql
-- CreateIndex (manual: partial index for stale-feed query)
CREATE INDEX "idx_places_stale_feed" ON "places" ("external_id_validated_at")
WHERE "external_id_invalidated_at" IS NULL;
```

**Why manual?** Prisma does not support `WHERE` clauses in `@@index` declarations. This partial index must be added directly to the migration SQL.

**Commit 2:** After steps 1.2–1.6 pass, commit the migration:
```
feat(prisma): PROJ-XXXXX generate migration with partial index

Adds migration SQL for external_id_validated_at, external_id_invalidated_at,
and needs_full_refresh columns. Manually adds partial index
idx_places_stale_feed (WHERE external_id_invalidated_at IS NULL).

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

---

**Problems with this approach:**

- **~400 token waste:** Complete 30-line Prisma model definition when only 3 new fields are relevant
- **~150 token waste:** Full SQL code block that duplicates what `prisma migrate` auto-generates
- **~50 token waste:** Complete commit message bodies with trailers (should use templates)
- **Brittle:** If existing fields in Place model change, the plan breaks
- **Context bloat:** Executing agent must parse through irrelevant boilerplate to find what actually changes

**Total:** ~1200 tokens for this stage

---

## After: Structural Stage Instructions (v2.0 Format)

### Step 1.1: Update Prisma Schema

**Mutation:** Inject
**Target:** `Place` (model — after `updatedAt` field)
**Search keys:** `Place` — _(Prisma model definition to locate injection point)_
**Signature/Contract:**
```prisma
externalIdValidatedAt   DateTime? @map("external_id_validated_at") @db.Timestamptz(3)
externalIdInvalidatedAt DateTime? @map("external_id_invalidated_at") @db.Timestamptz(3)
needsFullRefresh        Boolean   @default(false) @map("needs_full_refresh")
```

Inject three new fields into the `Place` model immediately following the `updatedAt` field. All three use snake_case column names via `@map`. The timestamp fields are nullable; the boolean defaults to `false`. Verification: `pnpm prisma format` succeeds without errors.

**Commit:** `feat(prisma): PROJ-XXXXX add Place ID validation columns to Place model`

---

### Step 1.2: Generate Migration (create-only)

**Command:** `pnpm prisma migrate dev --create-only --name add_place_id_validation_columns`

Generate migration SQL without applying. This creates a timestamped folder under `prisma/migrations/` containing the `ALTER TABLE` statements. Verification: migration.sql file exists and contains `ADD COLUMN` statements for all three fields.

---

### Step 1.3: Add Partial Index to Migration SQL

**File:** `prisma/migrations/<timestamp>_add_place_id_validation_columns/migration.sql`
**Mutation:** Append
**Target:** End of migration file
**Signature/Contract:**
```sql
CREATE INDEX "idx_places_stale_feed" ON "places" ("external_id_validated_at")
WHERE "external_id_invalidated_at" IS NULL;
```

Append partial index SQL to the generated migration file. This index supports stale-feed queries by filtering on `external_id_validated_at` only where `external_id_invalidated_at` is null. Verification: migration file contains the `CREATE INDEX` statement with `WHERE` clause.

**Commit:** `feat(prisma): PROJ-XXXXX generate migration with partial index`

---

### Step 1.4: Apply Migration & Verify

**Commands:**
```bash
pnpm prisma migrate dev
pnpm prisma generate
pnpm run build
```

Apply migration, regenerate Prisma client, and verify build succeeds. Verification: all three commands exit with code 0.

---

**Key principle:** Describe what to change and how to verify — not how to write the code or what the entire file looks like.

**Total:** ~500 tokens for this stage

---

## Key Differences Table

| Aspect | Before (Over-Coded) | After (Structural) | Token Savings |
|---|---|---|---|
| **Prisma model** | Complete 30-line model definition with all existing fields | 3-line signature of new fields only | ~400 tokens |
| **SQL migration** | Full SQL code block with `ALTER TABLE` syntax | Structural description ("Append partial index SQL") + verification | ~150 tokens |
| **Commit messages** | Full body text with Co-authored-by trailers | Template with ticket ID only | ~50 tokens |
| **Narrative** | Implementation details ("The complete Place model should look like...") | Structural intent ("Inject three new fields immediately following...") | ~100 tokens |
| **Search keys** | None — executor must guess file + grep blindly | `**Search keys:** Place` — executor runs one grep to locate model | ~50 tokens |
| **Brittleness** | Breaks when existing Place fields change | Resilient — only references injection point and new fields | N/A |
| **Total** | ~1200 tokens | ~450 tokens | **63% reduction** |

---

## Quick Reference: AST Verbs

Use these verbs in stage step descriptions to communicate structural intent without prescribing implementation.

| Verb | When to Use | Marketplace Example |
|---|---|---|
| **Inject** | Add new code into existing structure (class, module, array) | Inject method into class `VendorResolver`: `async getReviews(vendorId: string): Promise<Review[]>` |
| **Wrap** | Surround existing code with new construct (error boundary, async wrapper) | Wrap function `fetchReviews` with error boundary returning `Either<ReviewError, Review[]>` |
| **Delete** | Remove code (method, import, field) | Delete deprecated method `legacyFetchReviews` from class `ReviewService` |
| **Rename** | Change an identifier (variable, class, function, file, column) | Rename interface `IReview` to `Review` for consistency with codebase conventions |
| **Append** | Add to the end of a list/array/block | Append route `/api/reviews/:vendorId` to `routes.ts` exports array after existing review routes |
| **Extract** | Factor out code into separate unit (function, module) | Extract validation logic from `createVendor()` into new function `validateVendorInput(data: VendorInput): Either<ValidationError, void>` |

### Guidelines for Using AST Verbs

1. **Pair with location:** Always specify the target (class name, file path, AST node)
   - ✅ "Inject method into class `VendorResolver`"
   - ❌ "Add a new method"

2. **Include signature, omit body:** Show the contract (types, parameters, return value) but not the implementation logic
   - ✅ `async getReviews(vendorId: string): Promise<Review[]>`
   - ❌ Complete function with loops, conditions, and business logic

3. **Add verification:** Every structural mutation should have a concrete verification condition
   - ✅ "Verification: `pnpm run build` exits with code 0"
   - ❌ "Make sure it works correctly"

4. **Natural variations OK:** The verbs are guidelines, not rigid syntax
   - "Inject method" ≈ "Add method to class" ≈ "Insert new method in"
   - Focus on structural clarity, not verb orthodoxy

---

## Additional Examples by Pillar

### Pillar 1: Signature-Driven Planning

**✅ Structural:**
```markdown
Define GraphQL type in `schema.graphql`:
```graphql
type StorefrontReview {
  id: ID!
  rating: Float!
  text: String!
  createdAt: DateTime!
}
```
```

**❌ Over-Coded:**
```markdown
Add a resolver that fetches reviews:
```typescript
const resolvers = {
  Query: {
    storefrontReviews: async (_, { storefrontId }, { dataSources }) => {
      const reviews = await dataSources.reviewsAPI.getReviews(storefrontId);
      return reviews.map(r => ({
        id: r.id,
        rating: parseFloat(r.rating),
        text: r.review_text,
        createdAt: new Date(r.created_at)
      }));
    }
  }
};
```
```

---

### Pillar 2: AST-Targeted Instructions

**✅ Structural:**
```markdown
Inject import statement at top of `VendorService.ts`:
```typescript
import { ReviewSnippet } from '@/types/ReviewSnippet';
```

Inject public method into class `VendorService` after `getVendorById`:
```typescript
async getReviewSnippets(vendorId: string, limit: number = 3): Promise<ReviewSnippet[]>
```

Verification: TypeScript compiler passes with no import errors.
```

**❌ Over-Coded:**
```markdown
Open VendorService.ts. At the top of the file, add an import for ReviewSnippet from the types folder. Then scroll down to the getVendorById method. After that method, add a new method called getReviewSnippets. The method should be async and take two parameters: vendorId (string) and limit (number, default 3). It should return a Promise of ReviewSnippet array. Make sure to export it properly.
```

---

### Pillar 3: Strict Format Constraints

**✅ Structural (Tabular Blueprint):**
```markdown
| File | Contract | Verification |
|---|---|---|
| `src/vendor/VendorResolver.ts` | `async getReviews(vendorId: string): Promise<Review[]>` | GraphQL query `{ vendor(id: "test") { reviews { id } } }` returns array |
| `src/types/Review.ts` | `interface Review { id: string; rating: number; text: string; }` | `pnpm run build` exits 0 |
```

**❌ Over-Coded (Complete File Listing):**
```markdown
The entire VendorResolver.ts file should now look like this:

```typescript
import { Resolver, Query, Arg } from 'type-graphql';
import { VendorService } from '../services/VendorService';
import { ReviewService } from '../services/ReviewService';
import { Vendor } from '../types/Vendor';
import { Review } from '../types/Review';

@Resolver(Vendor)
export class VendorResolver {
  constructor(
    private vendorService: VendorService,
    private reviewService: ReviewService
  ) {}

  @Query(() => Vendor)
  async vendor(@Arg('id') id: string): Promise<Vendor> {
    return this.vendorService.getVendorById(id);
  }

  @Query(() => [Review])
  async getReviews(@Arg('vendorId') vendorId: string): Promise<Review[]> {
    return this.reviewService.fetchByVendor(vendorId);
  }
}
```
```

---

### Pillar 4: Symbol-Indexed Plans

The Symbol Index in `specification.md` is a pre-computed grep map. The executing agent reads it once and primes its code map before touching any stage.

**✅ Structural (Symbol Index in specification.md):**
```markdown
## Symbol Index

| Symbol | Type | Grep pattern | Stages |
|--------|------|--------------|--------|
| `VendorResolver` | class | `class VendorResolver` | 1, 2 |
| `ReviewService` | class | `class ReviewService` | 1 |
| `fetchByVendor` | method | `\.fetchByVendor\b` | 1 |
| `Review` | interface | `interface Review` | 1 |
```

**Stage step using Search keys:**
```markdown
**Mutation:** Inject
**Target:** `VendorResolver` (class)
**Search keys:** `VendorResolver`, `ReviewService` — _(grep to locate class and its dependency)_
**Signature/Contract:** `async getReviews(vendorId: string): Promise<Review[]>`
**File hint:** `src/vendor/` _(confirm with grep)_
```

**Why this matters:** The executor runs `grep -r "class VendorResolver"` instead of reading a 200-line file top-to-bottom looking for the class declaration. Combined with the Symbol Index, the executor arrives at each step with a precise code map rather than re-reading files to locate targets.

**❌ Missing search keys (forces blind file reads):**
```markdown
**File:** `src/vendor/VendorResolver.ts`
**Mutation:** Inject
**Target:** Class VendorResolver
**Signature/Contract:** `async getReviews(vendorId: string): Promise<Review[]>`
```
The executor must open and read the file to confirm where the class is and what it imports — wasted tokens every time the plan is executed.

---

## When to Use Which Pillar

| Scenario | Primary Pillar | Secondary Support |
|---|---|---|
| Adding new API endpoint | Signature-Driven (show route signature + response type) | AST-Targeted (Inject route into routes array) |
| Refactoring class structure | AST-Targeted (Extract/Rename operations) | Signature-Driven (show new interface contracts) |
| Database schema change | Signature-Driven (show new columns/types) | Strict Format (tabular migration summary) |
| Multi-file dependency | Strict Format (tabular contract map) | Signature-Driven (show interface signatures) |
| Error handling update | Signature-Driven (show error union types) | AST-Targeted (Wrap existing logic) |

All four pillars work together — the **Symbol Index** is built from the plan's symbols and gives the executor its code map; **signature contracts** define what exists; **AST verbs** define where it goes; **format constraints** prevent implementation details from creeping in.
