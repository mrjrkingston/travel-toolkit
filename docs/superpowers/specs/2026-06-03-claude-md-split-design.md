# Design: Split CLAUDE.md into Public + Private Layers

**Date:** 2026-06-03  
**Status:** Approved

## Problem

The repo is public on GitHub. `CLAUDE.md` contains personal behavioral configuration (how the agent should act for this specific user) alongside generic reference content (alliance data, cabin codes, tool inventory) that any forker would benefit from. Mixing these creates two problems:

1. Personal workflows, operational rules, and rare nuggets are exposed publicly
2. The file is 40.7k chars, over the 40k performance threshold

## Solution

Split `CLAUDE.md` into two files along a clear boundary: *reference knowledge any forker benefits from* vs *personal behavioral configuration*.

## File Structure

### `CLAUDE.md` (tracked, public, ~24k chars)

Generic reference content — useful to anyone who forks this repo. Contains no personal preferences or behavioral flows.

Sections:
- Tool index: MCP servers (one-liner each) + skills (one-liner each)
- Data file map: what each `data/*.json` file contains and when to use it
- Output Format
- API Keys (generic: "keys come from env vars, see `.env.example`")
- Cabin Codes (F/J/W/Y reference table)
- Alliance Awareness (Star Alliance, oneworld, SkyTeam membership)
- Partner Awards (cross-alliance booking reference)
- Hotel Chain Recognition (brand → loyalty program lookup)
- Points Valuations (how to read the data file, floor/ceiling rules)
- Sweet Spots (how to use the data file, tier definitions)
- Flight Source Priority (tool comparison table)
- Market Selection Strategy (country market arbitrage)
- Fallback and Resilience (what to try when a tool fails)
- Booking Guidance (phone numbers, booking flow, hold-before-transfer rule)
- Premium Hotel Programs (FHR/THC/Chase Edit reference)
- Important Notes (rate limits, data freshness, Seats.aero caveats)
- `@CLAUDE.local.md` — import line at the bottom

### `CLAUDE.local.md` (gitignored, private, ~17k chars)

Personal behavioral configuration. Never pushed to GitHub.

Sections:
- PRE-OUTPUT GATE (personal communication rules — no action-offer sentences)
- Your Mindset (be opinionated, show math, be proactive not passive)
- Proactive Behaviors (personal workflows: pull balances first, always write trip log, hit Atlas Obscura on destination mentions, hotel chain trigger table)
- Lessons Learned (hard-won operational nuggets: search all Seats.aero sources, Duffel beats SerpAPI for prices, SW is never in GDS, Companion Pass CPP math, small market behavior)

### `.gitignore` addition

```
CLAUDE.local.md
```

## How the Import Works

Claude Code resolves `@CLAUDE.local.md` at load time. The agent sees both files as a single combined context. If `CLAUDE.local.md` is missing (e.g., someone else clones the repo), Claude Code skips it silently and uses the public baseline only — no errors, no broken behavior.

The `@CLAUDE.local.md` line goes at the bottom of the public `CLAUDE.md` so the private behavioral rules load after and can override anything in the public file.

## Content Migration Rules

| Content type | Destination |
|---|---|
| "What this tool does" | Public CLAUDE.md |
| "When and how I use this tool" | Private CLAUDE.local.md |
| Reference tables (cabin codes, alliances, chains) | Public CLAUDE.md |
| Behavioral flows ("when X, always do Y") | Private CLAUDE.local.md |
| Fallback procedures (generic) | Public CLAUDE.md |
| Lessons learned from real searches | Private CLAUDE.local.md |
| Phone numbers and booking steps | Public CLAUDE.md |
| PRE-OUTPUT GATE and mindset rules | Private CLAUDE.local.md |

## Size Outcome

| File | Estimated chars | Threshold |
|---|---|---|
| `CLAUDE.md` (public) | ~24,000 | < 40,000 ✓ |
| `CLAUDE.local.md` (private) | ~17,000 | < 40,000 ✓ |
| Combined (as agent sees it) | ~41,000 | n/a (split load) |

## What Changes in `.gitignore`

Add one line:
```
CLAUDE.local.md
```

The existing `.gitignore` already covers `.env`, `data/points-balances.yaml`, `trips/`, `seats-aero-chats/`, `*.pdf`, `Screenshot*.png`.

## Out of Scope

- Trimming prose within sections (separate effort)
- Moving content to individual skill SKILL.md files (future)
- Changing any skill behavior or data files
