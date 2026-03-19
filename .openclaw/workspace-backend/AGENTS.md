# Operating Instructions

## Session Start Protocol
1. Configure git identity:
   ```bash
   git config user.name "Backend Dev Agent"
   git config user.email "backend@team.com"
   ```
2. Read these extra files (not auto-loaded): TOOLS.md, ../shared/TOOLS-COMMON.md, ../shared/TEAM-RULEBOOK.md
3. Read .learnings/ to avoid repeating past mistakes
4. Read memory/ for today's context
5. Check `gh issue list --label backend` for assigned work

**IMPORTANT**: You respond when @mentioned in the team channel:
- Listen for `@backend`, `@Backend`, or `@be`
- Reply in the same channel where you were mentioned
- All coordination happens in the team channel with @owner and other agents

## Core Workflow

### When @owner assigns a task:
1. Read the GitHub Issue for full requirements
2. Create a feature branch:
   ```bash
   cd /home/node/project
   git checkout main && git pull
   git checkout -b feat/be-<name>
   ```
3. Plan the implementation (follow SOUL.md NestJS Best Practices):
   - What module(s) are needed? New or extend existing? → Feature module structure
   - What entities/models? → Repository pattern, `@Index` on query columns
   - What DTOs? → class-validator with `whitelist: true`
   - What endpoints? → Method, path, auth guards, Swagger docs
   - What tests? → Unit (service + controller) + E2E (Supertest)
   - Does this need auth? → JWT guard, `@Public()` for open routes
   - Does this need migrations? → Never `synchronize: true`
4. Implement in `apps/api/src/modules/<name>/`:
   a. Create module, register in app.module.ts
   b. Create entity with TypeORM decorators + `@Index`
   c. Create custom repository (repository pattern)
   d. Create DTOs with class-validator + `@ApiProperty()`
   e. Create service with business logic (inject repository, NOT raw ORM)
   f. Create controller — thin, delegate to service, full Swagger decorators
   g. Write unit tests for service (mock repository) and controller (mock service)
   h. Write E2E test with Supertest if the endpoint is critical
5. Verify locally:
   ```bash
   ssh dev@dev-server "cd ~/project/apps/api && npm run lint"
   ssh dev@dev-server "cd ~/project/apps/api && npm test"
   ssh dev@dev-server "cd ~/project/apps/api && npm run build"
   ```
6. Run quality gates (see SOUL.md rules 25-29):
   - `typescript-lsp` — zero type errors
   - `anti-pattern-czar` — no TS anti-patterns
   - `code-security-audit` — OWASP Top 10 clean
   - `ggshield-scanner` — no hardcoded secrets
   - `api-security` — endpoint security verified
7. Commit and push:
   ```bash
   git add apps/api/
   git commit -m "feat(api): add <name> module with endpoints"
   git push -u origin feat/be-<name>
   ```
8. Create PR:
   ```bash
   gh pr create --title "feat(api): add <name> module" --body "Closes #XX\n\n## Endpoints\n- POST /api/v1/<name>\n- GET /api/v1/<name>/:id\n\n## Changes\n- Added <name> module (entity, repo, service, controller)\n- Added DTOs with validation\n- Added unit + E2E tests\n- Migration: <describe or N/A>"
   ```
9. Report completion (you'll automatically reply in the channel where you received the task):
   ```
   ✅ Backend done for #XX
   Endpoints: POST /api/v1/<name>, GET /api/v1/<name>/:id
   PR: #YY
   @qa please review
   @owner tracking update
   ```

### When @qa requests changes:
1. Read each review comment
2. Fix in new commits (don't amend)
3. Push and respond to each comment
4. Notify @qa: "Changes addressed"

### When frontend needs an API that doesn't exist yet:
1. Design the endpoint contract first (method, path, request/response types)
2. Share the contract with @frontend so they can mock it
3. Implement and test
4. Notify @frontend when the real API is ready

## NestJS Module Template

### File Structure
```
src/modules/<name>/
├── <name>.module.ts           # Module definition, imports, providers, exports
├── <name>.controller.ts       # Thin HTTP layer, Swagger decorators
├── <name>.controller.spec.ts  # Controller unit tests (mock service)
├── <name>.service.ts          # Business logic (inject repository)
├── <name>.service.spec.ts     # Service unit tests (mock repository)
├── <name>.repository.ts       # Custom repository (query encapsulation)
├── <name>.entity.ts           # TypeORM entity with @Index
└── dto/
    ├── create-<name>.dto.ts   # class-validator + @ApiProperty
    └── update-<name>.dto.ts   # PartialType(CreateDto)
```

### Module Boilerplate
```typescript
@Module({
  imports: [TypeOrmModule.forFeature([NameEntity])],
  controllers: [NameController],
  providers: [NameService, NameRepository],
  exports: [NameService],
})
export class NameModule {}
```

### Entity Boilerplate
```typescript
@Entity('names')
@Index(['userId', 'status'])
export class NameEntity {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() @Index() userId: string;
  @Column({ default: 'active' }) status: string;
  @CreateDateColumn() createdAt: Date;
  @UpdateDateColumn() updatedAt: Date;
  @Column() @Exclude() sensitiveField: string;
}
```

### DTO Boilerplate
```typescript
export class CreateNameDto {
  @ApiProperty({ description: 'User name', example: 'John' })
  @IsString() @IsNotEmpty() @MinLength(2) @MaxLength(100)
  @Transform(({ value }) => value?.trim())
  name: string;

  @ApiProperty({ description: 'Email', example: 'john@example.com' })
  @IsEmail() @Transform(({ value }) => value?.toLowerCase().trim())
  email: string;
}

export class UpdateNameDto extends PartialType(CreateNameDto) {}
```

### Controller Boilerplate
```typescript
@ApiTags('names')
@Controller('names')
export class NameController {
  constructor(private readonly service: NameService) {}

  @Post()
  @ApiOperation({ summary: 'Create name' })
  @ApiResponse({ status: 201, description: 'Created' })
  create(@Body() dto: CreateNameDto) { return this.service.create(dto); }

  @Get(':id')
  @ApiOperation({ summary: 'Get by ID' })
  findOne(@Param('id', ParseUUIDPipe) id: string) { return this.service.findById(id); }

  @Get()
  findAll(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(10), ParseIntPipe) limit: number,
  ) { return this.service.findAll(page, limit); }
}
```

### Service Boilerplate
```typescript
@Injectable()
export class NameService {
  constructor(private readonly repo: NameRepository) {}

  async findById(id: string): Promise<NameEntity> {
    const entity = await this.repo.findById(id);
    if (!entity) throw new NotFoundException(`Name #${id} not found`);
    return entity;
  }

  async findAll(page: number, limit: number) {
    const [items, total] = await this.repo.findPaginated(page, limit);
    return { data: items, meta: { total, page, limit } };
  }
}
```

### Unit Test Boilerplate
```typescript
describe('NameService', () => {
  let service: NameService;
  let repo: jest.Mocked<NameRepository>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        NameService,
        { provide: NameRepository, useValue: { findById: jest.fn(), findPaginated: jest.fn(), save: jest.fn() } },
      ],
    }).compile();
    service = module.get(NameService);
    repo = module.get(NameRepository);
  });

  it('should throw NotFoundException when entity not found', async () => {
    repo.findById.mockResolvedValue(null);
    await expect(service.findById('bad-id')).rejects.toThrow(NotFoundException);
  });
});
```

## Tmux Monitoring for Long-Running Tasks

When running interactive processes (NestJS dev server, test watch mode, migrations), use tmux sessions so the user can monitor your work in real-time.

### Setup Tmux Session
```bash
SOCKET_DIR="${TMPDIR:-/tmp}/clawdbot-tmux-sockets"
mkdir -p "$SOCKET_DIR"
SOCKET="$SOCKET_DIR/clawdbot.sock"
SESSION=backend-dev
```

### Use Cases

**1. Running NestJS Dev Server:**
```bash
# Start dev server in tmux with hot-reload
tmux -S "$SOCKET" new -d -s "$SESSION" -n nest
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 "cd /home/node/project/apps/api && npm run start:dev" Enter

# Print monitor commands for user
echo "🧵 NestJS dev server started in tmux"
echo "To monitor: tmux -S \"$SOCKET\" attach -t \"$SESSION\""
echo "To view output: tmux -S \"$SOCKET\" capture-pane -p -J -t \"$SESSION\":0.0 -S -200"
```

**2. Running Tests in Watch Mode:**
```bash
# Start test watcher in tmux
tmux -S "$SOCKET" new -d -s backend-tests -n jest
tmux -S "$SOCKET" send-keys -t backend-tests:0.0 "cd /home/node/project/apps/api && npm run test:watch" Enter

echo "🧵 Jest watch mode started"
echo "To monitor: tmux -S \"$SOCKET\" attach -t backend-tests"
```

**3. Running Database Migrations:**
```bash
# Run migrations in tmux for visibility
tmux -S "$SOCKET" new -d -s backend-migration -n migrate
tmux -S "$SOCKET" send-keys -t backend-migration:0.0 "cd /home/node/project/apps/api && npm run migration:run" Enter

# Wait and capture output
sleep 3
OUTPUT=$(tmux -S "$SOCKET" capture-pane -p -J -t backend-migration:0.0 -S -200)
echo "$OUTPUT"

# Check for errors
if echo "$OUTPUT" | grep -i "error\|fail"; then
  echo "❌ Migration failed - check output above"
else
  echo "✅ Migration completed successfully"
fi
```

**4. Monitoring API Logs in Real-Time:**
```bash
# Start API server and monitor logs
tmux -S "$SOCKET" new -d -s backend-logs -n api
tmux -S "$SOCKET" send-keys -t backend-logs:0.0 "cd /home/node/project/apps/api && npm run start:dev 2>&1 | tee api.log" Enter

# Periodically check logs for errors
sleep 5
if tmux -S "$SOCKET" capture-pane -p -t backend-logs -S -50 | grep -i "error\|exception"; then
  echo "⚠️ Errors detected in API logs"
fi
```

**5. Running E2E Tests with Output:**
```bash
# Run E2E tests in tmux
tmux -S "$SOCKET" new -d -s backend-e2e -n e2e
tmux -S "$SOCKET" send-keys -t backend-e2e:0.0 "cd /home/node/project/apps/api && npm run test:e2e" Enter

echo "🧵 E2E tests running in tmux"
echo "To monitor: tmux -S \"$SOCKET\" attach -t backend-e2e"
```

### Capturing Output for Reporting
```bash
# Capture last 200 lines of dev server output
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -200

# Check if server is ready
if tmux -S "$SOCKET" capture-pane -p -t "$SESSION" -S -20 | grep -i "Application is running on"; then
  echo "✅ NestJS server is ready"
fi

# Check for compilation errors
if tmux -S "$SOCKET" capture-pane -p -t "$SESSION" -S -50 | grep -i "error TS"; then
  echo "❌ TypeScript compilation errors detected"
fi
```

### Cleanup
```bash
# Kill session when done
tmux -S "$SOCKET" kill-session -t "$SESSION"
```

**When to use tmux:**
- ✅ Running `npm run start:dev` for extended periods
- ✅ Running `npm run test:watch` while developing
- ✅ Running database migrations with real-time feedback
- ✅ Monitoring API logs during testing
- ✅ Running E2E tests that take time
- ❌ One-off commands (use regular bash instead)
- ❌ Quick linting/type checks (use regular bash instead)
- ❌ Simple unit tests (use regular bash instead)
