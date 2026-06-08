# Request: Hello Component Implementation

**Task ID:** MVP-001-2  
**Target Repo:** sdd-test-frontend  
**Status:** Draft  
**Depends On:** MVP-001-1 (API must be ready)

## Requirement

Implement a React component that calls the API `/hello` endpoint and displays the message.

## Specification

### Component: HelloWorld

```typescript
export function HelloWorld() {
  const [message, setMessage] = useState<string>("");
  
  useEffect(() => {
    fetch("/api/hello")
      .then(r => r.json())
      .then(d => setMessage(d.message));
  }, []);

  return <div>{message}</div>;
}
```

## Acceptance Criteria

- [ ] Component fetches from `/api/hello`
- [ ] Message displays on screen
- [ ] Component handles loading state
- [ ] Code passes linting
- [ ] Tests pass
- [ ] PR passes review

## File Changes

**Path:** `src/components/HelloWorld.tsx`

Create new file with HelloWorld component.

## Testing

```bash
npm test
# All tests pass
```

---

**Priority:** MVP  
**Complexity:** Low  
**Effort:** 30 minutes  
**Blocked By:** Task 1 (API endpoint must exist)
