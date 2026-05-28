# Live Context — Long-Term Rollup (2026-03-24 → 2026-05-26)

> **What this is:** the compressed two-month history that sits *behind* the minute-level hot data in `*.jsonl`. Individual events from this window have been deep-archived; what survives is the trajectory — patterns, decisions, relationships, and how Dani's product thinking moved. This models how an ambient system actually scales: recent context is precise, older context is summarized. (This file = human-readable; `history-rollup.json` = structured mirror for the loader.)
>
> **Voice:** neutral system summary (third-person, objective). **Coverage:** Dani's join (~2026-03, concurrent with the Series A) through the day before the hot window. **Ground truth:** anchored to real Highlight milestones (see `_research-dossier.md`); Dani-specific content is fictional.

---

## At a glance

- **Tenure:** ~9 weeks. Joined as **Head of Product** around the **$40M Series A (2026-03-24)**, when Sergei Sorokin was named CEO and the company repositioned from personal assistant to **shared intelligence layer for the agentic age of work**.
- **Arc in one line:** arrived to "make the personal product great," left Month 1 convinced the real wedge was **proactivity + coordination, not capture** — and has spent Month 2 bending the public launch around that conviction.
- **Dominant thread:** the **Jun 9 public launch** (now D-12 in hot data). It has absorbed an increasing share of her attention since early May.

---

## 1. Product-thinking evolution (the throughline)

Dani's framing moved through three distinguishable phases:

**Phase A — "Make capture excellent" (weeks 1–3, late Mar → mid Apr).**
She joined assuming the job was polishing the personal product: better meeting notes, tighter Screen Context, faster Magic Dot. Early notes and reviews concentrated on capture quality and the Daily Summaries surface. She treated capture as the moat.

**Phase B — "Capture is table stakes" (weeks 4–6, mid Apr → early May).**
Trialing competitors (Granola, Superhuman, and especially **Littlebird**, whose ambient on-screen-context pitch is nearly identical to Highlight's) collapsed that assumption. Recurring note across this period: *everyone* now captures; the differentiator has to be what happens *after* capture. This is when her language starts shifting from "capture" to "brief" and "act."

**Phase C — "Proactivity + coordination is the wedge" (weeks 7–9, early → late May).**
Her framing converges with Sergei's public thesis ("AI you don't have to ask," "coordination bottleneck"). The internal reframe becomes load-bearing: Highlight isn't the tool that remembers, it's the one that **briefs you and moves work forward**. Every launch decision in Month 2 is filtered through this — the hero one-liner fight, the "lead with the artifact not the adjective" instinct, the insistence on verbs the product can actually back.

> Net: she resolved the company's positioning tension *for herself* before the team resolved it collectively — which is why she's the one driving the launch message in the hot window.

## 2. Decisions & accumulated ownership

**What she has come to own (de facto, over the 2 months):**
- **Launch readiness** end-to-end — the cross-functional Jun 9 launch is her primary surface.
- **External narrative / positioning** — by default, because no Founding Product Marketer is hired yet; she's been carrying it with Samantha (fractional).
- **Product voice** — repeatedly pulled in as reviewer on copy (launch page, in-product), enforcing the "brief not capture" framing.
- **Competitive strategy** — she runs the competitor trials personally rather than delegating.

**Notable decisions in the window:**
- Reprioritized the roadmap so launch-blocking Connections reliability outranks net-new features (a recurring tension with eng's desire to ship more surface area).
- Pushed to treat **honesty about limitations** as a launch asset rather than something to hide (visible "reconnect" states, known-limitations notes) — a stance that recurs in the hot data.
- Chose to **hire the launch narrative owner before launch** (Founding PMM) rather than after, accepting the recruiting load mid-crunch.

**Open / carried-forward (entering the hot window):**
- The Slack-Connection OAuth reliability question (becomes the P0 in hot data).
- The unresolved launch one-liner (resolved on Day 2 of hot data).
- The Founding PMM hire (Naomi in pipeline).

## 3. Relationships & people network

- **Sergei Sorokin (CEO, manager).** The relationship that recruited her — both ex-Discord. Highest-trust, lowest-friction. She treats his vision statements as the constitution; her Month-2 reframe is essentially her operationalizing his thesis. Light-touch management; he sets direction, she executes.
- **Parris Khachi (Head of Product Engineering, peer).** Also ex-Discord. Her primary cross-functional partner; the product↔eng seam runs through them. Healthy, direct, occasionally in tension over scope (ship-quality vs. ship-more). The OAuth decision in hot data is a normal instance of this seam working.
- **Sam Eckert (Head of Design, peer).** Tight collaboration on launch surfaces; design is frequently blocked on her words (copy/positioning), which has made the cadence between them load-bearing.
- **Samantha Taube (fractional brand/launch).** Her current messaging partner; both understand this is a stopgap until the founding marketer lands.
- **Sarah Wu (ops).** Runs recruiting logistics and launch ops; the operational backbone Dani leans on.
- **Eng (Adrian, Julian, Michael).** Working relationships formed around launch-critical work; she's earned credibility by making fast, defensible calls rather than deferring.
- **External:** an embargoed press relationship (reporter) and at least one team-features **design partner** providing a launch testimonial — both nurtured over Month 2.

> Network shape: a tight **Discord-alumni core** (Sergei, Parris, Dani) at the center, a thin senior layer around launch (Sam, Samantha, Sarah), and a small eng bench. Every relationship is load-bearing — this is a ~15-person company where Dani is one of the few senior product voices.

## 4. Recurring patterns & habits (observed)

These are behavioral regularities the system has surfaced across the window — useful for the Brief's pattern-recognition moments ("this is the Nth time…"):

- **Decides with evidence, not vibes.** Repeatedly defers binary calls ("ship or not") until there's a number or a landed artifact. (Hot-data echo: "let's see the patch land, then decide with real numbers.")
- **Leads with the artifact, not the adjective.** Recurring instinct in both product and messaging: show the concrete thing (the brief, the demo, the proof point), distrust abstract claims. Resists overpromising language ("runs your day") in favor of verbs she can back.
- **Treats transparency as a feature.** A consistent preference for visible failure states and honest limitations over hidden polish.
- **Protects focus windows but responds fast on blockers.** Tends to batch deep work (positioning drafts, PRD writing in Cursor) into mid-morning and late-afternoon blocks, while clearing launch blockers near-synchronously in Slack.
- **Moves on people fast when conviction is high.** When a candidate or a hire feels right, she compresses the process rather than letting it drift (the Naomi urgency is characteristic, not exceptional).
- **Competitive trials are a personal ritual, not a delegated task.** She installs and uses rivals herself; her sharpest positioning insights come out of those sessions.
- **Tooling fingerprint:** Cursor for vibe-coding prototypes + PRD drafting; Linear watched through a **launch-blocker lens** rather than as a personal task list; Slack-first (light email, mostly external); GitHub only as a reviewer, not an author.

---

## How the Brief should use this
- This rollup is the **long-memory backdrop** — it lets the Brief say things the 2-day hot data can't, e.g. *"You've been converging on 'proactivity over capture' for six weeks; today's one-liner is where it lands,"* or *"This is the third time you've chosen a visible failure state over hidden polish."*
- It also answers the assignment's **scale question**: the system isn't holding thousands of raw items live — it holds *this*, the compressed trajectory, plus a precise recent window. Compression is the scaling strategy.
