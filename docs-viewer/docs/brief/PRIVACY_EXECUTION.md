# AI Chat Panel — execution plan

> **What this doc is.** The build plan for the **right-side AI chat panel** — a
> *general* conversational control surface — and the thin **bridge** that lets any
> domain (privacy first) plug into it. Privacy's policy/data live in
> `PRIVACY_MODEL.md`; this doc owns the **chat panel and the contract**, not the
> privacy internals.
>
> **Why the split matters (the whole point of this rewrite).** Three things that
> look like "privacy" are actually three different layers with three different
> owners. The chat panel must not know what privacy *is* — it talks to a
> `PanelScenario` protocol, and privacy is merely the first scenario that
> implements it. This keeps the chat work and the privacy work **independent**:
> two people (two terminals) can build them in parallel, meeting only at the
> protocol.
>
> **Status.** Planning only — no code written from this doc directly. Swift
> snippets show *interfaces and signatures* (the contract both sides agree on);
> view bodies stay as prose + wireframes.

---

## 1. Three layers, three owners

The single most important diagram in this doc. "Privacy" is not one thing:

```
┌──────────────────────────────────────────────────────────────────┐
│  ① LIVE CONTEXT  — the home screen (already built / others own it) │
│     · sidebar item "Privacy", header "Privacy" row                  │
│     · the ENTRY POINT (tap → open the panel)                       │
│     · DISPLAYS the resulting count ("· 1 filter")                  │
│     owns: LiveContextView, ContextSummaryBar                       │
├──────────────────────────────────────────────────────────────────┤
│  ② DOMAIN  — privacy data + logic (other terminal owns it)         │
│     · PrivacyState, AutoItem, PrivacyRule, scan, counts            │
│     · pure model — knows NOTHING about chat UI                     │
│     owns: PrivacyState.swift (+ its scenario adapter, §5)          │
├──────────────────────────────────────────────────────────────────┤
│  ③ CHAT PANEL  — the general conversational shell (THIS doc/work)   │
│     · header(topic+back) · nav stack · thread · composer          │
│     · knows NOTHING about privacy — talks to a protocol           │
│     owns: PanelRoute, PanelMessage, PanelComposer, the host       │
└──────────────────────────────────────────────────────────────────┘

        ③ Chat Panel  ──── PanelScenario protocol ────  ② Domain
            (grail)            (the only contact)        (filling)
              ↑                                              │
              │ presented over / returns count to           │
              └──────────────  ① Live Context  ←────────────┘
```

- **① Live Context** *is* the Brief home surface. Privacy appears here as a nav
  item and a header row — but that's just an **entry point** and a **readout**.
  It opens the panel and later shows the count. Mostly already built; we touch it
  minimally (§6).
- **② Domain (privacy)** is **not** Live Context and **not** chat. It's a pure
  model — `PrivacyState` doesn't import a single view. Live Context merely *uses*
  it; the chat panel never sees it directly. The other terminal is actively
  growing this (it just added `autoScreeningOn` / `userFiltersConfigured`).
- **③ Chat panel** is **not** Live Context either. It's a general vessel that
  floats *over* the home surface. It hosts privacy today, memory/connections
  later — because it only ever talks to the **`PanelScenario`** contract (§3).

> **Ilwon's mental model, made literal:** "챗에서 설정도 건드릴 수 있게 — raw
> memory & connected apps도 되지만 이런 연결고리 관점에서 설정도 관리." → The
> chat panel (③) is the one surface for steering every "connection" by talking;
> privacy (②) is the first domain to plug in; memory/connections plug into the
> *same* vessel later by implementing the same protocol; Live Context (①) is the
> home that shows them all and provides the doors.

**Division of labor (so the two terminals don't collide):**

| Layer | Owner | This doc's job |
|---|---|---|
| ① Live Context (entry + readout) | existing / others | specify the *minimal* hooks (§6) |
| ② Privacy domain | other terminal | specify only the **contract** it must satisfy (§5) — not its internals |
| ③ Chat panel + bridge | **this work** | full build (§2–§4, §6–§7) |

---

## 2. The bridge — `PanelScenario` (the only contact point)

This is the contract. The chat panel renders and drives a conversation **without
knowing the domain**. A domain (privacy) plugs in by implementing this. Get this
right and the two sides never touch again.

```swift
// New — PanelScenario.swift  (lives with the chat panel; the contract both sides import)

/// A unit of rich content the assistant can "speak" without the chat panel
/// knowing its type. The domain supplies the view; the panel just hosts it.
/// (Kept deliberately opaque so chat never imports a domain type.)
protocol PanelCard {
    associatedtype Body: View
    @ViewBuilder @MainActor func makeBody() -> Body
}

/// An action the user can confirm from a card (e.g. "Keep it out"). Opaque to
/// the panel — it just hands the chosen action back to the scenario.
protocol PanelAction {}

/// One turn in the thread. `.text` and `.card` are all the panel understands;
/// the card's contents are the domain's business.
enum PanelTurn {
    case userText(String)
    case assistantText(String)
    case assistantThinking(String)        // shimmered label while the scenario works
    case assistantCard(any PanelCard)     // domain-rendered rich content
}

/// What the chat panel asks of ANY domain. Privacy is the first impl (§5);
/// memory/connections are future impls. The panel calls these; it never reaches
/// into the domain's state.
@MainActor
protocol PanelScenario {
    /// The conversation's title (shown in the header). "Privacy", "Memory", …
    var title: String { get }

    /// The proactive opening — turns the assistant has "already" prepared on entry
    /// (e.g. the privacy brief). Rendered before the user types anything.
    func openingTurns() -> [PanelTurn]

    /// The user said something. The scenario interprets it and returns the
    /// assistant's response turns (which may include a "thinking" turn followed by
    /// a card). Async so a scenario can mock latency / actually scan.
    func respond(to userText: String) async -> [PanelTurn]

    /// The user confirmed an action surfaced in a card. The scenario applies it
    /// (e.g. creates a rule, mutates its own state) and returns follow-up turns.
    func confirm(_ action: any PanelAction) async -> [PanelTurn]

    /// Optional drill-in destinations the scenario offers (e.g. "Automatic",
    /// "Your rules"). The panel renders these as pushable detail screens; their
    /// bodies are scenario-supplied cards.
    func detailDestinations() -> [PanelDestination]
}

struct PanelDestination: Identifiable {
    let id = UUID()
    let title: String
    let card: any PanelCard
}
```

**What this buys us:**

- The chat panel imports **zero** privacy types. `PrivacyRule`, `ScanFindings`,
  `PrivacyState` never appear in panel code.
- The privacy terminal imports **zero** chat types beyond this one file. It builds
  `PrivacyScenario: PanelScenario` against the protocol and is done.
- Swapping/adding domains is "write another `PanelScenario`." The vessel is
  untouched.

> **Simplicity check (Karpathy rule #2).** A protocol is only justified because
> Ilwon explicitly wants *multiple* domains (privacy now, memory/connections
> later) on this surface. For a one-off it'd be over-engineering; here it's the
> correct abstraction for a stated future. The protocol is small — four methods —
> and each maps to a concrete moment in the flow.

---

## 3. The chat panel — what to build (privacy-free)

Everything in §3 is general. It compiles and runs against a *mock* scenario with
**no privacy code present** (that's the proof the layering is real, §7 step 0).

### 3.0 What already exists (reuse)

Verified against the codebase 2026-05-29:

| Capability | File | Reuse |
|---|---|---|
| Slide-in mechanism (off right edge → in) + scrim; in-window variant | `PrivacyPanel.swift` → `PrivacySlideOver`; `PrivacyWindowController.swift` | Host mechanics reused; the *content* gets rebuilt as the general panel. |
| **Chat primitives** | `BriefChatKit.swift` | `StreamingText` (word-by-word), `BriefShimmer` ("thinking"), `BriefPressStyle`. Exactly the turn-rendering kit. |
| Block-selection mini composer (pattern reference only) | `ChatComposer.swift` | Anatomy reference for `PanelComposer`; not reused directly (it's selection-bound). |
| Tokens | `BriefLayout/Radius/Color/Motion` | `BriefSpacing.xs…xxl`, `BriefRadius.chip/card/panel`, `BriefLayout.Composer`, `.briefHover/.briefStandard`. Confirmed present. |

> Note: today `PrivacyPanel` content is privacy-specific (it builds bucket cards
> directly). Under this plan that content **moves into the privacy scenario** (§5);
> the panel becomes generic. The *slide-over host* (`PrivacySlideOver`) is the
> reusable part — likely renamed `ChatPanelSlideOver`.

### 3.1 Navigation — header topic + back, a real route stack

The panel is a navigation stack (decision ①A). Routes are panel-generic; detail
*titles* come from the scenario, not hardcoded.

```swift
// New — PanelRoute.swift
enum PanelRoute: Equatable {
    case conversation                 // root: opening turns + thread + composer
    case detail(destinationID: UUID)  // a scenario-supplied drill-in (title/card from PanelDestination)
}

@State private var stack: [PanelRoute] = [.conversation]
private var canGoBack: Bool { stack.count > 1 }
private func push(_ r: PanelRoute) { stack.append(r) }
private func pop() { if stack.count > 1 { stack.removeLast() } }
```

**Header** (replaces the current static "Privacy" header):

```
┌─────────────────────────────────────────────┐
│  ‹  Privacy                              ✕   │  root: back hidden, ✕ closes panel
└─────────────────────────────────────────────┘   (title = scenario.title)
┌─────────────────────────────────────────────┐
│  ‹  Automatic                            ✕   │  pushed: ‹ pops, ✕ still closes
└─────────────────────────────────────────────┘   (title = destination.title)
```

- **Left:** `chevron.left` back, shown only when `canGoBack`; pops. At root,
  hidden (a quiet identity glyph optional).
- **Title:** root → `scenario.title`; detail → the pushed `PanelDestination.title`.
  Panel-title serif (`.briefStyle(.panelTitle)`).
- **Right:** the existing dismiss button, re-glyphed to an unambiguous **close**
  (`xmark`, not `chevron.right`) — it slides the whole panel out regardless of
  depth. *(Fixes the "header is wrong" gap.)*
- **Transition:** push/pop = horizontal move within `.briefStandard`. The panel's
  own in/out slide is unchanged (§4.1).

### 3.2 The conversation thread — turns

Root route is a scrolling thread (decision ②A — everything is the stream),
rendered from `[PanelTurn]` using the existing kit. The panel keeps the
*displayed* turns; the scenario *produces* them.

```swift
// Panel-local display state (the host owns this; not in any domain)
@State private var turns: [PanelTurn] = []      // seeded from scenario.openingTurns()
@State private var draft: String = ""
@State private var isThinking: Bool = false
```

**Rendering rules:**
- `.assistantText` → `StreamingText` on first show, then `animated:false` (no
  re-stream on scroll). Cadence already tuned.
- `.assistantThinking(label)` → `Text(label).briefShimmer()` — shimmer the line,
  not a skeleton box.
- `.assistantCard(card)` → `AnyView(card.makeBody())` in an assistant-aligned
  container. The panel does **not** know what's inside.
- `.userText` → right-aligned quiet bubble, no streaming.
- Layout: `LazyVStack`, gap `BriefSpacing.xl`, inside the existing ScrollView.

### 3.3 The composer — the missing input

A fixed composer pinned to the bottom (the missing field). Borrows `ChatComposer`'s
anatomy minus the context chip / copy action.

```swift
// New — PanelComposer.swift
struct PanelComposer: View {
    @Binding var draft: String
    var placeholder: String                 // scenario-flavored: "Tell me what to keep private…"
    var isThinking: Bool
    var onSend: (String) -> Void
    // ┌───────────────────────────────────────────────┐
    // │  Tell me what to keep private…           [ ↑ ] │
    // └───────────────────────────────────────────────┘
    // • TextField .plain, .briefStyle(.body), submit on Enter
    // • Trailing send (InputIconButton "arrow.up", filled) appears when !draft.isEmpty
    // • Focus ring: briefHighlight wash (as ChatComposer); pinned; hairline top divider
}
```

- **Send** appends `.userText`, flips `isThinking = true`, then awaits
  `scenario.respond(to:)` and appends the returned turns. Disabled while thinking.
- `placeholder` is supplied by the panel host from the scenario (a small extra on
  the protocol if wanted, or a default).

**Assembled panel:**

```
┌─────────────────────────────────────────────┐
│  ‹  Privacy                              ✕   │  header §3.1
├─────────────────────────────────────────────┤
│   [ assistant: "Here's how I'm protecting…"] │  thread §3.2
│   [ ▢ scenario card (e.g. buckets)      › ]  │   (card contents = scenario's)
│   [ user: "keep Acorn out" ]                 │
│   [ assistant: scanning… ▒▒▒ ]               │
│            ⋮                                  │
├─────────────────────────────────────────────┤
│  Tell me what to keep private…       [ ↑ ]   │  composer §3.3 — pinned
└─────────────────────────────────────────────┘
```

---

## 4. Driving the conversation — the panel's loop

How the panel host wires §3 together, still privacy-free:

```
on open:
    turns = scenario.openingTurns()          // proactive brief appears

on send(text):
    turns += [.userText(text)]
    isThinking = true
    let reply = await scenario.respond(to: text)   // may include .assistantThinking then a card
    turns += reply
    isThinking = false

on confirm(action) (from a card's CTA):
    let follow = await scenario.confirm(action)
    turns += follow

on tap a destination chevron:
    push(.detail(destinationID: dest.id))     // renders dest.card; back pops
```

The panel never branches on *what* the text means or *what* the card is — it
delegates to the scenario and renders whatever turns come back. That indifference
is the design.

---

## 5. The privacy scenario — the contract, fulfilled (other terminal's work)

This section is **specification, not implementation** — it tells the privacy
terminal exactly what to build so it drops into the panel. The privacy domain
types (`PrivacyState`, `PrivacyRule`, scan, etc.) stay entirely on that side.

`PrivacyScenario` implements `PanelScenario`:

```swift
// Other terminal — PrivacyScenario.swift (privacy side; imports PanelScenario.swift)
@MainActor
struct PrivacyScenario: PanelScenario {
    let store: PrivacyStore             // the shared privacy state (§ below)

    var title: String { "Privacy" }

    func openingTurns() -> [PanelTurn] {
        [ .assistantText("Here's how I'm protecting you right now. …"),
          .assistantCard(BucketsCard(state: store.state)) ]   // reuses PrivacyBucketCard
    }

    func respond(to userText: String) async -> [PanelTurn] {
        // 1. echo a thinking turn, 2. mock-scan store for matches, 3. return a
        //    proposal card with findings + a confirmable action.
        [ .assistantThinking("Looking through what I've captured…"),
          .assistantCard(ScanProposalCard(findings: scan(userText),
                                          onConfirm: /* yields a PanelAction */)) ]
    }

    func confirm(_ action: any PanelAction) async -> [PanelTurn] {
        // apply: store.add(rule)  → returns confirmation + the materialized rule card
        [ .assistantText("Done — I'll keep anything about … out. …"),
          .assistantCard(RuleCreatedCard(rule: newRule)) ]
    }

    func detailDestinations() -> [PanelDestination] {
        [ PanelDestination(title: "Automatic", card: AutomaticDetailCard(state: store.state)),
          PanelDestination(title: "Your rules", card: RulesDetailCard(state: store.state)) ]
    }
}
```

**The user-visible flow this produces** (the ★ micro-interaction — decision ③A,
full spec; copy is privacy's, but recorded here so the demo is concrete):

1. **Proactive brief** (`openingTurns`): the opening line + the two bucket cards
   (`🛡 Automatic 7 today ›`, `✋ Your rules 2 rules ›`). Tapping a `›` pushes that
   detail. This is the "explain what automatic screening does, and invite you to
   add your own" moment Ilwon described.
2. **Wish** (user): "Don't keep anything about the Falcon acquisition."
3. **Scan** (`respond` → thinking): shimmering "Looking through what I've
   captured…" with mock latency — sells that the AI actually reviews context.
4. **Proposal** (`respond` → card): "I found 3 things that mention Falcon: …
   [Not now] [Keep it out]". Surfacing findings before acting proves it *can tell*
   and keeps the protection falsifiable (the Recall honesty lesson,
   `PRIVACY_MODEL.md`).
5. **Confirm** (`confirm`): `store.add(rule)`; assistant confirms; the new rule
   **materializes with the `justAdded` glow** (already in `PrivacyBucketCard`),
   then settles — "the rule appears and the item retreats."

> The chat panel sees none of this. It sent text, got `[thinking, card]` back,
> rendered them; the user tapped a CTA, it called `confirm`, rendered the result.

**Shared privacy state (privacy side owns; ① reads it):**

```swift
// Other terminal — PrivacyStore.swift
@Observable final class PrivacyStore { var state: PrivacyState = .mock }
```

This is the **one** object that bridges to layer ① for the readout: both the
privacy scenario (writes via `add`) and `ContextSummaryBar` (reads the count)
observe it. `PrivacyState` already has `userFiltersConfigured` + `adding(_:)`
(the other terminal just added the flags) — so the count plumbing is mostly there.

### Contract checklist for the privacy terminal

To plug into the panel, that side provides:
- [ ] `PrivacyScenario: PanelScenario` (the four methods above).
- [ ] Cards conforming to `PanelCard`: `BucketsCard`, `ScanProposalCard`,
      `RuleCreatedCard`, `AutomaticDetailCard`, `RulesDetailCard`
      (most wrap the existing `PrivacyBucketCard` layouts).
- [ ] A `PanelAction` value for "keep it out" carrying the proposed rule.
- [ ] `PrivacyStore` (`@Observable`) as the shared state for the ① readout.
- [ ] The mock scan: keyword → findings (min: Falcon/Acorn from the planted data).

Nothing on this list touches chat-panel code. Nothing on the chat side touches
this list. **That's the clean seam.**

---

## 6. Layer ① hooks — Live Context (minimal, others' code)

The home surface needs three small wires (kept tiny on purpose):

| File | Change |
|---|---|
| `LiveContextView.swift` | Owns/holds the `PrivacyScenario` (built from the shared `PrivacyStore`); presents the **general chat panel** with that scenario when the Privacy row/nav is tapped. Keep `showPrivacy` as the single trigger. |
| `ContextSummaryBar.swift` | Take the shared `PrivacyStore` instead of reading `PrivacyState.mock` statically (`ContextSummaryBar.swift:24`); its existing `userFiltersConfigured` branch then shows the live count after a rule is added. Point `onOpenPrivacy` at the slide-over trigger (retire the `NSPanel` toggle as primary — see below). |

**Entry-point conflict to resolve:** privacy is presented two ways today —
`LiveContextView` uses `.privacySlideOver`, `ContextSummaryBar` calls
`PrivacyWindowController.shared.toggle()`. **Standardize on the in-window
slide-over** (it reads as a focused, dismissable surface *within* the window —
the panel's own header comment argues this). One-line change at the
`ContextSummaryBar` call site; the `NSPanel` controller stays as an alternate but
isn't primary. (Either host works — both present the same general panel — so this
is just blessing one.)

---

## 7. Build order — chat panel stands alone first

The ordering proves the layering: the chat panel is built and verified against a
**mock scenario with no privacy code**, then privacy plugs in.

0. **Bridge + mock scenario.** Write `PanelScenario.swift` (the protocol) and a
   throwaway `EchoScenario` (opening = one line; `respond` = echoes; one dummy
   card + destination).
   → *Verify:* nothing privacy-related imported anywhere in the panel.

1. **Panel shell + header (route-driven).** `PanelRoute` + `stack`; header shows
   `scenario.title` / destination title, `chevron.left` back when `canGoBack`,
   `xmark` close.
   → *Verify:* push a dummy destination, title changes, back pops, close slides
   the panel out.

2. **Composer.** `PanelComposer` pinned under the thread; `onSend` appends a
   `.userText` turn and clears.
   → *Verify:* type + Enter → right-aligned user turn appears.

3. **Thread + loop.** Render `[PanelTurn]` (StreamingText / shimmer / card host);
   wire the §4 loop to the mock scenario (`openingTurns`, `respond`, `confirm`).
   → *Verify:* opening line streams; echo replies stream; a `.assistantThinking`
   turn shimmers; the dummy card renders; scrolling doesn't re-stream.

4. **Detail push.** `detailDestinations()` → pushable detail screens hosting the
   destination card; back returns with the thread intact.
   → *Verify:* tapping a card's `›` pushes a titled detail; back works.

   *— At this point the chat panel is DONE and demoable with zero privacy code. —*

5. **Privacy plugs in.** (Coordinates with the other terminal.) Swap `EchoScenario`
   for `PrivacyScenario`; render real bucket / scan / rule cards.
   → *Verify:* the full ★ flow — brief → wish → scan → proposal → Keep it out →
   rule materializes (glow→settle) — runs end to end.

6. **Layer ① readout.** Shared `PrivacyStore` into `ContextSummaryBar`; confirm
   flips `userFiltersConfigured`; the Privacy row shows `Auto-screening on · 1
   filter`.
   → *Verify:* closing the panel after step 5 shows the count on the home surface;
   reopening preserves the rule.

7. **Entry-point cleanup.** Privacy row → the slide-over (one consistent door).
   → *Verify:* `Add your filters →` opens the general panel, seeded with the
   privacy scenario's brief.

> Steps 0–4 are entirely **this** terminal and need nothing from privacy. Step 5
> is the handshake. Steps 6–7 are small wires into the already-built home surface.

---

## Open questions (flag before building)

- **Card opacity in the protocol:** `any PanelCard` (a view-producing protocol,
  shown above) vs. a simpler `AnyView`-returning closure? Protocol is cleaner for
  the scenario; `AnyView` is fewer moving parts. Default: protocol.
- **Presentation host:** in-window slide-over (recommended, §6) vs. screen-edge
  `NSPanel`? Both host the identical panel; just bless one.
- **Placeholder on the protocol?** Add `var composerPlaceholder: String` to
  `PanelScenario`, or keep a panel default and let scenarios ignore it? Minor.
- **Scan breadth (privacy side):** how many keyword→finding mappings? Min two
  (Falcon/Acorn); more = a more convincing scan, more mock data.
