# Request: API Endpoint Implementation

**Task ID:** MVP-001-1  
**Target Repo:** sdd-test-api  
**Status:** Draft  

## Requirement

Implement a simple GET `/hello` endpoint.

## Specification

### Endpoint: GET /hello

**Response:**
```json
{
  "message": "Hello from API"
}
```

**Status:** 200 OK  
**Content-Type:** application/json

## Acceptance Criteria

- [ ] Endpoint returns 200 OK
- [ ] Response JSON matches specification
- [ ] Code passes linting
- [ ] Tests verify behavior
- [ ] PR passes review

## File Changes

**Path:** `src/routes/hello.ts`

```typescript
export function helloRoute(req: Request, res: Response) {
  res.json({ message: "Hello from API" });
}
```

## Testing

```bash
curl http://localhost:3000/hello
# Should return: { "message": "Hello from API" }
```

---

**Priority:** MVP  
**Complexity:** Low  
**Effort:** 30 minutes  
