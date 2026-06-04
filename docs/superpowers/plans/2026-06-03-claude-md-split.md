# CLAUDE.md Public/Private Split — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split the single 40.7k-char `CLAUDE.md` into a tracked public file (generic reference) and a gitignored private file (personal behavioral config), so personal workflows stay off GitHub.

**Architecture:** Extract four sections (PRE-OUTPUT GATE, Your Mindset, Proactive Behaviors, Lessons Learned) into a new `CLAUDE.local.md` that is gitignored. Rewrite `CLAUDE.md` to contain only generic reference content and an `@CLAUDE.local.md` import at the bottom. Claude Code resolves the import at load time — the agent sees both files as one.

**Tech Stack:** Markdown files, Claude Code `@file` import syntax, git.

---

## File Map

| File | Action | Result |
|------|--------|--------|
| `CLAUDE.md` | Rewrite — remove 4 private sections, add `@CLAUDE.local.md` at bottom | ~24k chars, public, tracked |
| `CLAUDE.local.md` | Create — contains the 4 extracted private sections | ~17k chars, private, gitignored |
| `.gitignore` | Add one line: `CLAUDE.local.md` | Prevents private file from ever being pushed |

---

### Task 1: Create `CLAUDE.local.md` with the four private sections

**Files:**
- Create: `CLAUDE.local.md`

The private file contains exactly these four sections, extracted verbatim from the current `CLAUDE.md`. Read the current `CLAUDE.md` (lines 1–33 and 114–175 and 389–468) and write them here in this order.

- [ ] **Step 1: Create `CLAUDE.local.md`**

Write this file at the repo root. The content is the four private sections from `CLAUDE.md`, in order, with no other changes:

```
Section 1 — PRE-OUTPUT GATE: lines 1–21 of current CLAUDE.md
Section 2 — Your Mindset: lines 27–33 of current CLAUDE.md (the "## Your Mindset" block)
Section 3 — Proactive Behaviors: lines 114–175 of current CLAUDE.md (the full "## Proactive Behaviors" block including all sub-sections)
Section 4 — Lessons Learned: lines 389–468 of current CLAUDE.md (the full "## Lessons Learned" block through end of file)
```

Assemble them in that order with a blank line between each section. The file needs no header or frontmatter — Claude Code will load it as continuation of CLAUDE.md context.

- [ ] **Step 2: Verify the private file exists and has all four section headers**

Run:
```bash
grep "^## " CLAUDE.local.md
```

Expected output:
```
## PRE-OUTPUT GATE (mandatory, every response, no exceptions)
## Your Mindset
## Proactive Behaviors
## Lessons Learned
```

- [ ] **Step 3: Verify character count is in the expected range**

Run:
```bash
wc -c CLAUDE.local.md
```

Expected: between 15,000 and 19,000 characters.

---

### Task 2: Rewrite `CLAUDE.md` to remove private sections and add the import

**Files:**
- Modify: `CLAUDE.md`

The public CLAUDE.md keeps everything that was between the private sections. The sections to REMOVE are: PRE-OUTPUT GATE (lines 1–21), Your Mindset (lines 27–33), Proactive Behaviors (lines 114–175), and Lessons Learned (lines 389–468). The title line and everything else stays.

- [ ] **Step 1: Remove PRE-OUTPUT GATE block from CLAUDE.md**

Delete from line 1 through line 21 (from `## PRE-OUTPUT GATE` through the closing `---`). This removes the personal communication rules that should not be public.

- [ ] **Step 2: Remove Your Mindset block from CLAUDE.md**

Delete the `## Your Mindset` section — three bullet paragraphs starting with "Be proactive, not passive", "Be opinionated", and "Show your math." Stop before `## Tools at Your Disposal`.

- [ ] **Step 3: Remove Proactive Behaviors block from CLAUDE.md**

Delete from `## Proactive Behaviors` through the end of the last sub-section (`### When someone mentions a destination` and its three bullets). Stop before `## Points Valuations`.

- [ ] **Step 4: Remove Lessons Learned block from CLAUDE.md**

Delete from `## Lessons Learned` through the end of file (the Duffel Limitations sub-section is the last entry).

- [ ] **Step 5: Update the title section**

After removing the private sections, the file will open with `# Travel Hacking Toolkit` followed immediately by `## Tools at Your Disposal`. Add one line of intro text between them so the public file has a brief orientation:

```markdown
# Travel Hacking Toolkit

Reference guide for the travel-hacking-toolkit. Skills, data files, source priority, and booking procedures for award and cash travel research.
```

- [ ] **Step 6: Add `@CLAUDE.local.md` import at the very end of CLAUDE.md**

Append to the bottom of `CLAUDE.md`:

```markdown

@CLAUDE.local.md
```

The blank line before it is required. This is how Claude Code resolves additional context files.

- [ ] **Step 7: Verify the public file has the correct section headers and NOT the private ones**

Run:
```bash
grep "^## " CLAUDE.md
```

Expected — these 14 sections, in order:
```
## Tools at Your Disposal
## Flight Source Priority
## Output Format
## Market Selection Strategy
## Points Valuations
## API Keys
## Partner Awards
## Hotel Chain Recognition
## Alliance Awareness
## Sweet Spots
## Cabin Codes
## Fallback and Resilience
## Booking Guidance
## Premium Hotel Programs
## Important Notes
```

NOT present (private sections moved to CLAUDE.local.md):
- `## PRE-OUTPUT GATE`
- `## Your Mindset`
- `## Proactive Behaviors`
- `## Lessons Learned`

- [ ] **Step 8: Verify character count is in the expected range**

Run:
```bash
wc -c CLAUDE.md
```

Expected: between 22,000 and 26,000 characters.

- [ ] **Step 9: Verify the @import line is at the end of the public file**

Run:
```bash
tail -3 CLAUDE.md
```

Expected output includes `@CLAUDE.local.md` on the last line.

---

### Task 3: Update `.gitignore` to exclude `CLAUDE.local.md`

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Add `CLAUDE.local.md` to the personal files section of `.gitignore`**

The `.gitignore` already has a `# Personal / local-only files (not contributed upstream)` section. Add `CLAUDE.local.md` to it:

```
# Personal / local-only files (not contributed upstream)
.claude/settings.json
data/points-balances.yaml
trips/
*.pdf
Screenshot*.png
seats-aero-chats/
CLAUDE.local.md
```

- [ ] **Step 2: Verify git does not track the private file**

Run:
```bash
git status CLAUDE.local.md
```

Expected output includes something like `nothing to commit` or the file does not appear — meaning git is ignoring it. If it shows as untracked (not ignored), the gitignore rule did not apply.

Run this to force-check:
```bash
git check-ignore -v CLAUDE.local.md
```

Expected: `.gitignore:N:CLAUDE.local.md    CLAUDE.local.md` (where N is the line number).

---

### Task 4: Commit and push

**Files:** All three modified/created files.

- [ ] **Step 1: Stage the public changes only**

```bash
git add CLAUDE.md .gitignore
```

Do NOT add `CLAUDE.local.md` — it is gitignored and should not appear in `git status` as a stageable file.

- [ ] **Step 2: Verify only public files are staged**

Run:
```bash
git status
```

Expected: `CLAUDE.md` and `.gitignore` are staged. `CLAUDE.local.md` does NOT appear anywhere in the output (not staged, not untracked — fully ignored).

If `CLAUDE.local.md` appears as untracked, the gitignore rule from Task 3 was not applied correctly. Fix before committing.

- [ ] **Step 3: Commit**

```bash
git commit -m "$(cat <<'EOF'
refactor: split CLAUDE.md into public reference + private behavioral config

Public CLAUDE.md keeps generic reference content (tool index, alliances,
cabin codes, booking guidance, fallback table). Private CLAUDE.local.md
holds personal behavioral rules (PRE-OUTPUT GATE, Proactive Behaviors,
Lessons Learned) and is gitignored — never pushed to GitHub.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

- [ ] **Step 4: Push to origin**

```bash
git push origin main
```

Expected: push succeeds, `CLAUDE.local.md` is not mentioned anywhere in the push output.

- [ ] **Step 5: Verify the public file on GitHub does not contain private sections**

Run:
```bash
gh api repos/mrjrkingston/travel-toolkit/contents/CLAUDE.md --jq '.content' | base64 -d | grep "PRE-OUTPUT GATE"
```

Expected: no output (the section is not in the pushed file).

Run:
```bash
gh api repos/mrjrkingston/travel-toolkit/contents/CLAUDE.local.md 2>&1
```

Expected: `{"message":"Not Found"...}` — the private file is not on GitHub.
