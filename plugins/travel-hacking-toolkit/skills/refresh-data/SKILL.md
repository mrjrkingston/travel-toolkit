---
name: refresh-data
category: maintenance
summary: Refresh stale data files and repair toolkit drift before a session.
description: >
  Refresh all stale data files and repair toolkit drift at the start of a
  session after a gap. Triggers on "refresh data", "session start", "been a
  while", "update valuations", "update bonuses", "update sweet spots", or
  when smoke-test failures are mentioned.
---

# refresh-data

Run this skill at the start of any session after a gap. It refreshes stale
data files from live sources, repairs toolkit drift, and commits the result.

## Step 1 — Freshness audit

Run:
```bash
bash scripts/check-data-freshness.sh
```

Display the output table. Note which files are STALE. If all files are FRESH,
report that and stop — no commit needed.

## Step 2 — Auto-refresh transfer-bonuses.json

Run:
```bash
python3 scripts/refresh-transfer-bonuses.py
```

This scrapes frequentmiler.com and awardwallet.com. No API keys required.
If the script exits non-zero, report the error message and continue to the
next step — do not abort the entire refresh.

## Step 3 — Refresh points-valuations.json

**Source priority (first success wins):**

### Priority 1: data/.refresh-inputs.md

If `data/.refresh-inputs.md` exists, read it first. It is freeform — the user
may have pasted a TPG table, a Reddit post, a screenshot transcript, or any
other external content. Parse intent, not schema: extract any CPP values or
program changes mentioned. After incorporating, rename the file:
```bash
mv data/.refresh-inputs.md data/.refresh-inputs.md.used
```

### Priority 2: Live web fetch

Use WebFetch on these URLs in order. Stop at the first that returns usable
structured data:

1. `https://thepointsguy.com/guide/airline-miles-valuations/` — TPG monthly CPP table
2. `https://www.nerdwallet.com/article/travel/airline-miles-points-valuations` — secondary source

Extract CPP values per program. If a page returns an error, paywall block, or
unrecognizable markup, skip it and try the next URL. Do not fabricate values.

### Priority 3: Model knowledge fallback

If both web fetches fail or return no usable data, update values from model
knowledge and add this notice to output:

> ⚠️ Web fetch returned no usable data. Values updated from model knowledge.
> Verify against TPG or NerdWallet before any high-stakes booking.

### Writing the file

Show a before/after diff of changed CPP values, then write the file with
`_meta.last_updated` set to today's date (YYYY-MM-DD format).

## Step 4 — Refresh sweet-spots.json

Same `.refresh-inputs.md` check as Step 3 — the file may contain sweet-spot
data alongside CPP values; incorporate anything relevant.

Use WebFetch on these URLs in order:

1. `https://frequentmiler.com/best-use-of-points-and-miles/`
2. `https://thepointsguy.com/guide/best-ways-to-use-points-miles/`

Update any sweet spots that have meaningfully changed (new programs added,
old ones removed, rate changes). Show before/after diff, then write the file
with `_meta.last_updated` set to today. Same model-knowledge fallback and
warning notice applies.

## Step 5 — Drift repair

Run:
```bash
bash scripts/sync-agent.sh
bash scripts/gen-skill-tables.sh
```

Both are idempotent. Run unconditionally — drift repair is cheap and prevents
the agent-sync failure from creeping back silently.

## Step 6 — Commit

Stage all modified files and commit:
```bash
git add data/transfer-bonuses.json data/points-valuations.json data/sweet-spots.json
git add agents/travel-hacker.md README.md llms.txt
git commit -m "chore: refresh data files and repair toolkit drift ($(date +%Y-%m-%d))"
```

---

## Using data/.refresh-inputs.md

Create this file before invoking the skill if you have external data to inject:

```
# Refresh inputs — [date]

[paste TPG table, Reddit post, news article, or any content here]
```

The skill reads it, extracts what it can, writes updated values, then renames
the file to `data/.refresh-inputs.md.used` so it doesn't re-trigger on the
next run. Both files are gitignored.
