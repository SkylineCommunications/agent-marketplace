---
name: dataminer-e2e-testing
description: 'End-to-end testing for DataMiner frontend apps with Playwright: test planning, setup, mocked HTTP and WebSocket dependencies, authentication workflows, coverage, and completion criteria. Use when creating a new app or testing changes to an existing app.'
license: LicenseRef-Skyline-Agent-Marketplace
user-invocable: true
metadata:
  updated: 2026-09-17
  version: 1.0.0
---

# DataMiner E2E Testing Skill

Every new DataMiner frontend app MUST ship with a Playwright end-to-end test suite, even when the user does not explicitly request tests. App creation is not complete until:

1. An `e2e/TEST_PLAN.md` was written before tests were created or extended, and the `e2e/` suite covers its in-scope frontend scenarios.
2. A fresh production build succeeds.
3. `npx playwright test` passes with all required tests green, not skipped or marked as expected failures.

These are **frontend-only tests against mocked dependencies**, not backend or DataMiner integration tests. Exercise the real app in the browser while intercepting its HTTP and WebSocket boundaries. Never require a live DMA, real credentials, backend deployment, or backend writes to run the suite. Do not replace the frontend's own session handling, API client, state management, or rendering with mocks.

For updates to an existing app, run the existing suite and extend it to cover changed behavior. Do not claim completion when required tests are missing, failing, or could not run. Report an execution blocker explicitly instead of claiming success.

## 0. Write the Test Plan First

Before creating or modifying tests, inspect the app's actual behavior and write or update `e2e/TEST_PLAN.md`. Share the plan before implementing it; do not retroactively write a plan around tests that already exist.

- Scope the suite to the custom app itself. Chromium is sufficient; do not add other browsers unless requested.
- Include the app's sign-in redirect and sign-out workflows in the test plan. Mock their external authentication boundaries and use synthetic sessions; never use real credentials or remove or bypass authentication in production code.
- Map each app feature to scenario IDs, setup/data, user actions, observable expected results, and the intended spec file. Include edge cases, combined interactions, resets/recovery, and responsive workflows where supported.
- Record exclusions and limitations explicitly. Do not invent backend behavior or add product features solely to make hypothetical test cases possible.
- Test observable UI changes, not merely a click, a visible button, or an internal state attribute. State the meaningful checks for each scenario, including rendered data, computed theme appearance, and action outcomes.
- Define the build/test commands. Before completion, reconcile the implemented tests with the plan and report any uncovered scenarios. Passing test counts alone do not prove whole-app or line/branch coverage.

### Test Names and Plan Tags

- Test names MUST describe the behavior being verified; do not prefix them with test-plan IDs.
- Put plan IDs in Playwright's native `tag` metadata, prefixed with `@`. For example, a case covering D4 and D6 uses `{ tag: ['@D4', '@D6'] }`, not a title starting with `D4/D6:` or a single `@D4/D6` tag.
- Keep IDs stable in `e2e/TEST_PLAN.md` and use matching tags for traceability. Parameterized cases share the relevant tags and include their distinguishing input or viewport in the descriptive title.
- Tag shared plan checks on each applicable test, or use a tagged `test.describe` group so those tags are inherited. Tags must reflect implemented coverage, not merely intended coverage.
- Verify tags are present in the test source. Use `npm run test:e2e -- --grep "@D4"` to run matching cases, or add `--list` to inspect selection. Playwright treats `--grep` as a regular expression, so use token boundaries if IDs share prefixes.

## 1. Setup

Include `@playwright/test` as a dev dependency during project setup, then install Chromium:

```powershell
npm install -D @playwright/test
npx playwright install chromium
```

Add these scripts alongside the app's existing scripts in `package.json`:

```json
{
  "scripts": {
    "preview": "vite preview",
    "test:e2e": "playwright test"
  }
}
```

Create `playwright.config.ts`. Serve the production build with Vite preview to exercise the deployed `/public/{BuildFolderName}/` base path:

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  preserveOutput: 'never',
  reporter: 'list',
  use: {
    baseURL: 'http://localhost:4173',
    serviceWorkers: 'block',
    trace: 'off'
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
  webServer: {
    command: 'npm run preview -- --host localhost --port 4173 --strictPort',
    url: 'http://localhost:4173/public/{BuildFolderName}/index.html',
    reuseExistingServer: false
  }
});
```

Replace `{BuildFolderName}` with the app's actual build folder name everywhere. Run `npm run build` before testing. Use a free port and update both URLs and the preview command together if 4173 is occupied; do not reuse an unrelated server. The preview server only serves static frontend assets, not a backend. Keep Playwright and test files out of the deployed bundle.

Use only the `list` reporter for terminal feedback. Do not configure HTML, JSON, or other persisted reports, and do not retain traces, screenshots, videos, or test output folders.

## 2. Mock Every External Dependency

### Discovery-Driven Mock Contract

Test mocks must be produced from the app's completed data-discovery phase, not invented independently while tests are written.

- Start from the exact documented Web API endpoint or hardcoded GQI query used by production code.
- Preserve the real request method, request body, `{ "d": ... }` envelopes, GQI columns and metadata, WebSocket methods, paging, and completion events.
- Base the normal fixture on sanitized representative records observed during discovery. Remove customer-sensitive values, credentials, connection IDs, and hostnames without changing the schema.
- Derive empty, null, boundary, changed-data, and failure fixtures from that same observed schema.
- Assert outgoing query objects and meaningful request parameters where practical so a production/test contract drift fails the suite.
- Never create a simpler test-only endpoint, import fixtures into production code, or add `if (test)` behavior to the app. Playwright interception is the mock boundary.

This keeps the suite backend-independent while still exercising the code that will run against the real DataMiner system.

Create shared fixtures in `e2e/fixtures.ts`, with deterministic data and per-test overrides for response bodies, HTTP statuses, empty datasets, and failures. Register all routes before navigating to the app.

- Use `browserContext.route` or `page.route` for every HTTP endpoint the app calls, including session checks, security checks, query session creation/cleanup, and write operations.
- Match the response shapes verified under the [dataminer-api skill](../dataminer-api/SKILL.md), including the `{ "d": ... }` envelope where the endpoint uses it. Use the [dataminer-execute-query skill](../dataminer-execute-query/SKILL.md) for GQI payloads. Do not invent response contracts or call a live system while running tests.
- Use `browserContext.routeWebSocket` or `page.routeWebSocket` for all WebSocket connections. Never call `connectToServer()` in the test mocks.
- Install a catch-all HTTP guard before specific routes. Allow only the local preview server's static assets to reach the network; abort and fail the test on unmocked API requests or external hosts. Guard all WebSocket URLs too, failing on unknown messages or connections instead of connecting to a real server.
- Supply mocked authentication responses and synthetic cookies. Assert the app's sign-in redirects and sign-out behavior without navigating to a live identity provider or using real credentials.
- Bundle fonts/images locally or intercept them as fixtures. The suite must not depend on third-party network availability.

Use a synthetic connection GUID and a cookie helper:

```typescript
import type { BrowserContext, Page } from '@playwright/test';

export const APP_URL = '/public/{BuildFolderName}/index.html';
export const CONNECTION_GUID = '00000000-1111-4222-8333-444444444444';

export async function setSessionCookie(context: BrowserContext): Promise<void> {
  await context.addCookies([
    { name: 'DMAConnection', value: CONNECTION_GUID, domain: 'localhost', path: '/' }
  ]);
}

type MockResponse = { body: unknown; status?: number };

export async function mockDataMinerApi(
  page: Page,
  overrides: Record<string, MockResponse> = {}
): Promise<void> {
  const responses: Record<string, MockResponse> = {
    IsConnectionAlive: { body: { d: true } },
    ...overrides
  };

  await page.route('**/API/v1/Json.asmx/*', async route => {
    const endpoint = new URL(route.request().url()).pathname.split('/').pop()!;
    if (!Object.hasOwn(responses, endpoint)) {
      await route.abort();
      throw new Error(`Unmocked DataMiner endpoint: ${endpoint}`);
    }

    const response = responses[endpoint];
    await route.fulfill({
      status: response.status ?? 200,
      contentType: 'application/json',
      body: JSON.stringify(response.body)
    });
  });
}
```

This is a starting helper, not a complete fixture: add the HTTP network guard, WebSocket mocks, and every endpoint used by the app. Verify `IsConnectionAlive`'s success payload against the contract used by the app. For endpoints called with different request bodies, dispatch on the method and parsed request body as well as the endpoint name.

### GQI and Interactive Workflows

Mock the complete browser-visible flow, not just the HTTP session opening:

- Handle WebSocket setup (`SetConnectionID`), subscriptions (`GetEvents`), and keep-alives using the [WebSocket setup reference](../dataminer-api/references/websocket-setup.md).
- Mock `OpenQuerySessionAsync` or `ObserveQuerySessionAsync` responses and deliver rows, paging, completion, and relevant realtime events through the mocked WebSocket using the [GQI protocol reference](../dataminer-execute-query/references/websocket-protocol.md). Correlate messages with the actual request and subscription IDs; do not hardcode IDs the app generates.
- For interactive automation, mock the HTTP calls and dialog/event messages described by the [dataminer-headless-ias skill](../dataminer-headless-ias/SKILL.md).
- Assert the resulting rendered data and user interactions. Loading/error-only tests are not sufficient coverage of a data-driven feature.
- For write actions, inspect the outgoing request and return a simulated success/failure, then assert the frontend's resulting state. Never execute a real automation script or change backend data.

## 3. Minimum Required Coverage

### Authentication Workflows

Use the [dataminer-api authentication contract](../dataminer-api/SKILL.md) to mock authentication boundaries. Test that a signed-out session triggers the expected sign-in redirect and that signing out clears or invalidates the frontend session and reaches the expected destination. Cover app-owned failure and retry behavior where present, but never navigate to a live identity provider or test the provider itself.

### Core Features (`e2e/<feature>.spec.ts`)

Use one file per major feature:

- The main screen renders the mocked data correctly: headings, key values, and counts.
- Every requested user-facing feature works end-to-end within the frontend against mocks.
- Empty and edge data states (no rows, zero counts, multiple items) render sensibly.
- Refresh, filters, form submissions, and write actions produce the expected requests and UI updates, wherever applicable.
- Relevant validation, loading, paging, and realtime update states are covered when the app supports them.
- Check exact row sets and summary values independently of implementation constants. Exercise search normalization, every filter option, combined filters, clearing/reset, and empty-result recovery when available.
- For refresh and other repeatable actions, assert in-progress/disabled states, completion, repeatability, and preservation or updates of relevant data and selections. Use a controlled browser clock for timed behavior rather than extending delays to make tests pass.

### Error Handling

- Where an app feature fetches or writes data, mock failures and assert its error state and retry/recovery behavior. Include authentication failure handling when it is observable in the app.
- Cover WebSocket failures and recovery controls when the app uses them. For static local datasets, document that no data-API failure state exists instead of fabricating one.

### Theming (When a Theme Switcher Exists)

- Explicit light and dark modes change computed UI colors, persist across reload, and remain selected despite OS changes.
- System mode follows OS preference changes in both directions via `page.emulateMedia({ colorScheme })`, including after reload.
- Cover theme menu selection, open/close behavior, and supported keyboard interactions.

## 4. Reliable Tests

- Use role/label-based locators such as `getByRole`, `getByLabel`, `getByTitle`, and `getByText`, not brittle CSS selectors.
- Use auto-retrying assertions such as `await expect(locator).toBeVisible()` or `await expect.poll(...)` for asynchronous changes.
- Keep tests independent: install mocks and set cookies in fixtures, `beforeEach`, or at the start of each test. Keep mutable mock state isolated per test for parallel execution.
- Do not use fixed sleeps or `waitForTimeout`; wait for observable UI, requests, or URLs.
- Check relevant desktop and mobile layouts by interacting with controls, checking page overflow and table scrolling, and verifying local assets load. Do not generate screenshots or other test artifact folders.
- Assert unexpected network traffic and uncaught page errors in shared fixture teardown, not just in page-close callbacks.
- Do not weaken assertions, skip required scenarios, or mock frontend internals just to make tests pass.

## 5. Definition of Done

Run from the generated app's project folder:

```powershell
npm run build
npx playwright test
```

- Require a successful production build and all required mocked frontend tests passing before delivery.
- Verify every in-scope scenario in `e2e/TEST_PLAN.md` is covered and keep exclusions explicit. Include the plan link in the handover.
- If a test fails, fix the frontend or its fixture and rerun. If execution is blocked, report the blocker and leave the task incomplete; never describe unrun tests as passing.
- Include both commands and the actual result counts from the terminal output in the handover alongside deployment instructions.
