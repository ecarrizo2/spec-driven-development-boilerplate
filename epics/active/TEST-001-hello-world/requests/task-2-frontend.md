---
target_repo: sdd-test-frontend
depends_on: [1]
---

# Task 2: Frontend Hello Component

## Objective
Create a React component that fetches the greeting message from the API and displays it.

## Requirements

### Functional
- Component name: `HelloWorld`
- Fetches from `GET /api/hello` on mount
- Displays the message from the API response
- Shows loading state while fetching
- Shows error state if fetch fails

### Technical
- Use React hooks (useState, useEffect)
- Use fetch API or axios for HTTP requests
- Display message in a clear, readable format
- Handle loading and error states gracefully

## Acceptance Criteria
- [ ] Component fetches from `/api/hello` on mount
- [ ] Message from API is displayed to user
- [ ] Loading indicator shows while fetching
- [ ] Error message shows if fetch fails
- [ ] Tests added and passing
- [ ] Component can be imported and used in the app

## Dependencies
- Task 1 (API endpoint) must be completed and deployed first
- API must be accessible from frontend (CORS configured)

## Testing Notes
- Add unit test with mocked API response
- Add integration test with actual API call (if test API available)
- Verify loading and error states render correctly
