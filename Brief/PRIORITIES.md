# Scope Priorities — Brief (Highlight take-home)

> Decided by Ilwon 2026-05-28. The order is the rule. Read alongside `ASSIGNMENT.md`.

## P0 — The assignment, verbatim (hero, full hi-fi)

> **Design a Desktop "Memory" interface that allows users to edit and curate their memory — Delete sensitive moments, annotate important context, or flag items as "always remember this."**

This is the hero deliverable. Full high-fidelity:
- **Memory browser** — navigate and explore captured context
- **Curation actions** — delete (sensitive moments), annotate, flag "always remember"
- **User control over privacy** — Ilwon's two mechanisms: (1) policy/retention — user says (in plain language) "don't store this kind / discard after a day or custom period," and the system follows; (2) pre-filter — secrets like API keys are caught before they ever feed the LLM. The point is **the user has control**, not a perfect classifier.
- **Works for both power users (granular control) AND casual users (peace of mind)** — assignment constraint.
- **Scales to thousands** — answered by compression (recent precise / older summarized).
- **At least one micro-interaction** — assignment requirement.

Framing (C strategy): curation is not data hygiene — it's teaching the assistant what to remember. Satisfies the control requirement without becoming a control panel (avoids the "cognitive overload" the assignment warns against).

## P1 — Proactive brief (Chief of Staff)

Morning / evening brief. The proactive surface that gives the curated memory a reason to exist. Shown enough to make the point — frames + Loom narrative; not a second full product.

## P2 — Light-user onboarding

The light user → heavy user path: surfacing value, prompting richer data connections and actions. Lighter fidelity — direction/frames/annotations, not full hi-fi.

---

## Narrative for the submission
Solved the assignment's core (P0) cleanly, then — out of genuine interest — extended into how the curated memory gets used (P1) and how a light user grows into it (P2). Extension reads as depth, not sprawl, because the order and boundaries are explicit. Evaluation cares about "complexity without complexity" and "thoughtful trade-offs," so the priority order itself is part of the answer.
