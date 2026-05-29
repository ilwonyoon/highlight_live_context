# Brief — My approach to the take-home

> A short read on *how I framed the problem and why I made the decisions I did.*
> The detailed privacy spec lives in `PRIVACY_MODEL.md`; this is the thinking on top of it.

---

## 1. The problem I chose to solve

The brief asks for a "Memory" interface — edit, curate, delete sensitive moments, flag what to keep. I could have built a clean CRUD surface over captured items. I think that misses the actual hard problem.

**Brief only gets powerful with more data. Security-conscious users won't hand that over at once.** They connect the safe minimum — calendar, email, meetings — and hold back the rest (clipboard, screen, Slack, code). So the real design challenge isn't *managing* what's already captured. It's:

> **How do you dissolve privacy concern so the user keeps expanding data permissions — and rides that into the power-user experience?**

That reframes "Memory management" into something with a business spine, which is what I chose to design for.

## 2. The core thesis — privacy is a growth flywheel, not a wall

Privacy is usually treated as a defensive feature. I treated it as the **engine** that moves a user from casual to power:

```
add a data connection
      ↓  (why would they? because it feels safe)
 1. TRUST     — the system proves, daily, that it protects you
 2. CONTROL   — you can redraw any boundary anytime, by talking
      ↓
 3. BETTER EXPERIENCE — richer context → better briefs & actions
      ↓
 grant MORE permission ──┐
      ↓                   │
 more context processed → more usage (credits) → value felt
      ↓                   │
 conversion (paid / yearly)
      └────────────────────┘ → connect the next source
```

**Trust unlocks permission → permission creates value → value drives usage → usage drives conversion.** Privacy is the *first domino* of Highlight's funnel, not an afterthought. The whole experience is designed to move the user around this loop, one connection at a time.

This also dissolves the brief's "serve casual **and** power users" requirement: they aren't two personas to satisfy separately — they're the **same person early vs. late on one trust ladder.** Casual lives on automatic protection; power has connected more and authored their own rules. The design's job is the ramp between them.

## 3. The main work — Privacy control as a conversation, not a settings panel

This is where my design decisions concentrate.

**The model (three actions, not three data categories):**
- **Silent filter** — universal secrets (API keys, passwords) dropped before storage, never mentioned (saying "I removed your key AKIA…" re-leaks it).
- **Visible filter** — personal-but-legitimate (medical, personal finance, family) auto-excluded *and the user is told* — calm reassurance, not a silent drop.
- **User control** — context-sensitive boundaries only the user/org knows ("nothing about the Falcon acquisition") — drawn as **rules**, not per-item toggles.

**The key decision: you steer it by talking, not by clicking settings.**

> "Who manually controls settings anymore? You tell the AI."

Opening "Privacy" is a **conversation**, not a control panel. It (a) **briefs you on the current state** — what's being silently dropped, what's kept private, what lines you've drawn — making an invisible model legible without a dashboard; and (b) **turns a wish into a rule** — you describe a boundary in plain language, the assistant authors the rule and confirms. No categories to pick, no regex, no toggles.

A conventional manual settings screen still exists as a fallback for people who want to drive by hand — and both paths edit the same rule set. But the conversation is the primary surface, because describing a boundary is faster than building one, and because it's the move that actually *builds trust* (and trust is what unlocks the next permission).

**Why this raises the business metric:** every time the system proves it protects you and lets you change the line effortlessly, the cost of granting the next connection drops. More connections → richer context → better product → more usage → conversion. The privacy UX *is* the conversion mechanism.

## 4. Visual craft & interaction (the craft proof)

Run in parallel with the thesis, concentrated where it shows:
- **Readability of the document surface** — Brief reads like a document, not a dashboard. A real type system (Klim Söhne workhorse + Family serif for the single hero title + Söhne Mono for metadata), a warm-paper foundation, markdown-semantic hierarchy, and a capped reading column so prose stays legible on any width.
- **Interaction** — inline source provenance with hover-preview popovers; drag-to-select lines → summon the assistant on a selection; the "wish → rule → confirmation" privacy micro-interaction. Motion is restrained: appearance animates, dismissal is instant.
- **macOS-native** — real Liquid Glass sidebar, standard window chrome, brand color reserved for meaning (AI-marked content), never decoration.

The craft isn't decoration; it's what makes a privacy/trust product feel trustworthy.

## 5. Scope & priorities (deliberate trade-offs)

- **P0 — Privacy control (the hero).** Conversational privacy control + the trust→permission→conversion loop. This is where the design effort and the argument live.
- **Craft (parallel).** Visual polish + interaction model, proving the bar on "feels like a product you'd use every day."
- **P2 — Proactive brief (time-permitting).** The morning/evening briefing + action-taking is the *reward* at the top of the ladder. It's the natural next surface, scoped down here so the hero stays sharp — shown as direction, not built to full fidelity.

The trade-off I'm making explicit: I'm **not** centering this on a deletion/hygiene dashboard. Treating privacy as control-panel hygiene produces a defensive product nobody opens twice. Treating it as the trust engine that expands permission produces a product that compounds — and answers the brief's "complexity without complexity" by keeping complexity in the model and the UI a sentence.

## 6. What I'd build next

The org/team layer: today the rules are personal; the same model extends to an org drawing hard lines once (confidential clients, comp channels, data-room domains) with individuals getting lightweight personal control within those guardrails. That's the "for Teams" destination — out of scope for two days, but the architecture already points at it.
