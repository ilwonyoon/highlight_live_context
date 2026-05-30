# Live Context — screen gallery

Screenshots of the running macOS prototype (SwiftUI, our design system, Dani's data). For reviewing detail on a phone. Tap an image to zoom.

## The Brief — full view

An action-oriented document, generated from a Track/MeaningUnit model: the goal organizes everything, tracks are classified by the user's intent (**Priority · ranked by you / In motion / Concluded**), and every live track is *did → next* with a prominent **Next step**. Inline provenance marks where each fact was woven from; sources read as part of the prose (the hairline underline is the affordance).

![The Brief — full view](/shots/live-context-full.png)

## Header — Connected & Privacy

The data-governance block, as Notion-style property rows. **Connected** (top of the funnel — where the data comes from) sits above **Privacy** (control over it). Source apps are white rounded chips; the trailing **＋** manages connections. Privacy says two things at once: automatic screening is always on (the calm default), and the user's own filters aren't set up yet — an active invitation to take more control.

![Header — Connected & Privacy rows](/shots/header-connected-privacy.png)

---

## AI Chat Panel — states (work in progress)

The right-side **AI chat panel** is a *general* conversational control surface — header (topic + back), a streamed message thread, hosted domain cards, and a pinned composer. It knows nothing about any domain; a domain (privacy first, memory/connections later) plugs in through a `PanelScenario` bridge. See [Privacy execution](/brief/PRIVACY_EXECUTION) for the architecture.

These shots use a throwaway **Echo** scenario (no privacy code) to verify the panel's foundation in isolation — proof the layering holds before privacy plugs in.

### 1 · Opening — proactive turns, a hosted card, a drill-in row

The scenario's opening turns: a streamed assistant line, a rich card the panel hosts without knowing its type, and a pushable "Details ›" row. A pinned composer waits at the bottom.

![Chat panel — opening](/shots/chat-1-opening.png)

### 2 · A user turn + the echoed reply

Send a line → it appears as a right-aligned bubble; the assistant's reply streams in word-by-word (the chat-kit `StreamingText`).

![Chat panel — user turn and reply](/shots/chat-2-reply.png)

### 3 · The "thinking" shimmer

While the scenario works, a shimmered label (not a skeleton box) — `BriefShimmer` swept across the line.

![Chat panel — thinking shimmer](/shots/chat-3-thinking.png)

### 4 · A card with a confirm CTA

A card can expose one confirmable action (`primaryAction`); the panel renders the dark CTA below it and routes the tap back to the scenario's `confirm(_:)`. (In privacy this becomes "Keep it out" → a rule is created.)

![Chat panel — confirm CTA](/shots/chat-4-cta.png)

### 5 · Confirmed

After the CTA, the scenario's follow-up turn lands in the thread.

![Chat panel — confirmed](/shots/chat-5-confirmed.png)

---

_Provenance is always-on inline citation; the day-switcher (▾) jumps to another day's context. Privacy opens the slide-in protection panel._
