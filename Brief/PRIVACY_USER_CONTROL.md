# Privacy — user-controlled filters (manual control surface)

> **What this doc is.** The design of the **filter control surface** — the menu
> where a user sees and manages what Highlight keeps out of their context — and
> the data model behind it. This is the thing the AI chat panel *edits by talking*;
> it has to be designed precisely first, or the chat has nothing concrete to drive.
>
> **Where it lives (layers, per `PRIVACY_EXECUTION.md`).** That doc owns the
> chat-panel *vessel* and the `PanelScenario` contract; the privacy *internals*
> (data + cards) are the domain's. **This doc owns those internals** — the filter
> model (layer ②) and the *content* of the privacy cards the panel hosts
> (`RulesDetailCard`, `AutomaticDetailCard`, `RuleCreatedCard`, `ScanProposalCard`).
> The container is theirs; the contents are here. No overlap.
>
> **Status.** Design only — no code. Other terminals are building the chat panel
> and growing `PrivacyState`; this doc must not touch their files.

---

## 1. Principles

**P1 — Automatic and user filters are the same model; only `editable` differs.**
A filter is `{ what to keep out, for how long }`. The service ships some by
default (automatic); the user declares the rest. They are *not* different kinds of
object — same shape, same card, same menu. The only difference: automatic filters
are **read-only** (the system owns them), user filters are **editable**.

| | Automatic | User-controlled |
|---|---|---|
| Authored by | the service (shipped) | the user (declared, often via chat) |
| Duration | always `permanent` ("never keep this") | the user picks (permanent / N days) |
| In the menu | **same card** | **same card** |
| Editable? | ✕ (read-only — transparency, not control) | ✓ (edit tags, duration, delete) |
| Filtered count | **shown** | **shown** |

**P2 — Show automatic too, even though it's read-only.** Highlight today only
*describes* automatic screening in prose. We render it as cards in the same menu
(read-only). Why: usability and trust. The user can finally *see* "the system
already blocks API keys, health, finance" — which both reassures and naturally
invites them to add their own. (Per `PRIVACY_MODEL.md`, the engine stays one
thing; this is just making it visible.)

**P3 — Filters are global (broad), not per-connector.** Setting a rule per source
(Slack, Gmail, …) is too fiddly — nobody would do it. A user filters by the *kind*
of information ("anything about my family"), and it applies **wherever it comes
from**. Scope is implicitly "everywhere." This keeps a filter to two decisions:
**what** and **for how long**.

**P4 — Trust = the filtered count.** A list of filters that just *says* it filters
isn't trustworthy. Each filter shows **how many times it actually caught
something** (the antivirus / "threats blocked this week" model). The count is the
proof the protection works — and it's why automatic gets a count too. Counts are
aggregate only — never the blocked content itself (the Recall lesson:
`PRIVACY_MODEL.md`).

**P5 — Natural language is the record; tags are the executable unit.** The user
speaks a wish ("keep my family stuff out"); that sentence is kept as the filter's
*statement* (the human intent). The AI extracts **tags** from it (`family`,
`personal life`) — the keyword chips the system actually screens on. The AI can
get this wrong, so every user tag is **removable (✕)** and the user can **add (＋)**
ones the AI missed. Intent (human) + execution (machine) + correction (human).

**P6 — One request = one filter; split compound asks.** A user often says several
things at once ("block health and family, and keep salary for 30 days"). The AI
**splits the utterance into intent units** — one filter card each — because each
may want a different duration. A card is always one coherent request.

**P7 — Same card, two contexts.** The filter card appears both **inline in the
chat thread** (just-created: `RuleCreatedCard`) and **in the manage list**
(`RulesDetailCard`). One component, two places. Chat = *create*; the list =
*manage / correct / verify counts*.

---

## 2. Litmus tests

- **Falsifiability:** does each filter show a count, so the user can tell it's
  actually working (not just declared)?
- **Correctability:** can the user fix a wrong AI tag without re-typing the whole
  request (remove a chip, add a chip)?
- **Parity:** is an automatic card visually/structurally identical to a user card,
  minus the edit affordances? (If you'd build two different views, the model is wrong.)
- **Reachability:** can the user both *talk* a filter into existence and *see/manage*
  all filters in one place, without hunting through settings?

---

## 3. Data model (layer ② — extends the privacy domain)

A single shape covers both automatic and user filters. (Naming aligned with the
existing `PrivacyState` / `PrivacyRule`; this is the shape the cards render and the
chat scenario creates.)

```
Filter {
  statement:    String          // the intent, in words.
                                 //   user:      what they said ("keep my family stuff out")
                                 //   automatic: a system-written line ("Secrets like API keys & passwords")
  tags:         [FilterTag]      // AI-extracted keyword chips — the executable screening units
  duration:     .permanent       // never keep (all automatic; the strongest user choice)
              | .days(Int)        // keep now, auto-forget later (user only)
  filteredCount: Int             // how many times this filter has caught something (P4)
  editable:     Bool             // ★ the only automatic/user difference. user=true, automatic=false
  active:       Bool             // user can pause without deleting (automatic always true)
}

FilterTag {
  label:        String           // "family", "health", "salary"
  count:        Int              // times THIS tag caught something (chip-level proof)
  // removable in the UI iff the parent Filter is editable
}
```

Notes:
- **Scope is not a field** (P3 — always global). If we ever need per-source, it's an
  additive option, not the default.
- `editable` is the hinge of the whole design (P1). Flipping it is how a future
  "raise the safety level" feature would promote/demote a filter — no new types.
- This extends, doesn't replace, today's `PrivacyRule { what, scopeLabel, retention }`.
  `what`→`statement`, `retention`→`duration`, plus `tags`/`filteredCount`/`editable`.
  The other terminal owns the actual type; this is the target shape.

---

## 4. The filter card — anatomy

The atom of the whole surface. Same in both contexts (P7); edit affordances appear
only when `editable`.

```
┌─────────────────────────────────────────────────────────┐
│  Keep my family & personal life out          12 filtered │  ← statement (the wish) · count (P4)
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌───┐            │
│  │ family 5 ✕│ │ health 4 ✕│ │ home 3 ✕ │ │ ＋ │           │  ← AI tags as chips; ✕ removes, ＋ adds (P5)
│  └──────────┘ └──────────┘ └──────────┘ └───┘            │
│  Never kept ▾                                      ⋯      │  ← duration control · overflow (delete/pause)
└─────────────────────────────────────────────────────────┘
```

- **Statement** (lead): the natural-language intent. For user filters it's *their*
  words; editable inline. For automatic it's a calm system line.
- **Filtered count** (trailing): "12 filtered" — the trust signal. Tappable later to
  see *when/where* (aggregate timeline), never *what*.
- **Tag chips**: each `label + count` ("family 5"). The count makes each chip
  falsifiable. On editable cards each chip carries an **✕**; a trailing **＋** adds a
  tag (type or pick). On automatic cards: **no ✕, no ＋**.
- **Duration**: `Never kept` (permanent) or `Forgets after N days`. A small menu on
  editable cards; static text on automatic (always "Never kept").
- **Overflow (⋯)** (editable only): pause (`active` off) / delete the whole filter.

**Automatic card = identical, minus affordances.** No chip ✕/＋, no duration menu,
no ⋯. Tapping an edit affordance that isn't there is impossible; tapping the card
can show a quiet note — *"Highlight manages this automatically."*

```
┌─────────────────────────────────────────────────────────┐
│  Secrets — API keys, tokens, passwords        3 filtered │  ← system statement · count
│  ┌────────┐ ┌────────┐ ┌──────────────┐                 │
│  │ api key│ │ token  │ │ password  ·2 │                 │  ← chips, NO ✕ / ＋
│  └────────┘ └────────┘ └──────────────┘                 │
│  Never kept · managed by Highlight                       │  ← read-only duration + ownership note
└─────────────────────────────────────────────────────────┘
```

---

## 5. The manage surface — list UX (right-side panel content)

This is the content of the panel's **"Your rules" / "Automatic"** drill-ins
(`RulesDetailCard` / `AutomaticDetailCard` in `PRIVACY_EXECUTION.md` §5). It is the
manual control surface: one scroll, two sections, same cards.

```
┌─ Panel (drill-in: "Filters") ───────────────────────────┐
│  ‹  Filters                                          ✕   │  panel header (PRIVACY_EXECUTION §3.1)
├──────────────────────────────────────────────────────────┤
│  YOUR FILTERS                              + Add a filter │  ← editable section · add (opens composer/chat)
│  ┌──────────────────────────────────────────────────┐    │
│  │ Keep my family & personal life out     12 filtered│    │  ← user card (§4) — chips ✕/＋, duration, ⋯
│  │ [family 5 ✕][health 4 ✕][home 3 ✕] [＋]   Never ▾  │    │
│  └──────────────────────────────────────────────────┘    │
│  ┌──────────────────────────────────────────────────┐    │
│  │ Don't keep candidate compensation       4 filtered│    │
│  │ [comp 3 ✕][salary 1 ✕] [＋]      Forgets in 30d ▾  │    │
│  └──────────────────────────────────────────────────┘    │
│                                                            │
│  AUTOMATIC  ·  managed by Highlight                        │  ← read-only section (P2)
│  ┌──────────────────────────────────────────────────┐    │
│  │ Secrets — API keys, tokens, passwords    3 filtered│    │  ← automatic card — no ✕/＋, no menu
│  │ [api key][token][password ·2]            Never kept│    │
│  └──────────────────────────────────────────────────┘    │
│  ┌──────────────────────────────────────────────────┐    │
│  │ Personal health & finance                4 filtered│    │
│  │ [health ·2][finance ·1][medical ·1]      Never kept│    │
│  └──────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────┘
```

- **Two sections, one list**: *Your filters* (editable) on top — it's where the
  user acts — then *Automatic* (read-only) below, labeled "managed by Highlight."
- **Section is the only chrome that differs**; the cards within are the same
  component with `editable` true/false.
- **+ Add a filter**: opens the composer (or jumps to chat) to declare a new one in
  words — same path the chat uses (P7), so creation is consistent.
- The whole surface lives as the panel's drill-in content; the panel supplies the
  header/back/close (PRIVACY_EXECUTION §3.1).

---

## 6. Chat ↔ manual mapping

Same filters, two ways to touch them.

| Moment | Surface | What happens |
|---|---|---|
| Declare ("keep my family stuff out") | **chat** | scenario splits the utterance (P6), creates a `Filter` per intent, extracts tags; shows a `RuleCreatedCard` inline (the §4 card) |
| Propose before acting | **chat** | `ScanProposalCard`: "I found 3 things mentioning Falcon — [Not now] [Keep it out]" (falsifiable, P4 litmus) |
| See everything | **manual list** | `RulesDetailCard` / `AutomaticDetailCard` (§5) — all active filters, both sections |
| Correct an AI tag | **manual or chat** | remove a chip (✕) / add (＋); or in chat "no, not health, just family" |
| Change duration | **manual** | the `Never kept ▾` menu on the card |
| Pause / delete | **manual** | card overflow (⋯) |
| Verify it works | **both** | the `filtered` counts (card + chip level) |

The card is the shared object: chat **creates** it (and shows it inline), the list
**manages** it. Because both render the same `Filter` via the same card, a rule
made by talking and a rule managed by hand are indistinguishable — as they should
be.

---

## 7. Dani — worked example

Grounded in the planted mock (`PrivacyState.mock`): 7 auto items + 2 user rules.

**Automatic (read-only, shown for transparency):**
- *Secrets — API keys, tokens, passwords* · `[api key][token][slack token]` · Never kept · 3 filtered
- *Personal health & finance* · `[health][finance][banking]` · Never kept · 4 filtered

**Your filters (editable):**
- *Don't keep candidate compensation* · `[comp ✕][salary ✕]` · Forgets in 30d · (from a chat wish)
- *Keep a teammate's private family situation out* · `[family ✕][personal ✕]` · Never kept

**A chat turn that lands here:** Dani says *"don't keep anything about the Falcon
acquisition."* → scenario scans, proposes ("found 3 mentions — Keep it out?"), Dani
confirms → a new editable `Filter` ("Anything about the Falcon acquisition",
tags `[falcon][acquisition]`, Never kept, 3 filtered) materializes inline (glow→settle,
`PrivacyBucketCard.justAdded`) and now appears in *Your filters*.

---

## 8. Extensibility (why the one-model design pays off)

Because automatic and user filters are one model differing only by `editable`
(P1), raising the safety bar later is cheap and legible:

- **Promote** an automatic protection to user-tunable: flip `editable` → it gains
  chips ✕/＋ and a duration menu, no new view.
- **Harden** a user filter toward automatic strength: same toggle the other way.
- **Add a new automatic category** (the service ships more): just another
  read-only `Filter` in the Automatic section — the surface already renders it.
- A future "safety level" control is then a single axis over `editable` /
  membership, not a redesign.

This is the privacy = growth flywheel made concrete (`project_privacy_growth_flywheel`):
seeing automatic protection builds trust → the user adds their own filters
(control) → richer, safer context → more confident use.

---

## Open questions (flag before building)

- **Count source:** `filteredCount` needs a data source. Mock per-filter/per-tag
  counts (like the captured-today volume), or derive from the planted sensitive
  items? Min: static mock numbers that read as plausible.
- **Tag editing UX:** the **＋** — free-type a keyword, or pick from AI-suggested
  candidates? (Free-type is more flexible; suggestions are safer/faster.)
- **Statement editing:** is the user's natural-language line editable in place, or
  only via re-stating in chat? (In-place is more direct; chat-only is simpler.)
- **Count drill-in:** does tapping "12 filtered" show an aggregate when/where view
  (never the content)? Strong for trust, but more surface to build.
- **Automatic disclosure depth:** how many automatic categories to reveal? Too few
  feels thin; too many turns the calm read-only section into a wall.
