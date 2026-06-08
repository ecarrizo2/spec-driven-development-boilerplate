---
target_repo: sdd-test-api
---

# Task 1: API Hello Endpoint

## Objective
Create a simple GET endpoint at `/api/hello` that returns a JSON greeting message.

## Requirements

### Functional
- Endpoint: `GET /api/hello`
- Response: `{ "message": "Hello from API" }`
- Status code: 200
- Content-Type: application/json

### Technical
- Use existing Node.js/Express setup
- Add route handler in appropriate file
- No authentication required
- No database interaction

## Acceptance Criteria
- [ ] GET /api/hello returns status 200
- [ ] Response body is valid JSON
- [ ] Response contains `message` field with value "Hello from API"
- [ ] Tests added and passing
- [ ] API can be called from frontend (CORS configured if needed)

## Testing Notes
- Add unit test for the route handler
- Add integration test for the endpoint
- Verify response format matches exactly
