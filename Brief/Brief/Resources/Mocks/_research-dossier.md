# Research Dossier — Ground Truth for Mock Data

> Compiled 2026-05-28 from web research (4 parallel research passes). This file is the **ground truth** every mock event must stay consistent with. Real, publicly-sourced facts about Highlight, its founder, a real teammate, and the competitors our persona evaluates. Source URLs included so claims are checkable.
>
> **Usage rule:** Real people/companies/funding/titles below are *factual* (use verbatim where quoted). Fictional scenario events (mock meeting dialogue, Slack messages, emails) are *invented for the prototype* — they are NOT real statements by these people. The persona **Dani Reyes** is fictional. Keep invented events plausible against these facts; never contradict them.

---

## ⚠️ Naming reality check (affects copy, not our product decision)

Our product uses **"Live Context"** (system layer) + **"Brief"** (surface) — Ilwon's decision, kept. But know the real Highlight vocabulary so mock data referencing the *actual* product stays honest:

- Highlight does **NOT** use "Live Context" / "Living Context." Real terms: **"Screen Context," "shared memory layer," "context graph."**
- Highlight's real feature is **"Daily Briefs & Summaries" / "Daily Summaries"** (overlaps our "Brief" — that's fine, it's our surface).
- Integrations are called **"Connections"**; automations are **"custom actions" / "Auto-Task"** (NOT "Skills").
- On-screen invocation UI is the **"Magic Dot"** ("AI at the tip of your mouse").
- **"Highlight for Teams"** is not a confirmed product name — the team product is waitlist-stage, framed as **"team intelligence" / "shared intelligence layer."**
- Cross-conversation search is **"@Mentions."**

→ In mock data, when Dani references the actual Highlight product she works on, prefer the real terms (Connections, Daily Summaries, Magic Dot, Screen Context). The "Live Context / Brief" naming is *our design layer* on top.

---

## 1. Sergei Sorokin — CEO (Dani's manager)

**Role & background**
- Co-Founder & CEO of Highlight AI; appointed CEO concurrent with the $40M Series A (announced **2026-03-24**). Note: he was **not** the original 2024 founder (that was Pim de Witte) — "Co-Founder" reflects the 2026 chapter.
  - https://siliconangle.com/2026/03/24/ai-productivity-startup-highlight-ai-raises-40m-appoints-new-ceo/
  - https://www.linkedin.com/in/ssorokin
- **8 years at Discord as VP of Product** — grew platform from ~5M to nearly 300M MAU; built Discord's revenue business from scratch; led AI features.
- After Discord: ~2 years building/advising AI startups (named: **Weights, Aura, OffCall**) — "saw firsthand how fragmented tools and agent workflows fail to deliver real productivity gains."
- Based in Irvine, CA.
  - https://www.intelligence360.news/highlight-ai-raises-40-million-series-a-to-build-the-shared-intelligence-layer-for-the-agentic-age-of-work/

**Vision quotes (VERBATIM — usable in scenario as things Dani internalized / Sergei said publicly)**
From his LinkedIn launch post (~March 2026):
> "I spent 8 years scaling Discord and got burnt out because modern work is broken."
> "We're overwhelmed with too much info, most of it low signal noise, and it gets worse the larger the org. AI sped this up, and existing tools just added more places to prompt."
> "We're building AI that you don't have to ask, because it already knows what to do. An AI that watches you work on your screen, in meetings, and between apps, connects the dots across your team, highlights what matters, and drafts actions before you ask."
> "A shared intelligence layer that knows your team and handles the noise."
> "An intelligent work OS for your team with shared memory, multiplayer agents, and proactive execution."
- https://www.linkedin.com/posts/ssorokin_finally-i-can-share-what-ive-been-up-to-activity-7442222781791899649-Bu-i

From Series A press:
> "AI's limitations in the workplace are no longer due to intelligence or capability. It's a coordination bottleneck."
> "Highlight is building the collective intelligence layer for the agentic age, unifying coordination and memory so work can move forward proactively rather than being constantly reassembled."
- https://siliconangle.com/2026/03/24/ai-productivity-startup-highlight-ai-raises-40m-appoints-new-ceo/

**Why this matters for our scenario:** Sergei is ex-Discord. Dani (our persona) is also ex-Discord — a natural reason Sergei recruited her. Sergei's "proactive / drafts actions before you ask / coordination bottleneck" framing is *literally* our "Proactive + Action" thesis — Dani's design work is executing her CEO's stated vision.

---

## 2. Parris Khachi — Head of Product Engineering (Dani's peer)

**Identity — HIGH confidence.** "Parris K." on LinkedIn = **Parris Khachi** (shared member-ID suffix `7928b011` across both profiles).
- https://www.linkedin.com/in/parris-k-7928b011/
- https://github.com/parris (display name "Parris Khachi," 46 repos)

**Background**
- **ex-Discord Senior Engineering Manager** (Core Experiences org — notifications/messaging; started the eng Growth Team; kicked off Webflow integration). Joined Discord ~June 2020.
  - https://webflow.com/webflowconf/2022/speaker/parris-khachi
  - https://theorg.com/org/discord/org-chart/parris-khachi
- Earlier: **Eventbrite** (PM, then Sr/Front-end SWE), **Brigade** (Director of Eng), **Forj** (co-founder), **NetApp**, **Parris Studios** (founder).
- Education: **B.S. Computer Science, San Jose State University.**
- Authored JS OSS: `iz` (validation), `dorsal`, `66`. npm: https://www.npmjs.com/~parris
- Wrote "How to Make Learning a Core Part of Your Engineering Team."
- (Reported, MEDIUM confidence) Early Engineering Leader at **Arena / LMArena** before Highlight.

**Scenario use:** Parris is *Head of Product Engineering* (eng), Dani is *Head of Product* (product) — **two different people, two different functions.** They partner on launch. Both ex-Discord — the Discord alumni cluster (Sergei, Parris, Dani) is a real, plausible founding-team texture. Parris is the eng counterpart Dani coordinates with on launch blockers.

---

## 3. Highlight — the product Dani works on

**Stage / facts**
- Spun out of **Medal Inc.** Oct 2024 with $10M (General Catalyst-led). Publicly launched, free on **Mac & Windows** (macOS flagship).
- **$40M Series A** led by **Khosla Ventures**, 2026-03-24. ~$73M total raised. **500,000+ users**; adoption at **Google, DoorDash**.
  - https://www.businesswire.com/news/home/20260324500318/en/
- Pricing (verbatim from highlightai.com/pricing): **Free $0** (unlimited chats, local audio transcription, Daily Briefs & Summaries, All Integrations) / **Pro $20/mo** (2,000 credits, premium models, real-time cloud transcription, instant action items) / **Enterprise Custom** (API access, on-prem, custom integrations).
- **Developer mode exists** (historically): npm `@highlight-ai/app-runtime` — "app platform for AI apps," `globalThis.highlight` available only inside the Highlight app, with `HighlightContext` / `userIntent` objects. NOTE: dev docs now redirect to consumer help center + example repo deprecated → the public app SDK appears in-transition. **But "developer mode" as a concept is real** — supports our premise of Dani viewing her own Live Context via dev mode.

**Six official features (verbatim taglines):** Chat ("Intelligence at your fingertips"), Writing ("Memory-backed AI writing"), Voice ("Hands-free interaction"), Tasks ("Automated task tracking"), Meetings ("Magic notes and takeaways"), Connections ("Connect to your favorite tools").

**Coined product terms (real):** Magic Dot, Auto-Task, Daily Summaries, @Mentions, Screen Context, Connections.

**What it captures (confirmed):** screen + OCR (encrypted SQLite, local, whitelisted apps only, frames discarded after processing), system audio / meeting transcription (no meeting bots; local on Free, real-time cloud on Pro), attachments/documents. Local-first; "never trains on your data." (Clipboard NOT officially confirmed — don't assert.)

**Integrations ("Connections") — CONFIRMED tools:** Gmail, Google Calendar, Google Docs / Workspace, Slack, Notion, Linear, GitHub, ChatGPT. Tasks push to Notion, Linear, Google Calendar. **Architecture = MCP** (Model Context Protocol). GitHub org `highlight-ing` publishes per-source MCP servers: `gmail-mcp-server`, `google-calendar-mcp-server`, `applescript-mcp`, etc.
  - https://github.com/highlight-ing
  - https://highlightai.com/connections

> **This is why our mock data is per-source streams.** Highlight's real architecture is *per-connector MCP servers feeding a shared context layer*. Our `Mocks/*.jsonl` (one file per source) + a common `LiveContextEvent` envelope mirrors that exactly.

**Real blog timeline (anchors our "2-week launch"):**
- 2026-05-26 — "What Cheap Code Did to Design"
- 2026-05-11 — "How to build agentic chat with Durable Objects"
- 2025-08-15 — "Introducing: Daily Summaries"
- 2025-06-13 — "Meeting notes, reimagined"
- 2025-05-08 — "Auto-Task: your digital task assistant"
- 2025-04-14 — "Magic Dot: AI at the tip of your mouse"

**2026 strategic vocabulary (verbatim, from /mission):** "shared intelligence layer for the agentic age of work," "coordination tax" (claimed "up to 24 hours per employee each week"), "shared, unified team memory," "collective context graph," "AI should work with you and your team, not just wait for you to prompt."

**Team (~10 named on About page; ~10-30 total, SF HQ):** Sergei (CEO), Pim de Witte (co-founder/chairman, now also CEO of General Intuition), Josh Lipson (co-founder), Sam Eckert (Head of Design — per LinkedIn screenshot), Sarah Wu (Ops), Adrian Casares (Backend Eng), Julian Curtis-Zi… (Lead Engineer), vasudev menon (design eng), Avinash Anant… (Member of Technical Staff), Michael Jelly (AI), Samantha Taube (brand/launches, fractional), Parris Khachi (Head of Product Eng). Background: "years at Discord, Medal.tv, Meta."

**Open roles (recruiting — coffee-chat targets):** Head of AI, Senior ML Engineer, Senior SWE Backend, Senior SWE Full-Stack, Founding Product Marketer (+ Sergei publicly posting for Brand & Content Lead and Head of Product Marketing).

---

## 4. Competitors Dani is evaluating (real facts + real URLs for Chrome history)

### Granola — granola.ai
- Tagline: "The AI Notepad for back-to-back meetings."
- What: desktop AI notepad, **no meeting bot**, merges your typed notes with transcript → enhanced summaries; cross-meeting AI chat; templates; "Spaces" for teams.
- 2026-03: **$125M Series C at $1.5B valuation** (Index, Kleiner Perkins). Pricing: Free / Business $14/user/mo / Enterprise $35/user/mo.
- Customers shown: Vanta, Gusto, Asana, **Cursor**, Linear, Vercel, Replit, Brex.
- Chrome-history URLs: `https://www.granola.ai/pricing`, `https://www.granola.ai/explore`, `https://techcrunch.com/2026/03/25/granola-raises-125m-hits-1-5b-valuation-as-it-expands-from-meeting-notetaker-to-enterprise-ai-app/`

### Superhuman — superhuman.com
- Tagline: "Superpowers, everywhere you work" / (email) "The most productive email app ever made."
- What: AI-native email client; now Mail + Docs + cross-app AI assistant; drafts in your voice.
- **Acquired by Grammarly 2025-07-01**; parent renamed "Superhuman" 2025-10-29. Pre-acquisition: ~$825M valuation (2021), ~$35M/yr revenue.
- Claims (verbatim marketing): "Save 4 hours every single week," "Fly through your inbox twice as fast."
- Chrome-history URLs: `https://superhuman.com/ai`, `https://superhuman.com/plans`, `https://techcrunch.com/2025/07/01/grammarly-acquires-ai-email-client-superhuman/`

### Littlebird — littlebird.ai  ⭐ closest direct competitor to Highlight
- Tagline: "Remember everything" / "The AI assistant that already knows your work."
- What: native macOS/Windows app that **reads structured on-screen text** (not screenshots) + real-time meeting transcription → private searchable memory across apps; ~90+ integrations. **The most on-the-nose ambient-context rival to Highlight.**
- 2026-03-23: **$11M** led by Lotus Studio; angels incl. Lenny Rachitsky, Scott Belsky, Gokul Rajaram, Justin Rosenstein, swyx. SOC 2, AES-256, no model training on data.
- Pricing: Free / Plus $17-20/mo / Pro from $100/mo / Team from $17/seat / Enterprise "Let's talk."
- Chrome-history URLs: `https://littlebird.ai/pricing`, `https://techcrunch.com/2026/03/23/littlebird-raises-11m-to-capture-context-from-your-computer-so-you-can-query-your-data/`, `https://www.producthunt.com/products/littlebird`

### Claude Cowork — Anthropic
- Tagline: "Delegate to Claude, delight in the result" / "Claude Code power for knowledge work."
- What: agentic desktop assistant — give it a goal, it works across local files/apps in a sandbox, returns finished deliverables; approval checkpoints; scheduled runs. "Claude Code for everyone else" (non-technical knowledge workers).
- **Jan 2026: research preview. Feb 24 2026: enterprise release** (connectors: Google Drive, Gmail, DocuSign, FactSet). Available on all paid Claude plans via desktop app.
- Chrome-history URLs: `https://www.anthropic.com/product/claude-cowork`, `https://claude.com/product/cowork`, `https://www.cnbc.com/2026/02/24/anthropic-claude-cowork-office-worker.html`

---

## Confidence summary
- **Solid (verbatim-quotable):** Sergei's bio + quotes; Parris identity + history; Highlight funding/pricing/features/Connections-MCP architecture/blog dates; all 4 competitors' funding + taglines + real URLs.
- **Medium:** Parris's Arena/LMArena stint (snippet-only); exact Highlight headcount (~10-30, inferred); Highlight dev-platform *current* status (in-transition).
- **Do NOT assert:** Highlight clipboard capture; "Live Context"/"Skills"/"Highlight for Teams" as Highlight's own terms (they're ours/unconfirmed); any private info about real individuals.
- **Fictional (clearly invented for prototype):** Dani Reyes and all her specific events; all mock meeting/Slack/email/issue content.
