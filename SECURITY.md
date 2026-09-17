# Security Policy

## Reporting a vulnerability

Please report security issues privately to **support@amass.tech**.

Do not open a public GitHub issue for a suspected vulnerability — this repository
is public, and an issue discloses the problem to everyone before we can fix it.

## Scope

This repository contains only the MCP Registry listing metadata (`server.json`)
for the Amass MCP server. The code that serves requests is not hosted here.

Reports are welcome for:

- **The hosted server** at `https://mcp.amass.tech` — authentication and
  authorization flaws, token handling, data exposure across organizations, or
  any way to reach data you are not entitled to.
- **The Amass API and platform** at `https://app.amass.tech` and
  `https://platform.amass.tech`.
- **This listing** — anything that would let a third party publish or alter the
  `tech.amass/amass` registry entry, or redirect clients away from
  `https://mcp.amass.tech/mcp`.

## What to include

- What you found and where, with enough detail to reproduce it.
- What an attacker could do with it.
- Any proof-of-concept request, log excerpt or screenshot.

Please do not access, modify or retain data belonging to other Amass customers
while investigating, and do not run denial-of-service or load tests against our
infrastructure.

## What to expect

We will acknowledge your report, keep you updated while we investigate, and tell
you when the issue is resolved. We are happy to credit reporters who would like
to be named.
