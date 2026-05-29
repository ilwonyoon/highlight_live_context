# Onboarding & Trust — Brief

> How a brand-new user first meets Brief, and how trust is *continuously* reinforced after. Pairs with `PRIVACY_MODEL.md` (the three privacy actions) and `PRIORITIES.md`. Research-backed (2026-05-28); take-home depth, not a spec.
>
> **The core reframe:** onboarding an ambient capture tool is not a *feature tour* — it's a **permission + trust negotiation**. The user is being asked to let the app read their screen, clipboard, meetings, mail. Microsoft Recall proved that getting this wrong (default-on, no consent) is fatal. So the onboarding IS the privacy hero's front door.

## Two stages (the 3 beats, resolved)

We originally framed three beats (first-run consent / re-education / continuous trust). Research collapsed them into **two stages**, because for a tool that's meant to be *invisible*, the only honest ongoing channel is the brief itself:

- **Stage 1 — First run** (once): the permission + trust negotiation.
- **Stage 2 — Ongoing** (lives inside the brief): re-education, teaching boundaries, and "here's what I protected" trust accrual — all embedded in the daily brief, never a separate nag stream.

---

## Stage 1 — First run: permission + trust negotiation

**Principle: value before ask. Stage permissions by fear; ask the scariest last.** Never fire all OS dialogs on launch. Every native macOS dialog is preceded by a Brief-styled **soft prime** (one sentence of concrete benefit) — the soft-ask is a reversible filter; declining it costs nothing, while declining the *native* dialog is expensive to recover from on macOS.

**The sequence:**
1. **Sign in** (SSO).
2. **Connect calendar** (OAuth — a familiar web consent, not a scary OS dialog). Low friction, high trust.
3. **Render a first real brief from calendar alone.** ← The aha moment *before* any heavy permission. The user sees the value the product promises, built from the safest possible source. This earns the right to ask for more.
4. **Soft-prime + request microphone** (for meeting capture). One line: why, and what they get.
5. **Soft-prime + request Screen Recording — last** (the heaviest; triggers a System Settings trip + app restart).

**The peak-anxiety moment is the Screen Recording step — and the privacy hero theme should peak here too:**
- Pre-empt the "are you watching my screen?" fear directly (Granola's move): explain exactly *what* is captured, that it's processed locally for the brief, and — if true — why macOS labels even audio-only capture as "Screen Recording."
- **Lead with the three privacy actions as a promise, here:** "Before you turn this on — here's what I'll never keep: passwords, keys, anything that's obviously private like medical or banking. And you can always tell me to forget more." This makes the silent/visible/user-control model (from `PRIVACY_MODEL.md`) a *reassurance at the moment of consent*, not fine print.

**The macOS hand-off, engineered as a first-class observable state** (not an error):
- Deep-link the button straight to the Screen Recording pane (`x-apple.systempreferences:…Privacy_ScreenCapture`), not the top of Settings.
- Trigger a dummy capture first so Brief actually *appears* in the Settings list (macOS only lists apps after their first capture attempt).
- Show a live "waiting for permission…" panel that auto-advances the instant the toggle flips.
- Lean on macOS's own "Quit & Reopen" prompt; treat the restart as expected.
- **Default to opt-in; capture is off until the user turns it on.** "Personal items stay in your personal layer" framing throughout.

---

## Stage 2 — Ongoing: re-education + trust accrual, inside the brief

**Why inside the brief:** an ambient tool that adds a separate notification stream breaks its own "quiet/invisible" contract. Research is clear — for a quiet tool, **the digest IS the re-engagement surface**. Behavior/milestone triggers beat time-based; digest framing has higher engagement + lower opt-out than individual alerts. So everything below rides *inside the brief the user already opens.*

**(a) Teaching boundaries (the re-education beat — P0 Action 3).**
The user must learn that *they* can say "never store this." Don't teach it in a tutorial — teach it **at the moment it's relevant**, when a surfaced item invites a rule:
- When Brief surfaces something context-sensitive (e.g. a comp discussion), offer inline: "Want me to never keep compensation talk? I can make that a rule." → authoring a privacy rule *from a real item* (strong micro-interaction candidate).
- Milestone-triggered, in the brief: "Brief has captured 50 meetings — you can exclude any app, site, or topic anytime." Surfaces the control *after* value is established.

**(b) Re-activating passive users (set up, but shallow).**
For users who plateaued (passive, not churned), nudge deeper value *inside the brief*, behavior-triggered:
- "You keep searching for decisions from meetings — connect Slack and I'll catch them automatically." (value-before-ask loop again: justify each new permission with demonstrated need.)
- Celebrate capture milestones as the hook to introduce the next source/permission.
- Respect quiet hours; offer digest vs. real-time frequency. Never a separate nag.

**(c) Continuous trust accrual — the antivirus / membership model (Ilwon's frame).**
The recurring "here's how much I protected you" signal — like antivirus "threats blocked this week," Apple's Privacy Report (trackers blocked), 1Password Watchtower, "you saved $X." This turns the *silent* filter into a visible trust asset.
- **The hard rule (from `PRIVACY_MODEL.md`): show the aggregate, never the content.** "This week I kept 3 secrets and 5 personal items out of your work context" — never the secret, never the medical detail. The count builds trust; re-showing the item would re-violate it.
- Tier it to the privacy actions:
  - **Silent filter** → only ever a non-identifying count ("3 secrets blocked"). This is the *one* place silent-filtered secrets become visible — as a number.
  - **Visible filter** → the calm "kept private" line, naming the *category* not content ("a doctor's appointment, your personal banking").
  - **User control** → "your rules caught 4 items this week," reinforcing that their boundaries are working.
- **Honesty caveat (the Recall lesson):** never promise blanket protection ("all sensitive data is filtered"). The numbers must be specific and falsifiable, paired with frictionless override. An over-confident wrong reassurance manufactures false trust — worse than none.

> **Whitespace / differentiation:** research found no shipping product does the proactive per-item "I noticed X and kept it private for you" reassurance, nor the "protection scoreboard" for an ambient capture tool. Antivirus does threat-counts; Apple does tracker-counts; nobody does it for *personal-context protection in an ambient work tool*. This is open ground for Brief — design it carefully, there's no template to copy.

---

## How this serves the assignment
- **Trust without surveillance** → value-before-ask sequence + opt-in + the privacy promise voiced at the consent moment.
- **"Both power AND casual"** → casual just accepts the staged permissions and reads the calm "kept private" + protection counts (peace of mind, zero config); power authors rules from surfaced items (granular control). Same onboarding, two depths — consistent with `PRIVACY_MODEL.md`.
- **"Complexity without complexity"** → no upfront settings wall; permissions staged just-in-time; control taught one item at a time, inside the brief.
- **Micro-interaction candidate** → "author a privacy rule from a surfaced item" (Stage 2a) or the consent-moment privacy promise (Stage 1).

## Open questions (for when screens get built)
- First-run: how many frames, and does the calendar-first "aha brief" need its own mock data state (empty-ish, day-one)?
- The protection scoreboard: where does it live — a line in each brief, a weekly recap, a dedicated calm surface? (No prior art — design choice.)
- Rule-authoring micro-interaction: what's the exact gesture from surfaced item → durable rule?
