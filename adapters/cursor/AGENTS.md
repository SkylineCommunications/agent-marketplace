# DataMiner DevOps Agent

AI orchestrator and portable skills for building custom DataMiner web applications with React, Vite, TypeScript, and DataMiner web services.

## DataMiner App Builder

An app builder agent that builds static frontend applications that can be used for deployment inside Skyline DataMiner.

- **Role:** subagent
- **Skills:** `dataminer-create-new-app`, `dataminer-frontend`, `dataminer-api`, `dataminer-data-discovery`, `dataminer-execute-query`, `dataminer-execute-automation-script`, `dataminer-performing-actions`, `dataminer-headless-ias`, `dataminer-debug-issues`

## DataMiner DevOps Agent

Orchestrate the creation of custom DataMiner web applications. Classify the user's goal, pick the right specialist sub-agent, and coordinate the workflow. This agent contains no domain knowledge; load the relevant DataMiner skills before delegating.

- **Role:** orchestrator
- **Subagents:** `dataminer-app-builder`
- **Skills:** `dataminer-create-new-app`, `dataminer-debug-issues`

## Skill: dataminer-api

If you need to use DataMiner Web Services endpoints use this skill. Use for authentication via ConnectAppAndInfo, strict endpoint validation against DataMiner docs, GetSecurityInfo access checks, global authorization guard patterns, and WebSocket connection setup.

## Skill: dataminer-create-new-app

Create a new React / static FRONTEND WEB APPLICATION (browser HTML/CSS/JS served from the DataMiner web server) with DataMiner API integration from zero: gather requirements, set up the static build, implement DataMiner auth, build initial features, and produce a deployable build. NOT for Automation scripts, QActions, connectors/protocols, GQI data sources, or DataAPI-driven elements — those are server-side/on-box artifacts; use dataminer-sdk (official dotnet new templates such as dataminer-automation-project) or dataminer-scaffolding (connectors) instead.

## Skill: dataminer-data-discovery

Perform AI-assisted data discovery against a live DataMiner system using the CreateAIGeneratedQuery endpoint. Use when the user asks to discover data, query DataMiner with natural language, run data discovery on goals, items, products, releases, or any DataMiner entity.

## Skill: dataminer-debug-issues

Use when the user says something is broken, not working, has a bug, or behaves unexpectedly. Open the running app in a browser and use Playwright to inspect console logs, network requests, and WebSocket frames to find the cause yourself before asking the user.

## Skill: dataminer-execute-automation-script

Use when implementing or debugging a call to the DataMiner ExecuteAutomationScriptWithOutput JSON API. Contains the exact JSON request structure, scriptOptions fields, and how parameters are encoded.

## Skill: dataminer-execute-query

Execute GQI queries in a DataMiner frontend application using OpenQuerySessionAsync over WebSocket. Use when building production apps that need to fetch GQI data (DOM instances, ad hoc data sources, custom queries) from DataMiner using a known query object, or when the user provides a query object directly.

## Skill: dataminer-frontend

If you need to create or update user interfaces use this skill. This skill contains everything you need to know before building or making changes to UI. It makes sure you're consistent with other DataMiner interfaces and follow best practices.

## Skill: dataminer-headless-ias

Use when a frontend app needs to drive a DataMiner Interactive Automation Script (IAS) from a custom UI. Covers the full WebSocket + HTTP protocol flow, dialog parsing, values string construction, re-render handling, and multi-dialog wizard navigation.

## Skill: dataminer-performing-actions

Use when the app needs to perform an action on the DataMiner system: creating, updating, deleting data, triggering workflows, or executing any server-side operation. Covers which mechanism to use and how to call it from the frontend.
