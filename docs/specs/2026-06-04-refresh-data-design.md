# refresh-data skill — Design Spec
**Date:** 2026-06-04
**Status:** Approved for implementation

---

## Problem

The CI smoke-test runs `check-data-freshness.sh` as a hard failure. Three data files go stale fast enough that any gap in toolkit usage causes CI to go red:

- `data/transfer-bonuses.json` — 7-day TTL, no automated refresh in CI
- `data/points-valuations.json` — 45-day TTL, no refresh script exists
- `data/sweet-spots.json` — 60-day TTL, no refresh script exists

Additionally, two skills (`rapidapi`, `trip-log`) are missing the `category` and `summary` frontmatter fields required by `gen-skill-tables.sh`, and `agents/travel-hacker.md` has drifted from `CLAUDE.md` after recent refactor commits.

The root cause: data freshness is a **runtime concern**, not a code-quality concern. CI is checking the wrong thing.

---

## Goals

1. CI stays green when the toolkit hasn't been used for weeks or months.
2. Data files are refreshed from live sources when a session starts after a gap.
3. No existing skills are modified; the solution is fully contained in this repo.
4. Refresh is invoked inside a Claude session (not via CLI without Claude).

---

## Out of Scope

- Scheduled/cron-based auto-refresh (no unattended data mutations)
- Changes to the shared Superpowers plugin or any upstream skill
- Refresh of hotel property files (`fhr-properties.json`, `thc-properties.json`, `chase-edit-properties.json`) — those have their own script and are not currently failing

---

## Architecture

Three self-contained changes:

```
1. skills/refresh-data/SKILL.md     ← new skill, project-local
2. scripts/smoke-test.sh            ← one-line edit: fail → skip for freshness
3. One-time cleanup commit          ← frontmatter + agent sync + table regen
```

---

## Change 1: `refresh-data` skill

### Location
`skills/refresh-data/SKILL.md`

### Frontmatter
```yaml
name: refresh-data
category: maintenance
summary: Refresh stale data files and repair toolkit drift before a session.
description: >
  Refresh all stale data files and repair toolkit drift before starting a
  session. Triggers on "refresh data", "session start", "been a while",
  "update valuations/bonuses/sweet spots", or when smoke-test failures
  are mentioned.
```

### Behavior (in order)

**Step 1 — Freshness audit**
Run `bash scripts/check-data-freshness.sh` and display the output table. Identify which files are STALE.

**Step 2 — Auto-refresh: `transfer-bonuses.json`**
Run `python3 scripts/refresh-transfer-bonuses.py`. This script scrapes frequentmiler.com and awardwallet.com (no API keys required) and writes the file with `_meta.last_updated` set to today. If the script exits non-zero, report the error and continue — do not abort the whole refresh.

**Step 3 — Live-fetch refresh: `points-valuations.json` and `sweet-spots.json`**

Data source priority (applied in order, first success wins):

1. **`data/.refresh-inputs.md`** — if this file exists, read it first. It is freeform: the user may have pasted a TPG table, a Reddit thread, a screenshot transcript, or any other source material. Parse intent, not schema. Extract any CPP values or sweet-spot changes mentioned. After incorporating, move the file to `data/.refresh-inputs.md.used` (keeps a record without re-triggering on next run).

2. **Live web fetch** — use `WebFetch` on the following URLs in order:
   - `https://thepointsguy.com/guide/airline-miles-valuations/` — monthly CPP table for `points-valuations.json`
   - `https://www.nerdwallet.com/article/travel/airline-miles-points-valuations` — secondary CPP source
   - `https://frequentmiler.com/best-use-of-points-and-miles/` — sweet spot coverage for `sweet-spots.json`
   - `https://thepointsguy.com/guide/best-ways-to-use-points-miles/` — sweet spots secondary

   Extract structured values where possible. If a page returns an error, a paywall block, or unrecognizable markup, skip it and move to the next source. Do not fabricate data — if no usable values are extracted, fall through to step 3.

3. **Model knowledge fallback** — use training knowledge to review and update values. When this path is taken, add a prominent notice to the skill's output:
   > ⚠️ Web fetch failed or returned no usable data. Values updated from model knowledge. Verify against TPG or NerdWallet before any high-stakes booking.

For both files, show a before/after diff of changed values, then write the file. Do not prompt for confirmation — the diff is informational.

**Step 4 — Drift repair**
Run `bash scripts/sync-agent.sh` then `bash scripts/gen-skill-tables.sh`. Both are idempotent. Run unconditionally — drift repair is cheap and prevents the agent-sync failure from silently creeping back.

**Step 5 — Commit**
Stage all modified files under `data/` and `agents/` and `README.md` and `llms.txt`. Commit with:
```
chore: refresh data files and repair toolkit drift (YYYY-MM-DD)
```
Show the staged file list, then commit.

### The `data/.refresh-inputs.md` contract

- **Format:** freeform markdown. No schema required.
- **How to use:** Before invoking the skill, create this file and paste in any external content (a table copied from TPG, a note about a program change, anything). The skill reads it, incorporates what it finds, and renames it to `.refresh-inputs.md.used`.
- **Git:** `.refresh-inputs.md` and `.refresh-inputs.md.used` are both gitignored — they are ephemeral session artifacts, not repo content.

---

## Change 2: `smoke-test.sh` freshness demotion

In the freshness check block (around line 160), change:

```bash
# Before
fail "stale data files (run: python3 scripts/refresh-hotel-data.py for hotels)"

# After
skip "stale data files — run the refresh-data skill before your session"
```

`skip` emits `[-]` and does not increment `FAIL`. All other static checks remain hard failures.

---

## Change 3: One-time cleanup

The following fixes unblock CI immediately and set the baseline the `refresh-data` skill maintains going forward.

**3a — Add missing frontmatter to `rapidapi` and `trip-log`:**

`skills/rapidapi/SKILL.md`:
```yaml
category: flights
summary: Cash flight prices and hotel/restaurant discovery via RapidAPI scrapers (Google Flights, Skyscanner, Booking.com, TripAdvisor, Yelp).
```

`skills/trip-log/SKILL.md`:
```yaml
category: orchestration
summary: Save flight searches, itineraries, and booked trips to trips/logs/ for future reference.
```

**3b — Sync agent file:**
```bash
bash scripts/sync-agent.sh
```

**3c — Regenerate tables:**
```bash
bash scripts/gen-skill-tables.sh
```

**3d — Verify:**
```bash
bash scripts/smoke-test.sh --quick
```
Expected: 9 passed, 0 failed (freshness is now `[-]` skip, not `[X]` fail).

---

## File additions / modifications summary

| Path | Change |
|---|---|
| `skills/refresh-data/SKILL.md` | New file |
| `scripts/smoke-test.sh` | Edit: `fail` → `skip` in freshness block |
| `skills/rapidapi/SKILL.md` | Edit: add `category` + `summary` |
| `skills/trip-log/SKILL.md` | Edit: add `category` + `summary` |
| `agents/travel-hacker.md` | Regenerated by `sync-agent.sh` |
| `README.md` | Regenerated by `gen-skill-tables.sh` |
| `llms.txt` | Regenerated by `gen-skill-tables.sh` |
| `.gitignore` | Add `.refresh-inputs.md` and `.refresh-inputs.md.used` |

---

## Success criteria

- `bash scripts/smoke-test.sh --quick` exits 0 on a repo that hasn't been touched in 90 days
- Invoking the `refresh-data` skill updates all three stale data files, repairs drift, and commits in a single session
- No shared/upstream skills were modified
- `.refresh-inputs.md` can be used to inject external data without any prompting back-and-forth
