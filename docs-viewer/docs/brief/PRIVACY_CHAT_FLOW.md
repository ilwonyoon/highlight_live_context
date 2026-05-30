# Privacy — the chat flow (how the AI explains & edits filters)

> **What this doc is.** The **conversation design** for the privacy panel — what
> the assistant says on entry, how the user discovers what's possible without
> being flooded, and the multi-step flow that turns a spoken wish into a saved
> filter (request → scan the real data → curate the hits → choose a duration →
> confirm). It is the *verbs*: how the dialogue actually moves.
>
> **Where it sits in the four privacy docs.**
>
> | Doc | Owns | One line |
> |---|---|---|
> | `PRIVACY_MODEL.md` | policy | *why/what* — the two-axis model, the trust flywheel |
> | `PRIVACY_USER_CONTROL.md` | the filter model + the manage menu | *the nouns* — what a `Filter` is, how the settings list looks |
> | `PRIVACY_EXECUTION.md` | the chat-panel vessel + `PanelScenario` bridge | *the container* — header/thread/composer, the protocol |
> | **`PRIVACY_CHAT_FLOW.md`** (this) | the conversation that drives it all | *the verbs* — welcome, discovery, the wish→filter flow |
>
> This doc consumes the other three: it creates the `Filter` objects defined in
> `PRIVACY_USER_CONTROL.md`, renders them as the cards that doc specifies, and
> runs inside the panel + on the loop defined in `PRIVACY_EXECUTION.md`. Read
> those for the model and the shell; read this for what the assistant *does*.
>
> **Status.** Design only — no code. The chat panel shell and the `PrivacyScenario`
> stub exist; this doc specifies the flow that replaces the stub. Mock-driven by
> design (see §7 on why there's no real API).

---

## 1. The one idea

The privacy panel is a **settings menu that an assistant operates by conversation.**
The user never hunts a toggle; they say what they want kept out, and the assistant
does the mechanical work — scanning what's been captured, proposing exactly what
would be filtered, and (only on the user's say-so) creating the rule.

Two consequences shape every decision below:

1. **Don't flood on arrival.** Privacy is abstract; a wall of explanation reads as
   work. The welcome says the minimum, then lets the user *choose* what to learn
   more about (§3). Progressive disclosure, driven by the user's curiosity, not a
   manual.
2. **Nothing is applied without approval.** The assistant proposes; the user
   confirms. Every filter that gets created passes through an explicit approval
   the user taps. This is the difference between "an AI that quietly changes your
   settings" (scary) and "an AI that does the work and asks" (trustworthy).

---

## 2. The two things the user can do here

Everything in the panel reduces to two moves — and the welcome offers exactly
these as the first choice:

- **Understand what's already protected** — the automatic filters (secrets,
  personal health/finance) the service runs without being asked. Read-only, shown
  for transparency (`PRIVACY_USER_CONTROL.md` P2).
- **Add a boundary of their own** — declare, in words, something only they know is
  sensitive ("don't keep anything about candidate pay"), and let the assistant
  turn it into a filter.

These map to the two buckets the panel already shows (Automatic / Your rules) and
to the two sections of the manage list (`PRIVACY_USER_CONTROL.md` §5).

---

## 3. The welcome — say why, then offer the choice

On entry the assistant has already prepared a short opening. It must do three
things in as few words as possible: say **why this surface exists**, name **what
it can do**, and **hand the next step to the user**. Not "hello" — but not a
lecture either.

### 3.1 The opening turn (copy)

```
🛡  Manage privacy

I keep things out of your work context — automatically for the
obvious stuff, and on your word for anything else.

Want to see what I'm already filtering, or set up something new?
```

- Line 1 (title, in the header): the surface's name.
- Body: two sentences. First states the *what* (two kinds of filtering) in plain
  language. Second is the **invitation**, phrased as a question so the user
  chooses rather than reads.
- Tone: calm, first-person, short. It's a chief-of-staff saying "here's what I
  handle; tell me what else" — not a settings panel narrating itself.

### 3.2 The discovery chips (the fork)

Directly under the opening, two suggestion chips — the user picks one (or ignores
them and just types):

```
[ What are you filtering now? ]   [ Filter something new ]
```

- **Chips are first-class** in the thread (a new turn kind — §6). Tapping one is
  equivalent to the user saying it: it posts as a user turn, and the assistant
  branches.
- The user is **never trapped** in the chips — the composer is always live. They
  can skip the menu entirely and type "stop keeping anything about the Acorn deal"
  as their first message.

### 3.3 After a branch — keep offering, don't dump

Whichever branch the user takes, the assistant answers *that*, then offers the
**next** relevant chip — so understanding accrues one step at a time:

- Pick **"What are you filtering now?"** → the assistant explains the automatic
  filters (§4), then offers `[ See the full list ]` and `[ Now filter something
  of mine ]`.
- Pick **"Filter something new"** → the assistant explains *how* it works (you say
  it, I find it, you confirm) and prompts for the wish (§5).

The principle: **answer → offer the next door.** Never show step 3 before the user
has chosen to take step 2. (This is the conversational form of progressive
disclosure — `PRIVACY_MODEL.md`'s "as few user-facing concepts as possible.")

---

## 4. Branch A — "What are you filtering now?" (explain automatic)

The assistant makes the otherwise-invisible automatic engine legible, calmly.

**Assistant reply (copy):**

```
Two kinds of things, kept out without you lifting a finger:

🔒  Secrets — API keys, tokens, passwords. Dropped the moment
    they appear; never stored.
🩺  Personal life — health, personal finance, family. Kept out
    of work context, and I tell you when.

That's 7 things kept out today.
```

- Renders as an **automatic card** (read-only) from `PRIVACY_USER_CONTROL.md` §4 —
  statement + tag chips + a filtered count, **no ✕/＋, no duration menu**. Seeing
  it (not just reading prose) is the trust beat.
- The count ("7 today") is the falsifiability signal (P4) — proof it's working.
- **Next chips:** `[ See the full list ]` (pushes the manage list, §5 of
  USER_CONTROL) · `[ Now filter something of mine ]` (→ Branch B).

The subtext, never stated as a sell: *you can see I already protect the obvious
things — so trusting me with one more boundary is safe.* (The flywheel.)

---

## 5. Branch B — "Filter something new" (the wish→filter flow) ★

The core micro-interaction. A spoken wish becomes a saved filter through five
beats. Each beat is one or two turns; the user drives the gates.

```
  1. WISH        user says it (or taps a starter)
        ↓
  2. SCAN        assistant looks through real captured data
        ↓
  3. PROPOSE     "here's what I found" — the hits, each selectable
        ↓        (or: "I didn't find anything matching" — §5.5)
  4. CURATE      user keeps/drops individual hits, confirms the set
        ↓
  5. DURATION    "how long should I keep this out?" → filter created
```

### 5.1 Beat 1 — the wish

The assistant prompts; the user describes a boundary in their own words.

**Assistant (copy):** *"Tell me what you'd rather I didn't keep — in your own
words. For example, 'don't keep anything about candidate pay,' or 'forget what
people share in my 1:1s.'"*

- The two examples are **real** for Dani (comp; 1:1 disclosures — §8), so they're
  not abstract.
- The user types freely, or taps a **starter chip** seeded from their own data
  (§8): `[ Candidate pay & equity ]` `[ The Acorn deal ]`. Starters lower the
  blank-page cost without constraining.
- A compound wish ("block health and family, keep salary 30 days") is **split into
  separate filters** downstream (`PRIVACY_USER_CONTROL.md` P6) — one card per
  coherent intent, because each may want a different duration.

### 5.2 Beat 2 — the scan (this is the part that matters)

The assistant does **not** just create a rule. It says it's looking, and actually
"reads" the captured data for matches — the move that makes the protection
*specific and honest* instead of a blind toggle.

**Assistant (thinking turn, shimmered):** *"Looking through what I've captured for
anything about candidate pay…"*

- Rendered as `.assistantThinking` with the shimmer (`BriefChatKit`), held ~1.2s
  of mock latency so it reads as real work.
- **What's actually happening (the model the user is meant to infer):** the wish is
  turned into **keyword tags** (`comp`, `salary`, `equity`, `band`, `offer`), and
  those tags are matched against the captured items. This is exactly the
  `Filter { tags }` execution model in `PRIVACY_USER_CONTROL.md` P5 — the scan is
  where tags get *tested against real data* before they become a standing rule.
- In the prototype this is a **mock keyword→items lookup** over Dani's planted data
  (§8). In production it'd be a Claude call (§7) — but the *experience* is identical.

### 5.3 Beat 3 — propose (show the receipts)

The assistant returns with **what it found** — each hit shown so the user can see
exactly what would be affected. Surfacing findings *before* acting is the Recall
honesty lesson (`PRIVACY_MODEL.md` Action 2): never promise blanket filtering;
show specific, falsifiable items.

**Proposal card (copy):**

```
I found 3 things that mention candidate pay:

  ☑  Slack #hiring — "$215k base + 0.4% equity…"        · Slack
  ☑  "Comp gate — after the onsite"                      · Notion
  ☑  Calendar — "Comp discussion: founding PMM"          · Calendar

Keep all of these out from now on?

                              [ Not now ]   [ Keep it out ]
```

- This is the `ScanProposalCard` named in `PRIVACY_EXECUTION.md` §5 and
  `PRIVACY_USER_CONTROL.md` §6 — its *content* is specified here.
- Each hit is a **row with a checkbox**, defaulted **on**. The user reads what was
  caught (the kind of thing + source), never made to trust a number.
- Hits name the *thing and where*, never re-print sensitive detail in full (the
  transparency-paradox guard — re-showing it re-violates it).

### 5.4 Beat 4 — curate (the user's judgment, not the AI's)

The proposal is a **starting set, not a verdict.** The user unchecks anything that
*shouldn't* be filtered — the moment that makes this "the AI did the legwork, I
made the call" rather than "the AI decided."

```
  ☑  Slack #hiring — "$215k base + 0.4% equity…"        · Slack
  ☑  "Comp gate — after the onsite"                      · Notion
  ☐  Calendar — "Comp discussion: founding PMM"          · Calendar   ← user unchecks (keep this)
```

- Toggling a row changes nothing yet — it just shapes the set that the eventual
  filter's **tags** are validated against. (If the user drops the calendar hit, the
  assistant can narrow the tags so that *kind* of item isn't swept up — or simply
  note the exclusion; see open questions.)
- The user can also **add a tag the scan missed** here or refine in words ("also
  anything about equity grants") — feeding the same tag-set (`PRIVACY_USER_CONTROL.md`
  P5: intent + execution + correction).
- `[ Keep it out ]` is the **approval gate** — the dark CTA. Nothing is created
  until it's tapped. `[ Not now ]` drops the whole proposal, no rule made.

### 5.5 The empty result — "I didn't find anything"

Critical and easy to skip: the scan must honestly report **nothing found**, not
invent hits or silently create an empty rule.

**Assistant (copy):** *"I looked, and I'm not seeing anything about that in what
I've captured so far. I can still set it up as a standing rule — I'll keep it out
the moment it shows up. Want me to?"* → `[ Set it up anyway ]` `[ Never mind ]`

- This is the honest counterpart to the proposal: the user learns the scan is
  *real* (it can come back empty), which paradoxically builds more trust than a
  scan that always finds something.
- "Set it up anyway" creates a **forward-looking filter** (tags, no current hits) —
  it catches future matches. Skips Beat 4 (nothing to curate), goes to Beat 5.

### 5.6 Beat 5 — duration (how strongly, for how long)

Once the set is approved, the **only remaining decision** is how long the boundary
holds — the second axis of every filter (`PRIVACY_USER_CONTROL.md` §3: a filter is
`{ what, how-long }`). Asked *after* approval so the user makes one decision at a
time.

**Assistant (copy):** *"Got it. How should I handle these going forward?"*

```
[ Never keep it ]        — strongest: dropped the moment it's captured, never stored
[ Keep, then forget ▾ ]  — kept for a while, then auto-deleted   (7 days · 30 days · …)
```

- **Two choices, plainly.** "Never keep it" = the strongest stance (≈ automatic
  strength): not even stored. "Keep, then forget" = a shelf life — useful now,
  gone later — with a small duration sub-pick (default 30 days).
- This maps directly to `Retention` in the domain model (`.never` / `.days(N)`;
  `.forever` is the implicit "no filter" state). The user never sees the word
  "retention" — they answer "how long should this stay out."
- On pick → the filter is **created**: a `Filter { statement: the wish, tags,
  duration, editable: true }` (`PRIVACY_USER_CONTROL.md` §3), and the assistant
  confirms.

### 5.7 The confirmation — the filter materializes

**Assistant (copy + card):** *"Done. I'll keep candidate pay out of your work
context — across every source — and forget it after 30 days. You can change or
undo this anytime, just tell me."*

- Renders the just-created **filter card** (`RuleCreatedCard`,
  `PRIVACY_USER_CONTROL.md` §4) inline, with the `justAdded` glow → settle (the
  "rule materializes and the item retreats" beat).
- The same card now also lives in the manage list's *Your filters* section (§5 of
  USER_CONTROL) — chat **created** it, the list **manages** it (P7).
- **Next chips:** `[ Add another ]` · `[ See all my filters ]`.

---

## 6. What the flow needs from the panel (handoff to `PRIVACY_EXECUTION.md`)

This flow rides on the chat panel; here's exactly what the panel/bridge must
provide. Most exists; two things are net-new and specified here.

### 6.1 Suggestion chips — a new turn kind

The welcome fork (§3.2) and the "next door" chips (§3.3, §4, §5.7) need tappable
chips in the thread. The current `PanelTurn` has no chip case.

**Add:**
```swift
// in PanelTurn (PRIVACY_EXECUTION.md §2)
case assistantChips([PanelChip])

struct PanelChip {
    let label: String
    let action: any PanelAction   // tapping posts a user turn + drives the scenario
}
```
Tapping a chip = posting `label` as a user turn, then calling `scenario.confirm(action)`
(or `respond`) — reusing the existing loop. (`PRIVACY_EXECUTION.md` §4's loop is
unchanged; chips are just another way to produce input.)

### 6.2 A multi-step, stateful scenario

The flow is a **sequence of `confirm()` round-trips** carrying different payloads —
the loop already appends whatever each step returns. The scenario becomes a small
**state machine** holding the in-progress filter between beats:

```swift
enum PrivacyAction: PanelAction {
    case explainAutomatic                 // chip: "what are you filtering now?"
    case startNewFilter                   // chip: "filter something new"
    case scan(wish: String)               // beat 1→2
    case toggleHit(id: UUID)              // beat 4 curation
    case approveHits                       // beat 4 gate → ask duration
    case setDuration(Retention)            // beat 5 → create filter
    case setupAnyway(wish: String)         // empty-result path
}

// PrivacyScenario gains:
private var pending: DraftFilter?          // wish, tags, scanned hits + checked state
```

Each tap → `scenario.confirm(action)` → switch on the case → return the next
beat's turns (next card). The scan step is `respond()` (free-text wish) returning
`[.assistantThinking, .assistantCard(ScanProposalCard…)]`. **The single real change
is that `PrivacyScenario` must hold `pending` across steps** — it's already a
`class`, so this is additive. (Replaces today's stub that creates a rule
immediately and returns `[]` from `confirm`.)

### 6.3 Everything else already exists

- The proactive opening, thread, streaming, shimmer, `CardHost` + CTA, detail
  push, the separate input window — all built (`PRIVACY_EXECUTION.md` §3, §7).
- The filter cards' *visuals* are `PRIVACY_USER_CONTROL.md` §4's job; this flow
  just sequences them.

---

## 7. Why it's mock — and how Claude would slot in (one section, on purpose)

The scan, the keyword extraction, and the proposal copy would, in production, be a
**Claude call**: the wish goes up, Claude returns the tags + the matched items +
the natural confirmation line. The flow above is built so that swap is a single
seam — `respond()`/`confirm()` are already `async`, and the scenario already
treats findings as data.

**But the prototype is deliberately mock, and that is the correct call for this
product:**

- **The thesis is "your context doesn't leave the device."** A privacy feature
  whose first act is to ship the user's captured work data to a cloud model to
  decide what's sensitive is in tension with its own promise. Production would
  resolve this (on-device extraction, or a privacy-preserving call) — but the
  prototype shouldn't pretend that's solved.
- **The demo's value is the *experience*, not the inference.** What persuades is
  the felt flow — say it → watch it scan → see the real hits → curate → choose a
  duration → watch the filter appear. A mock reproduces that completely; a real
  API call adds latency and a privacy question without changing what the reviewer
  sees.
- **Scope.** Wiring a real model (SDK, key handling, network entitlement, prompt
  design, the on-device-vs-cloud privacy decision) is its own project. The two-day
  surface is better spent making the *whole behavior* feel finished.

So: the behavior is built to completion against mock data; the API is documented as
a one-seam future, not half-built. (If/when it's wired, the prompt would extract
tags + match items + draft the confirmation, returning the same shapes this flow
already renders.)

---

## 8. Scenario data — what's actually in Dani's context

The scan is only convincing if it returns *real* items from the planted mock.
These are the user-control candidates mined from Dani's data — content a classifier
keeps but Dani might draw a line around. (Sources cited; full data in
`Brief/Brief/Resources/Mocks/*.jsonl`.)

### Canonical (already planted, `detection:user` / `type:confidential`)

| Wish | Scan finds | Tags |
|---|---|---|
| **"Don't keep candidate pay"** | Slack `#hiring`: *"$215k base + 0.4% equity for the founding PMM"* (`slack.jsonl:12`) | `comp`, `salary`, `equity`, `band`, `offer` |
| **"Forget what people share in my 1:1s"** | 1:1 transcript: Vasudev — *"My dad's back in the hospital… wanted you to know why I might be quiet"* (`meetings.jsonl:18`) | `1:1`, `family`, `health`, `personal` (or per-source: 1:1 disclosures) |

The **comp filter is the strongest single demo** (clear hit, obvious why a
classifier can't catch it, obvious why Dani wants it). The **Vasudev 1:1 is the
most resonant** (the system respecting a confidence).

### Expansion candidates (untagged but qualifying — to make a scan return *several* hits)

| Wish | Scan finds (across sources) | Tags |
|---|---|---|
| **"The hiring pipeline"** | "Naomi (PMM) coffee chat" (`slack.jsonl:9`); "who's in the loop: you, me, sergei, sam" (`:11`); "Head of AI role" (`gmail.jsonl:11`); candidates Naomi/Wei/Marcus (`_cast.json:116-153`) | `candidate`, `interview`, `onsite`, `#hiring`, names |
| **"The Acorn / Falcon deal"** *(demo placeholder)* | a calendar invite, Slack messages, a doc tab — seeded so the canonical "Falcon" example in the other docs resolves | `falcon`, `acorn`, `acquisition`, `deal` |
| **"Unreleased launch messaging"** | the locked one-liner *"Highlight briefs you, then moves your work forward"* (`clp_d1_005`, `slk_d2_007`); positioning doc (`notion-refs.json:17-26`) | `launch`, `positioning`, `one-liner`, `embargo` |
| **"The press embargo"** | reporter Priya thread, exec quote, "access creds separately" (`gmail.jsonl:1,9`) | `embargo`, `press`, `reporter`, `quote` |

### Contrast — the automatic items (shown read-only, never user-filtered)

Used in Branch A to show "these I caught for you; the ones above only you can
decide": Slack OAuth token (`slack.jsonl:4`), Anthropic API key (`clipboard.jsonl:3`),
prod DB string (`clipboard.jsonl:5`), MyChart labs (`gmail.jsonl:2`), personal
banking behind a screenshot (`screenshot.jsonl:4`).

> **Recommended demo spine:** Dani opens the panel → "what are you filtering now?"
> → sees the automatic card (trust) → "filter something new" → taps the
> **Candidate pay** starter → scan surfaces the $215k Slack line + 2 more →
> unchecks one → "Keep it out" → "Keep, then forget · 30 days" → the filter
> materializes and lands in *Your filters*. One minute, the whole thesis.

---

## 9. Litmus (does the flow hold?)

- **Not flooded:** is the first screen ≤ 3 short lines + 2 chips, with everything
  else reachable but not shown? (§3)
- **User in control:** does every created filter pass through an explicit tap the
  user makes — never auto-applied? (§1, §5.4)
- **Honest scan:** can the scan come back **empty** and say so, rather than
  inventing hits? (§5.5)
- **Real receipts:** does the proposal show *actual* items from Dani's data, named
  by thing + source, never a bare count? (§5.3, §8)
- **Two decisions only:** does creating a filter reduce to *what* (the wish, auto-
  tagged) and *how long* (the duration) — nothing else? (§5.6)
- **One object, two surfaces:** is the filter the chat creates identical to the one
  the manage list shows? (`PRIVACY_USER_CONTROL.md` P7)

---

## Open questions (flag before building)

- **Curation → tags:** when the user unchecks a hit (§5.4), does the assistant
  *narrow the tags* (so that kind of item isn't swept up) or just record the
  exclusion? Narrowing is smarter but harder to make legible.
- **Starter chips:** seed them from Dani's actual top sensitive topics (§8), or
  keep two generic ones? Data-seeded is more magical but couples the welcome to the
  mock.
- **Scan breadth:** how many wish→hits mappings to author? Min: the comp demo + one
  empty-result example. More = a scan that feels real for more inputs.
- **Duration default:** is "Keep, then forget · 30 days" or "Never keep it" the
  safer default to pre-highlight? (Never is stronger/safer; 30 days is the gentler
  on-ramp.)
- **Compound split UX:** when one utterance becomes multiple filters (P6), are they
  proposed as a stack of cards at once, or walked one at a time? One-at-a-time is
  calmer; a stack is faster.
