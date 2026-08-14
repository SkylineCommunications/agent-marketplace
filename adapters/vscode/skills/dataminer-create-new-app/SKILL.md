---
name: dataminer-create-new-app
description: 'Create a new React / static FRONTEND WEB APPLICATION (browser HTML/CSS/JS served from the DataMiner web server) with DataMiner API integration from zero: gather requirements, set up the static build, implement DataMiner auth, build initial features, and produce a deployable build. NOT for Automation scripts, QActions, connectors/protocols, GQI data sources, or DataAPI-driven elements — those are server-side/on-box artifacts; use dataminer-sdk (official dotnet new templates such as dataminer-automation-project) or dataminer-scaffolding (connectors) instead.'
license: MIT
user-invocable: true
---

> **Skill reference notice:** This skill refers to additional skills that are not included in this public distribution: `dataminer-sdk`. If any of them is required for the current task, inform the user and ask whether to continue while ignoring the missing skill or stop.

# DataMiner Create New App Skill

> **Scope guard — frontend web apps only (read first).** This skill is exclusively for building a **React / static frontend web application** that runs in the browser and talks to DataMiner over its web API. It is **not** the entry point for any server-side or on-box artifact, and "create a new app" here means a **web UI**, not an automation/connector solution. If the request is to create an **Automation script**, a **QAction**, a **connector/protocol**, a **GQI ad hoc data source**, or a **DataAPI**-driven element, **stop and do not use this skill** — load **`dataminer-sdk`** and scaffold with the official `dotnet new` templates (e.g. `dataminer-automation-project`, including a real `.sln` solution), or **`dataminer-scaffolding`** for connectors. Matching on the words "create"/"new" alone is not enough; confirm the target is a browser web app before continuing.

When creating a new application you should ALWAYS go through the following steps:

1. Gather requirements from the user
2. Set up the project structure and build configuration
3. Handle session bootstrap (no in-app login UI)
4. Implement initial features based on requirements
5. Build and test the application to ensure it meets requirements and is production-ready
6. Provide deployment instructions for hosting on DataMiner

Make sure you don't skip any of these steps and follow them in order to ensure a successful app creation process.

---

1. Gather requirements from the user

- Ask the user what they want in their frontend app
- Never skip this step and start building immediately
- Get specific requirements, features, data and functionality details
- Understand the user's exact needs before proceeding

---

2. Set up the project structure and build configuration

- **Framework:** React
- **Output:** Static build (HTML / CSS / JS)
- Do not use `npm create vite` or any CLI scaffold. Create all files directly, then run `npm install` once.
- All app files must be created inside a dedicated project subfolder (e.g. `my-app-name/`) — never at the workspace root.
- Always use the latest version of dependencies (React, Vite, TypeScript, etc.) unless the user specifies otherwise or a specific version is required for compatibility.

**Architecture Constraints**

- No backend, proxies, or server middleware
- Lightweight and optimized
- All logic runs client-side

**Deployment model:**

- The build will be placed directly onto the hosting platform
- No server-side runtime required
- No Node runtime required after build

**Build configuration requirements:**

- A dedicated production build path
- A clean output folder
- No unnecessary dependencies
- Optimized, minimal bundle size
- Production build output is served from `/public/{BuildFolderName}/` on the DataMiner host
- All API and auth URLs must be relative — no hardcoded hosts or protocols
- Set `outDir` and `base` to the project name. For example, for a project named `my-app`: `outDir: 'my-app'` and `base: '/public/my-app/'`.

**Dependency management guidelines:**

- Avoid third-party npm packages unless they provide significant value
- Do not reinvent the wheel - use established packages for complex functionality (e.g., date manipulation, charting)
- Prefer native browser APIs and vanilla JavaScript when feasible

---

3. Handle session bootstrap (no in-app login UI)

- Do NOT build an in-app login page. Users sign in through DataMiner's built-in `/auth/` page before the app loads.
- Users reach the app via `{PROTOCOL}://{DOMAIN}/auth/?url=%2Fpublic%2F{BuildFolderName}%2Findex.html`.
- The app must expose a sign-out action.

For all session implementation details (cookie bootstrap, GUID verification, auth guard, sign-out flow), follow the **dataminer-api** skill (rules 3, 4, 5).

---

4. Implement initial features based on requirements

- Do not add unasked features or assumptions beyond the requirements provided by the user

### Fetching data from DataMiner

Always use **GQI queries** to fetch data. Never use direct DOM/element SOAP calls.

Use the **dataminer-data-discovery** skill to discover GQI queries and the **dataminer-execute-query** skill to execute them in the production app. The two-step approach is:

1. **Discover**: The agent authenticates to the DataMiner system (asking the user for host and credentials once), then runs an agent-side Node.js script that calls `CreateAIGeneratedQuery` (NL2GQI) and captures the discovered query object. No user action is needed beyond providing credentials.
2. **Build**: The agent hardcodes the discovered query into the production app using `OpenQuerySessionAsync`. The app itself never calls `CreateAIGeneratedQuery`.

---

5. Build and test the application to ensure it meets requirements and is production-ready

- Attempt to build the application before considering the work complete
- Test that the build process works without errors
- Verify the output is functional and deployable
- Do not end development without a successful build validation

---

6. Provide deployment instructions for hosting on DataMiner

After giving the user a new build, say:
> "We added a build folder to the project named `BuildFolderName`. You should copy that folder and paste it in the \Skyline DataMiner\Webpages\Public folder. Then access it through DataMiner's sign-in page at: `http(s)://<your-dma>/auth/?url=%2Fpublic%2F{BuildFolderName}%2Findex.html` (the `url` value is URL-encoded — `%2F` represents `/`). Opening `/public/{BuildFolderName}/index.html` directly will not have a session."
