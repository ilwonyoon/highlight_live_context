# Live Context — design principles, diagnosis, redesign

The anchor for *what the Live Context document is* and *how it's generated*.
Written after studying a real Highlight Live Context output (Ilwon's own,
2026-05-29) and several rounds of getting it wrong. When work on the document
drifts back toward "a sourced summary," return here.

---

## 0. One line

> **It tells you what you did → so you know what to do next, fast — so you can
> pick up where you left off.**

The Live Context is **not** a reactive summary with citations attached. It is an
**action-oriented document**. Everything below follows from that distinction.

| Reactive summary (what we kept building) | Action-oriented (the goal) |
| --- | --- |
| "The OAuth blocker is cleared." (a status record) | "OAuth is done → now drop one edge-case line in the release notes." (the next move) |
| The source is the subject. | The **next action** is the subject; the source is backing. |
| You read it and you're done. | You read it and **resume work.** |

---

## 1. Principles

**P1 — The goal organizes the document.**
Live Context is not topic notes; it is *progress toward a goal + the next move*.
The goal organizes everything. For Dani the priority is self-evident: **launch is
#1, hiring is #2.** An item earns a place in the document because **there is an
action you took or must take** on it. No action → it drops to reference (§Concluded)
or doesn't appear.

**P2 — Every live track carries "did → next."**
State (the past) is brief; the **next step (the future) is the subject.** A track
with no next step is not "live" — it belongs in Concluded/In motion. This is the
mechanism of *pick up where you left off*: the next move is pre-stated, so resuming
is instant. → `NextStep` must be a **first-class** field in the model, not just
another bullet labelled "Next:".

**P3 — Classify by the user's intent, not the system's pipeline stage.**
Columns are not To-do / Doing / Done. They are "how much I mean it / whether it's
waiting on my decision." A track with an active interview can still rank *below* a
track the user cares about more. And the document **names the user as the author of
the ranking** ("ranked by you") — which both signals trust ("it ordered things the
way I would") and implies the edit right ("you can reorder this").

**P4 — Provenance means trust-backing + an action entry point. Never "go verify."**
- **(a) Trust.** When the weave is good, sources are rarely opened. Their *presence*
  certifies "this was woven from real capture, not hallucinated." So provenance is
  **quiet, and the sentence reads completely without it.**
- **(b) Entry point.** Opening a source means "I want to act on this thread." Rare,
  but it's the **door to the next action.** So provenance is wired to the action model.
- Therefore a citation **never replaces body text** — it sits *on* an already-complete
  noun phrase. And there are **two kinds**, shown differently:
  **captured fact** (what I heard / wove — voice, Slack, …) vs **external resource**
  (where to go look — a Notion doc, a Linear view, a PR).

**P5 — Generation is separate from representation.**
A meaning unit knows its meaning, its sources, and its next step — **not how a
citation looks.** Whether inline underline is even the right treatment is undecided,
so representation must be swappable without touching generation.

---

## 2. Litmus tests (the pass/fail bar for any redesign)

1. **Next-step test.** Does every live track answer "so what do I do?" at a glance?
2. **Source-removal test.** Delete every citation — does the prose still read perfectly?
3. **Scan test.** Is the same kind of info always in the same place, so you can sweep
   five tracks without re-reading each?

---

## 3. Diagnosis of the version we had

Scoring `MeaningUnit` / `BriefContent` / `LiveContextDocument` against the principles.

- **D1 (P1).** The goal didn't organize. §2 was split by *work topic* ("Launch
  readiness / External messaging") — topic folders, not progress-toward-launch. You
  couldn't see "what's left before launch" at a glance.
- **D2 (P2) — the big one.** The next step wasn't first-class. `MeaningUnit` had only
  `clauses` (description). "Next:" was just another bullet — structurally
  indistinguishable from status. So the document read as reactive.
- **D3 (P4).** Sources replaced body text. "the launch-blocker `HL-1042` is cleared" —
  HL-1042 *was* the prose and the citation. Fails the source-removal test. And captured
  facts and external resources used the *same* chip (the Info Map's Notion/Linear looked
  identical to a voice citation in the body).
- **D4 (P3).** The classifier's author was invisible — "Top priorities" with no signal
  that the user owns/can-change the ranking.
- **D5 (P3).** Item schema varied (some tracks Status-only, some Decision, 1–2 clauses),
  so the eye couldn't find the same field twice → no scan.
- **D6 (action chaining).** Highlight's strongest move — chaining scattered actions into
  one route ("do the Sonia review in-person to align with the Highlight SF visit") — was
  absent, though our data supports it (onsite + launch in the same week).
- **D7 (representation bug).** Generation↔representation split is good (P5 holds), but
  `BriefProseLayout` mis-places a child after a multi-line wrap → cascading
  "'re/co/nn/ect" break. A representation-layer bug.

**What the old version got right (keep):** data↔representation separation (P5);
`eventId` back-references making the weave auditable; typographic hierarchy (no color
bands or boxes).

---

## 4. Redesign

### 4.1 Model (generation)

Promote the action. Introduce `Track` (one flow toward the goal — analogous to
Highlight's per-company card); reuse the existing `Clause`/`Strand` as the *recap*.

```
Track(
  id, title,                       // "OAuth launch-blocker"
  state: .needsYou | .inMotion | .done,   // classification = the user's intent (P3)
  recap: [Clause],                 // what happened (brief, status) — sources back it
  next: NextStep?,                 // what to do (P2, first-class)
)

NextStep(
  text,                            // "drop one edge-case line in the release notes"
  owner: .you | .waitingOn(name),  // my move vs. waiting on someone
  when: String?,                   // "today", "Tue 3PM"
  entry: Strand?,                  // the action's entry point (e.g. HL-1033) — P4(b)
  chainedTo: String?,              // chain into another action (route) — fixes D6
)
```

Classification is **derived from `state`** (= action presence): `.needsYou` → top,
`.inMotion` → middle, `.done` → Concluded. Classification and action are one thing
(P1 · P3).

### 4.2 Document structure (organization)

```
Live Context — Dani Reyes
[Latest update / TL;DR]                 ← today at a glance (exists, keep)

1. PRIMARY GOAL — Public launch (Jun 9, D-12)
   goal line · value prop · owner

2. NEEDS YOU   ▸ ranked by you          ← waiting on your decision/action (.needsYou)
   per track:  title · did (recap, brief) · → next (prominent; owner/when/chain)

3. IN MOTION                            ← rolling, no action from you right now (.inMotion)

4. CONCLUDED                            ← done (.done), reference only

5. ABOUT DANI (permanent)               ← permanent context (sourced — voice)

Information Map                         ← people & resources; external links shown
                                          as a *different kind* than body citations
```

§2 carries the explicit **"ranked by you"** signal (P3).

### 4.3 Representation (showing)

- **Recap calm, next step prominent.** The next step leads the eye (a `→` marker +
  light emphasis; owner/when as parenthetical meta) so *pick up* works.
- **Two kinds of provenance:** captured fact = inline mark on a removable noun phrase;
  external resource = a link form in the Info Map ("where to go look").
- **Metadata inline in parentheses** — (Jun 9), (3PM), (HL-1033).
- Representation stays decoupled from the model (P5) — inline is not load-bearing.

### 4.4 Order of work

1. ✅ Fix the layout bug (D7) — nothing is judgeable while text cascades.
2. ✅ Redesign the model (`Track` / `NextStep`; absorb `Clause`).
3. ✅ Refill Dani's data as tracks (did → next; chain actions).
4. ✅ Renderer (recap/next split; two provenance kinds).
5. Visual tuning (then settle the type/spacing values).

### 4.5 Decisions taken (2026-05-29, with Ilwon)

- **Section names:** NEEDS YOU → **"Priority"** (kept In motion / Concluded).
- **Provenance is hover-only by default.** At rest the prose is clean — no icon, no
  underline, no raw ids. The source mark (icon + underline → popover) appears only on
  hover. `ProvenanceInline`/`ProvenanceStacked` gained a `hoverOnly` flag; `StyledProse`
  passes it. This is the strongest expression of P4 (sources certify by availability)
  and made the source-removal test pass by construction.
- **No raw identifiers in body text.** "HL-1042 / HL-1033 / HL-1051" were the *phrase*
  (D3). The phrase is now always human prose ("the Slack-Connection blocker"); the issue
  key lives only in the hover popover. A bare id on the page is a bug.
- **Track numbering restored** — "1) 2) 3)" per track (Ilwon had set this; the first
  redesign dropped it).
- **One marker family.** Recap = bullet `•`; next step = an SF Symbol arrow **Image**
  (`arrow.right`), not a font glyph "→" (which fell back to a dash when the body font
  lacked the glyph). Don't mix bullet/dash by accident.

### Still open

- Make the `→ next` step *more* visually prominent (it's the action; currently only the
  arrow + owner label set it apart). The core lever for "pick up where you left off."
- Deferred polish: confirm the type/spacing reset (#1 — likely h2 weight) and finalize
  values in the Type Editor.
