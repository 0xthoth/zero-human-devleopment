# @myorg/shared

Shared utilities, types, and constants for the monorepo.

## Usage

### In Frontend (apps/web)

```typescript
import { formatDate, ApiResponse, isValidEmail } from '@myorg/shared';

// Use shared function
const today = formatDate(new Date());

// Use shared type
const response: ApiResponse<User> = {
  success: true,
  data: user
};

// Use shared validation
if (isValidEmail(email)) {
  // ...
}
```

### In Backend (apps/api)

```typescript
import { ApiResponse, APP_NAME } from '@myorg/shared';

@Controller()
export class AppController {
  @Get()
  getData(): ApiResponse<string> {
    return {
      success: true,
      data: `Welcome to ${APP_NAME}`
    };
  }
}
```

## Adding to Your Apps

### Frontend (apps/web)

Add to `apps/web/package.json`:
```json
{
  "dependencies": {
    "@myorg/shared": "workspace:*"
  }
}
```

### Backend (apps/api)

Add to `apps/api/package.json`:
```json
{
  "dependencies": {
    "@myorg/shared": "workspace:*"
  }
}
```

Then run:
```bash
pnpm install
```

## Development

```bash
# Watch mode
pnpm --filter @myorg/shared dev

# Build
pnpm --filter @myorg/shared build

# Lint
pnpm --filter @myorg/shared lint
```

## What to Put Here

- Shared TypeScript types/interfaces
- Common utility functions
- Validation helpers
- Constants (API URLs, app config)
- Shared components (if using component library)
- API client utilities
