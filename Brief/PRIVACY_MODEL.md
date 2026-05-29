# Privacy Model — Brief

> The privacy model for the P0 hero (see `PRIORITIES.md`). Grounded in research (3 parallel passes, 2026-05-28) into what enterprises/individuals refuse to have captured, what's legally off-limits, and how real products handle it. Sources cited inline.
>
> **Core principle (Ilwon's):** it's not about whether data is *objectively* sensitive — it's whether the *user feels* it is, so **control belongs to the user, and the system's whole job is to make that control effortless.** This resolves the assignment's tension: privacy is the P0 hero, expressed as *teaching the assistant what to remember* — not a control-panel dashboard (the "cognitive overload" the brief warns against).
>
> **The overriding design mandate (don't lose this):** every privacy decision is judged by one question — *is it dead-simple for the user to understand and to set?* That's not a nicety; it's the mechanism of the whole product. The flywheel is **earn trust → give control → unlock more permission → make Brief more useful.** If understanding "what's protected" takes a manual, or changing it takes hunting through settings, trust never compounds and permissions never expand. So: as few user-facing concepts as possible, plain language, and steering by conversation. Complexity lives in the model; the UI stays a sentence.

## The frame: two axes, and only two things the user sees

Earlier drafts split this into three "actions" (silent / visible / user-control). That's still useful *inside the system*, but it over-exposes the user. Cleaner model: privacy is **two independent questions**, and the user only ever sees **two buckets**.

**Axis 1 — WHAT gets filtered (who knows the boundary):**
- **Automatic** — the system can recognize it (universal secrets + categorical personal info). The user does nothing.
- **Your rules** — only the user/org knows it's sensitive (context-dependent). The user draws the line, by conversation.

**Axis 2 — HOW LONG it's kept (retention):**
- **Never** — not even stored (secrets; storing *is* the breach).
- **Forever** — normal work context, kept until the user says otherwise.
- **Until N days** — useful now, noise later; auto-expires. (Not sensitive — just has a shelf life.)

These axes are independent: an "Automatic" item can be Never-kept (a secret) or Forever-kept-then-protected (a medical note); a "Your rules" item can be excluded outright *or* set to auto-expire.

### What the user actually sees — exactly two buckets

| User sees | = | Means |
|---|---|---|
| **🛡 Automatic** | Axis-1 Automatic | "I handle this for you." Secrets and personal info are kept out without you lifting a finger. |
| **✋ Your rules** | Axis-1 Your rules | "You drew these lines." Each rule says *what* and *for how long* (exclude, or forget after N days). |

That's the entire user-facing taxonomy. Two words. Casual users live in **Automatic** (and rarely look); power users add **Your rules**. Retention isn't a third bucket — it's just an option *on* a rule ("forget after 14 days").

### The silent/visible distinction — an internal attribution detail, not a user concept

Inside **Automatic**, two things differ only in *attribution*, not mechanism (one filter engine, per-category policy flags):

| | echo the value back? | tell the user it happened? | store any metadata? |
|---|---|---|---|
| **secrets** (API keys, passwords) | ❌ never (re-leaks it) | ❌ silent (a non-identifying aggregate at most) | ❌ nothing stored |
| **personal info** (health, personal finance, family) | ❌ never the details | ✅ calm reassurance ("kept your appointment private") | ✅ enough to say *that* it was protected |

So "silent vs. visible" = two policy flags (`echoSafe`, `notify`) on the same engine, driven by detection category. **Not two separate systems, and never surfaced to the user as a choice.** Validated by Apple's own split — passwords protected *silently* ("never revealed… not even to Apple"), trackers *shown* in a Privacy Report ([Apple Privacy](https://www.apple.com/privacy/features/)): protect-silently for the toxic, show-the-receipts for the legitimate-but-private. It's a correctness detail, not a taxonomy the user navigates.

> **Note on the sections below.** The detailed write-ups still use the original "Action 1 / 2 / 3" headings — read them as: Action 1 = Automatic/secrets/Never, Action 2 = Automatic/personal-info, Action 3 = Your rules. The two-axis frame above is the canonical user model; the action sections are the implementation detail.

---

## Action 1 — Silent filter (universal secrets)

**What:** API keys (`sk-`, `sk-ant-`, `AKIA…`, `ghp_`, `xoxb-`, `AIza…`, `sk_live_`), passwords, private keys (`-----BEGIN … PRIVATE KEY-----`), OAuth tokens, JWTs (`eyJ…`), connection strings with embedded credentials (`postgres://user:pass@…`), `.env` / `.aws/credentials` / `*.pem` contents, 2FA seeds.

**Why silent (not surfaced):**
1. **No recall value** — nobody asks "what was that API key I pasted Tuesday?" They regenerate it. Nothing to summarize.
2. **Persistence *is* the harm** — a stored secret is a breach regardless of whether anyone reads it. (GitGuardian extracted 2,702 hardcoded credentials from Copilot, ~7.4% live — [gitguardian](https://blog.gitguardian.com/yes-github-copilot-can-leak-secrets/).)
3. **Notifying re-leaks it** — surfacing "we dropped your key `AKIA…`" re-displays/re-logs the secret.
4. **High precision = no judgment call** — machine formats make detection confident enough that asking the user would be pure noise.

**How (detect before persistence):**
- **Regex on issuer prefixes** (the workhorse — high-confidence, cheap). detect-secrets, gitleaks, trufflehog patterns.
- **Shannon entropy** as a *secondary* catch, post-tokenization, gated by regex/keywords — never alone (base64≈4.5, hex≈3.0 thresholds; entropy-only is false-positive-prone). ([detect-secrets](https://github.com/Yelp/detect-secrets), [gitleaks](https://github.com/gitleaks/gitleaks))
- **File/path layer** — never ingest contents of `.env`, `*.pem`, `id_rsa`, `.aws/credentials` (mirrors [secretless-ai](https://github.com/opena2a-org/secretless-ai), which blocks via pre-read hooks for Claude Code/Cursor/Copilot). Treat a paste into a terminal/password field as elevated-risk.
- **The closest precedent is secretless-ai**: blocks file access rather than showing inline notifications — exactly "an ambient tool that silently refuses to ingest secrets." Anthropic itself "filter[s] or obfuscate[s] sensitive data" pre-processing ([Anthropic privacy](https://privacy.claude.com/en/articles/10458704)).

**Design rule for Brief:** detect + drop at the capture boundary, *before* anything is written or sent to a model. Silent and irreversible **by construction, not by policy** — there's never a stored copy to leak. Surface at most a non-identifying aggregate ("filtered N secrets today"), never the value.

> **In our data:** `clp_d1_002b` (API key in Cursor), `clp_d1_004` (prod DB connection string), `slk_d1_003b` (Slack OAuth token) — all `type:security, detection:auto`. These are the Action-1 demonstrations.

---

## Action 2 — Visible filter (personal, with reassurance)

**What:** Medical/health (appointments, lab results, patient portals, prescriptions, mental health), personal finance (personal banking/investments/taxes — *vs.* company finance), family/relationships/personal messages, and incidentally-appearing GDPR Art. 9 "special category" data (religion, sexual orientation, politics, location/home). All legitimate to exist on a work device; none of the work-context's business. ([GDPR Art. 9](https://gdpr-info.eu/art-9-gdpr/))

**Why visible (reassure, don't silently drop):** the user isn't ashamed of these and isn't hiding them — silently removing them (like a secret) would feel cold and leave them wondering if it was captured at all. The user's need is **assurance the boundary is held.** The reassurance message *is* the feature. It also demonstrates the system can tell **personal finance (out) from company finance (in)** — the exact discrimination an ambient work assistant must prove.

**The Microsoft Recall lesson (the cautionary spine):**
- 2024: default-on, plaintext DB, captured credit cards "by design" → backlash, feature pulled. Fix: opt-in, Hello biometric, encryption, local-only, tray indicator. ([Beaumont/DoublePulsar](https://doublepulsar.com/microsoft-recall-on-copilot-pc-testing-the-security-and-privacy-implications-ddb296093b6c), [computing.co.uk](https://www.computing.co.uk/news/2024/ai/recall-relaunch-microsoft-addresses-privacy-concerns))
- **The deeper warning:** even after the fix, the filter *still leaks* — 2025 tests show it captures cards/SSNs/passwords when the literal keyword is absent ([Tom's Hardware](https://www.tomshardware.com/software/windows/microsoft-recall-screenshots-credit-cards-and-social-security-numbers-even-with-the-sensitive-information-filter-enabled), [The Register](https://www.theregister.com/2025/08/01/microsoft_recall_captures_credit_card_info/)). **An over-confident reassurance that's silently wrong is worse than none — it manufactures false trust.**

**How (reassurance UX):**
- **Show the receipts, not the content** (HBS Bernstein "transparency paradox": re-exposing the private content re-violates the protected zone — [HBS](https://www.hbs.edu/ris/Publication%20Files/Bernstein_TransparencyParadox_ASQ_June2012_cdaaee20-3a45-4a07-8867-9761a5d4b5e8.pdf)). Name the *thing* ("I kept your therapy appointment private"), never the details.
- **Calm, batched, in the brief** — not a startle-popup. A short "Kept private today" line in the morning/evening brief ("I left 3 personal items out of your work context — a doctor's appointment, your personal banking, family messages"). Matches the ritual + calm-UX guidance ([Smashing](https://www.smashingmagazine.com/2019/04/privacy-better-notifications-ux-permission-requests/), [UXmatters](https://www.uxmatters.com/mt/archives/2025/05/designing-calm-ux-principles-for-reducing-users-anxiety.php)).
- **Specific & falsifiable, with frictionless override** — not "all sensitive data is filtered." Treat the user's correction ("actually include this" / "you missed one") as a first-class action.
- **"Stays in your personal layer" framing** + opt-in capture by default ([Transcend](https://transcend.io/blog/opt-in-vs-opt-out)).

> **Whitespace / differentiation:** research found **no shipping product does Action 2's exact move** — proactively telling a user "I noticed personal item X and kept it out." Apple shows blocked trackers; Recall shows "filtering is on"; nobody surfaces a friendly per-item "I protected this for you." **This is open ground for Brief** — but there's no prior-art template, so the reassurance copy/UX must be designed carefully, not borrowed.

> **In our data:** `gml_d1_priv` + `chr_d1_priv1/2` (medical/MyChart), `scr_d2_002` (personal banking behind a screenshot) — all `type:privacy, detection:auto`. These are the Action-2 demonstrations.

---

## Action 3 — User control (context-sensitive)

**What:** Data that *looks like ordinary work content* — only the user/org knows it crosses a line. Enterprise/contractual: customer PII under DPAs, contract/deal/pricing terms, source code/IP, internal financials, unreleased roadmap. Org-context: compensation, HR/performance, legal/privilege, M&A, layoffs.

**Why it requires user definition (the load-bearing rationale):** sensitivity is contextual, not pattern-detectable. Google Cloud's example: "order number 75337" (benign) vs. "wallet number 75337" (sensitive) — identical digits, opposite decisions ([Google Cloud](https://cloud.google.com/blog/products/identity-security/why-context-is-the-missing-link-in-ai-data-security)). A calendar invite "Project Falcon sync" reveals nothing to a classifier but everything to an insider. Auto-detection structurally cannot reach this — it's a *control* problem, not a *detection* problem.

**How (control without the overload trap — the assignment's central constraint):**
- **Unit of control = a *rule*, not an *item*.** One rule covers infinite future items. Per-item auto-filtering fails (Recall); per-item human review fails at scale (academic consensus). Patterns:
  - **App/site/domain exclusion** (Rewind hides windows via ScreenCaptureKit, auto-excludes incognito; Highlight allow-lists — capture only runs on whitelisted apps). ([Rewind teardown](https://kevinchen.co/blog/rewind-ai-app-teardown/), [Highlight privacy](https://highlightai.com/privacy))
  - **Retention / auto-expiry** ("delete after N days" — Slack's org-baseline + per-channel override hierarchy). ([Slack retention](https://slack.com/help/articles/203457187-Customize-data-retention-in-Slack))
  - **Transient pause / private mode** (ChatGPT Temporary Chat — zero-config, for the unanticipated one-off). ([OpenAI](https://openai.com/index/memory-and-new-controls-for-chatgpt/))
  - **Natural-language rules** ("never store anything about the Acorn account") — the cleanest fit for context-dependent data, but mostly *emerging/research*, not shipped (ChatGPT Custom Instructions is the closest analog). A differentiation opportunity for Brief, prototype carefully. ([arXiv 2512.05065](https://arxiv.org/pdf/2512.05065))
- **Progressive disclosure + sensible defaults** — keep the default view to ~3 controls (pause, retention dial, exclude-an-app); bury advanced policy. (30–50% faster task completion vs. exposing everything — [progressive disclosure](https://www.uxpin.com/studio/blog/what-is-progressive-disclosure/).) This is the direct answer to "complexity without complexity."
- **Admin vs. personal split** — org draws the hard lines once (client X is confidential, the #comp channel, the data-room domain), encoded centrally; individuals get lightweight personal toggles *within* those guardrails (Slack/Purview model). Individuals shouldn't have to police company secrets.
- **Review-and-edit memory with real delete** — a visible "what Brief has captured" surface, one-click forget. **Avoid ChatGPT's documented trap** where deleting a conversation leaves derived memories behind — deleting in Brief must actually forget.

**Enterprise compliance drivers (why Action 3 exists at all):** Brief, ingesting screen/clipboard/Slack/email, *is* a subprocessor of all that customer data. Enterprises refuse it without: **"no training on our data"** (now a mandatory DPA clause), **SOC 2 Type II** (price of entry), **GDPR DPA Art. 28** (subprocessor disclosure, retention/deletion, residency). The captured-but-restricted categories are only knowable if the org can *declare* them — which is what Action 3's rules are. ([usefini](https://www.usefini.com/guides/ai-platforms-fintech-vendor-security-reviews-soc2-gdpr-2026), [secureprivacy](https://secureprivacy.ai/blog/data-processing-agreements-dpas-for-saas))

> **In our data:** `slk_d1_008b` (candidate comp), `tr_d1_oneonone_02` (a colleague's private family disclosure) — both `type:confidential, detection:user`. These are the Action-3 demonstrations: the system can't know they're sensitive; Dani draws the line.

---

## Filter catalog — what actually lands in each bucket

A plain-language list of *what gets filtered where*, grounded in the 9 sensitive items planted across our mock sources (chrome, clipboard, gmail, meetings, screenshot, slack). The point isn't a per-connector spec — it's a glanceable answer to "so what does silent / visible / user-control actually catch?"

### 🔒 Silent filter — dropped before storage, never mentioned

Universal secrets. Pure pattern-match, no judgment call, no user rule needed. **Detection: auto.**

| Caught | Real example in our data | Source |
|---|---|---|
| API keys | `sk-ant-api03-Rj4mZ2…` pasted into the Cursor terminal | clipboard |
| DB connection strings (with password) | `postgresql://highlight_app:Hk9$wRn2…@db-prod-1…` copied | clipboard |
| OAuth / bot tokens | a live Slack `xoxb-…` token pasted while debugging | slack |
| (same class) passwords, private keys (`-----BEGIN … PRIVATE KEY-----`), JWTs (`eyJ…`), 2FA seeds, `.env` / `.pem` / `.aws/credentials` contents | — | any |

Rule of thumb: **if storing it is itself a breach, it's silent.** Never echo the value back — "I removed your key AKIA…" re-leaks it.

### 🟡 Visible filter — auto-excluded, *and the user is told* (calmly)

Personal-but-legitimate. The user isn't hiding these; they just aren't the work context's business. The reassurance line *is* the feature. **Detection: auto.**

| Caught | Real example in our data | Source |
|---|---|---|
| Medical / health portals | "Lab Results — MyChart", "Message your care team — MyChart" tabs open mid-workday | chrome |
| Medical notifications in the work inbox | "Your recent lab results have been posted…" (MyChart email) | gmail |
| Personal finance behind a work capture | a personal banking tab visible behind an interview-scheduling screenshot | screenshot |
| (same class) personal banking/investments/taxes, family & personal messages, GDPR Art. 9 special-category data (religion, politics, sexual orientation, home location) | — | any |

Rule of thumb: **legitimate to exist on a work device, none of the work context's business** → exclude *and say so* ("I kept your therapy appointment private"), never the details. Proves it can tell **personal finance (out) from company finance (in)**.

### ✋ User control — only the user/org knows it crosses a line

Looks like ordinary work content; a classifier can't tell. The user draws the line via a **rule**. **Detection: user.**

| Caught | Real example in our data | Source |
|---|---|---|
| Candidate compensation in a hiring context | "if she clears the onsite, what's the band? Sergei floated $215k base + 0.4%…" | slack |
| A colleague's private disclosure shared in confidence | a teammate's family/health situation mentioned in a 1:1 | meetings |
| (same class) customer PII under DPAs, contract/pricing terms, source-code/IP, internal financials, unreleased roadmap, comp/HR, legal/privilege, M&A, layoffs | — | any |

Rule of thumb: **sensitivity is contextual, not pattern-detectable** ("order #75337" benign vs. "wallet #75337" sensitive — same digits). One *rule* covers infinite future items ("never keep anything about the Acorn account").

> This catalog is the WHAT axis. The HOW-LONG axis (below) is orthogonal — it applies to anything that *is* kept.

---

## Retention — the HOW-LONG axis (auto-expire)

Filtering answers "is this kept at all?" Retention answers "for how long?" — a separate question that applies to everything that survives the filter. Three settings:

| Retention | For | Example |
|---|---|---|
| **Never** | secrets — storing *is* the breach | API key, password |
| **Forever** (default) | durable work context | your role, ongoing projects, key decisions |
| **Until N days** | useful now, noise later — *not sensitive, just perishable* | this sprint's debug notes, a one-off research tab, a temporary log |

**Why this matters to trust (and the flywheel).** "Auto-expire" isn't a safety control like secret-dropping — it answers a *different* anxiety: **"is everything I let you see piling up forever?"** Telling the user "I keep what's useful and let the rest fade" removes the fear of infinite accumulation, which is one more reason to connect the next source. Trust comes from *both* "you protect me" **and** "you don't hoard me."

**Where it lives in the user model:** retention is **not a third bucket** — it's an *option on a rule*. The user expresses it the same way they express anything else — by talking:
> User: "Keep the Falcon migration notes for two weeks, then forget them."
> Brief: "Done — anything about the Falcon migration auto-expires 14 days after it's captured."

So a **rule = { what, how-long }**: exclude outright, or keep-then-expire. The default for everything uncovered is Forever; the user only sets expiry where a shelf life makes sense. (This keeps the simplicity mandate intact — no retention dial to learn; you just say it.)

> **In our data — candidates for auto-expire:** transient working context like sprint scratch notes or a one-off research tab. None are *sensitive*; they just shouldn't accumulate. (Distinct from the secrets/personal/confidential items, which are about *filtering*, not *expiry*.)

---

## Two paths to control: conversational (primary) + manual (fallback)

The three actions define *what* the system does. This section defines *how the user steers it* — and the opinionated bet is that **steering happens through conversation, not a settings panel.**

> **Ilwon's framing:** "Who manually controls settings anymore? You tell the AI." The privacy control surface is, first, a **conversation** — and only secondarily a manual panel for people who want to drive by hand. Same *proactive + action* spine as the rest of Brief: the assistant explains the current state and changes it for you, rather than handing you toggles.

This is the concrete answer to the model's own open question ("how does a natural-language Action-3 rule get authored?") and to the assignment's central tension (control *without* a cognitive-overload dashboard).

### Path A — Conversational control (the primary surface)

Entering "Privacy" from the Live Context surface opens a **chat scoped to privacy** — the composer's context chip reads "Privacy," not a document. Two moves:

1. **It briefs you on the current state first (proactive).** Before you ask anything, it states what each action is doing right now, in plain language:
   > "Right now I'm **silently dropping** secrets — API keys, passwords (3 today). I'm **keeping personal things out and telling you** — a doctor's appointment, your personal banking. And you've drawn **2 lines yourself**: nothing about the Acorn account, and the #comp channel stays out."

   This makes the otherwise-invisible model (Actions 1+2 are automatic) *legible* without a dashboard — the chat is the transparency surface.

2. **It turns a wish into a rule (action).** The user describes what they want filtered in natural language; the assistant **authors the Action-3 rule** and confirms:
   > User: "Don't keep anything about the Falcon acquisition."
   > Brief: "Done — I'll exclude anything mentioning *Falcon acquisition* from your work context, across all sources. You can see or undo this in Privacy settings." → a rule is created.

   The user never picks a category, drags a toggle, or writes a regex. They describe the boundary; the system encodes it. (This is the natural-language-rule pattern the model flagged as emerging/differentiating — here it's the *default* authoring path.)

The chat can also explain *why* something is the way it is ("why didn't you filter X?") — which doubles as teaching the silent / visible / user-control distinction in context, exactly when the user cares.

### Path B — Manual settings (the fallback)

For users who *do* want to drive by hand, a conventional **Privacy settings** screen exposes the same model manually: active rules (Action 3) with edit/delete, visible-filter categories with per-category on/off, retention/pause controls, app-exclusion. Progressive disclosure still applies — default view ~3 controls, advanced policy buried.

**Both paths edit the same underlying rule set.** A rule authored by conversation appears in the manual list; a toggle flipped manually is reflected in the next conversational brief. The chat is a faster, friendlier front-end onto the same state — not a separate system.

### Why this split is the right bet

- **Casual users never open settings** — they live entirely in Path A (and mostly in the automatic Actions 1+2). The conversation *is* their control surface, and it's zero-config.
- **Power users get Path B** to audit / bulk-edit — but even they author most rules by talking, because describing a boundary is faster than building one.
- **It collapses the overload problem.** A panel that could expose dozens of toggles instead opens as a sentence: "here's what I'm protecting; tell me what else." Complexity lives in the model, not the UI.

> **Micro-interaction candidate (assignment requirement):** authoring an Action-3 rule *from a surfaced item* — the brief shows a line, the user says "keep this kind of thing private," the rule materializes and the item retreats. The "wish → rule → confirmation" moment is the demonstrable craft beat.

---

## How this answers the assignment

- **"Edit and curate / delete sensitive / annotate / flag"** → curation = drawing privacy boundaries (Action 3) + confirming auto-protections (Action 2). Reframed as *teaching what to remember*, not data hygiene.
- **"Both power users AND casual users"** → the two user-facing buckets ARE the split: casual lives entirely in **Automatic** (safety + reassurance = peace of mind, hands-off); power adds **Your rules** (what to filter + how long to keep). Same model, two depths — and they're the same person early vs. late on the trust ladder, not two personas.
- **"Complexity without complexity"** → rules-not-items + progressive disclosure + sensible defaults; Action 1 is invisible, Action 2 is one calm line, Action 3 is ~3 default controls.
- **"Scales to thousands"** → rules scale (one rule = infinite items); compression handles volume; auto-actions mean the user rarely touches individual items.
- **The honesty principle** (the Recall lesson) → never promise blanket filtering; surface specific, falsifiable protections with frictionless override. This is itself a "thoughtful trade-off" to articulate.

## Open design questions (for when screens get built)
- What does the Action-2 reassurance line actually look/sound like in the brief? (No prior art — must design.)
- How does a natural-language Action-3 rule get authored and confirmed? (Emerging pattern.)
- Admin/team policy surface — in scope for the hero, or noted as the for-Teams extension?
- The micro-interaction the assignment requires — strong candidate: the "forget this / keep private" moment, or authoring a rule from a surfaced item.
