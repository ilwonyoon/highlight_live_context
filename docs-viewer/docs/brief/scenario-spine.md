# Scenario Spine — Dani's 2 days (the story all streams share)

> Internal coherence guide. Every event in `*.jsonl` should trace to a beat here. Times are America/Los_Angeles (PDT, -07:00). Day 1 = Wed May 27, Day 2 = Thu May 28 (today). Launch = Tue Jun 9 (D-12).

## The throughline
Dani is driving Highlight's public launch (Jun 9). Two storms collide this week:
1. **A launch blocker emerges** — the Slack Connection (OAuth token refresh) is failing for some users during meeting→task push. It's a P0 because "Connections" is a headline launch feature. Parris's eng team is on it; Dani has to decide scope: fix-before-launch vs. ship-with-known-limitation.
2. **The external story isn't landing** — the launch positioning sounds like every other AI tool. Samantha (fractional brand) + Dani are wrestling the message; the Founding Product Marketer candidate (Naomi) could own this, so the hire suddenly feels urgent. A reporter (Priya) is on an embargo and wants an exec quote.

Plus steady-state: recruiting coffee chats, competitor trials (Littlebird is uncomfortably close to Highlight), and the normal launch burn-down.

## DAY 1 — Wed May 27 (~10h)
- **08:50** Dani opens laptop. (Day-1 morning brief would have shown — but our hero is the *evening* of Day 1.)
- **09:00–09:30** Launch standup (meeting, voice). Parris flags the Slack OAuth token-refresh failures seen in dogfood. Adrian: intermittent, ~. Decision deferred. → spawns Linear P0.
- **09:30–10:30** Focus: Dani drafts launch positioning in Cursor (PRD-style doc) + vibe-codes a landing-page hero variant via Cursor cloud agent.
- **10:30–11:00** Slack ping-pong on the OAuth blocker (eng channel). Julian: it's the token refresh window, not the integration itself.
- **11:00–11:45** Competitor trial: Dani uses Littlebird (Chrome → littlebird.ai, pricing, the TechCrunch piece). Unsettled by how close the ambient-context pitch is. Notes in Cursor doc.
- **12:00–12:30** Coffee chat #1 — Naomi Feldman (Founding Product Marketer candidate) (meeting, voice). Strong. Dani leaves wanting to move fast on her.
- **13:00–13:40** Gmail batch: Naomi follow-up thread; Priya (reporter) embargo request; a tool-billing receipt; Theo (design partner) testimonial ask.
- **14:00–15:00** Launch messaging working session w/ Samantha (meeting, voice). They can't crisp the one-liner. Reference Sergei's "AI you don't have to ask." Action: Dani to draft 3 options tonight.
- **15:00–16:00** Reviews competitors more (Granola pricing/Series C news, Superhuman, Claude Cowork) in Chrome to benchmark positioning + pricing. GitHub: a launch-blocker-adjacent PR review request lands (Dani is requested as reviewer on a product-copy change).
- **16:00–16:30** Linear triage: Dani re-prioritizes the OAuth issue to P0, comments scope question, assigns follow-up. Two other launch issues touched.
- **16:30–17:30** Cursor cloud agent run: drafts the 3 positioning one-liners + a PRD section on "known limitations at launch." Dani edits.
- **18:30** Day 1 winds down. **→ EVENING DEBRIEF (hero #1):** what happened Wed, what got handled (positioning drafts, competitor read), what's still open (OAuth P0 decision, Naomi hire urgency, Priya quote), carries to Thu.

## DAY 2 — Thu May 28 / today (~10h, partial — morning is the hero)
- **08:45** Dani opens laptop. **→ MORNING BRIEF (hero #2):** yesterday in one breath + today's must-dos: (1) make the OAuth ship/no-ship call (eng needs answer by noon), (2) send Priya a quote (embargo clock), (3) move Naomi to onsite, (4) lock the launch one-liner.
- **09:00–09:30** Launch standup (meeting, voice). The OAuth fix has a candidate patch overnight (Adrian) — needs Dani's go/no-go on whether it's enough for launch.
- **09:30–10:00** Slack: Dani makes the call in the launch channel (ship the patch, flag Slack-token edge case in release notes). Parris 👍.
- **10:00–10:30** Gmail: Dani sends Priya the exec quote (pulls from Sergei's framing); replies to Naomi to schedule onsite; quick yes to Theo testimonial.
- **10:30–11:00** Cursor: finalize the launch one-liner from last night's 3 options; cloud agent updates the PRD + landing copy.
- **11:00–11:30** Coffee chat #2 — Dr. Wei Zhang (Head of AI candidate) (meeting, voice). [today, in-progress edge]
- *(Day 2 is intentionally partial past ~late morning — the Morning Brief is the hero and looks forward; later Day-2 events are light/empty to show the "today is still unfolding" state.)*

## Cross-stream consistency checklist
- OAuth blocker: appears in meetings (D1 09:00, D2 09:00), slack (D1 10:30, D2 09:30), linear (D1 16:00 triage + statuses), github (D2 patch PR).
- Positioning one-liner: cursor (D1 draft, D2 finalize), meetings (D1 14:00 Samantha), slack (D2 lock), gmail (D2 Priya quote uses it).
- Naomi hire: meetings (D1 12:00 coffee chat), gmail (D1 follow-up, D2 onsite scheduling).
- Littlebird/competitors: chrome (D1 11:00, 15:00), cursor (notes), meetings (D1 14:00 references rivals).
- Priya embargo: gmail (D1 request, D2 quote sent).
