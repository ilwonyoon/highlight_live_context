# Document rendering architecture

> The standard for how the Brief renders a reading document (the Live Context body, and every variation's prose). Defined here on the Live Context surface, then promoted to the design system once proven. Supersedes the ad-hoc bullet rendering. Grounded in the structural audit (2026-05-29) and `TYPOGRAPHY_READABILITY.md`.

## Why this exists
The first cut had **three conflicting spacing systems** stacked on top of each other, so typography tokens couldn't control the page:
1. `VStack(spacing:)` between bullets (6pt),
2. `SelectableLine.padding(.vertical, 4)` on every line (+4+4 = 8pt) — silently part of the reading rhythm,
3. two different line-leading mechanisms — `FlowLayout(lineSpacing: 6)` for provenance bullets vs. a hand-computed `lineSpacing` for plain bullets.
Net: inter-bullet gap = ~14pt of fixed padding that **no token reaches**; line-height edits did nothing; the marker was a `Circle().offset(y: 6)` magic-number fudge (Circles have no text baseline); and `FlowLayout` measures each text segment atomically so prose **can't wrap mid-segment**.

## Principles (the new standard)
1. **One leading source.** Line-leading comes only from `BriefTypeStyle` (`extraLineSpacing = (lineHeight − 1) × size`). Never recompute it inline; never a second hardcoded `lineSpacing`.
2. **One spacing owner per axis.** Vertical rhythm between blocks is owned by `BriefMarkdown` tokens. `SelectableLine`'s padding is for the *selection hit-target/affordance only* and must not contribute to reading rhythm (decouple it — selection background can inset without adding layout gap, or its padding is 0 for `.line` and the gap lives in the container).
3. **Prose wraps natively.** Inline text + inline objects reflow as one paragraph. A long sentence breaks between words, not as an atomic block.
4. **Markers are metric-derived.** No `.offset` magic. The bullet marker aligns to the first text line via a font-metric `alignmentGuide` or a `Text`-based glyph (the `tldrItem` pattern already proves this works).
5. **Provenance stays interactive.** Inline citations keep hover→popover. That constraint is why we need a real layout, not just `AttributedString`.
6. **FlowLayout is for chips only.** Badges, favicon clusters, tag rows — genuinely atomic pills. It is not the prose engine.

## The components

### `BriefProseLayout` (new) — the prose engine
A width-aware SwiftUI `Layout` replacing `FlowLayout` for paragraph content.
- **Sizing:** for each subview, propose the *remaining width on the current line* (not `.unspecified`). A `Text` child then wraps itself; read back its (possibly multi-line) size.
- **Placement:** advance the pen by the child's **last-line trailing width**; when a child's first line doesn't fit the remainder, wrap to a new line first. This makes a long text segment break naturally across lines instead of jumping whole.
- **Leading:** inter-line gap = the token's `extraLineSpacing` (single source), applied between line fragments.
- **Baseline:** lay children on a shared first-baseline per line so mixed Text + ProvenanceInline sit on one baseline.
- **Keeps interactive children:** ProvenanceInline remains a real `Button` view (hover/popover intact) — the whole reason we don't collapse to a single `AttributedString`.
- Note: SwiftUI `Layout` can't ask a `Text` "where do your line fragments break"; the pragmatic implementation proposes width, reads total size, and treats the trailing advance as `lastLineWidth` (approx via a measuring pass). Acceptable for our line lengths; documented as the known limit.

### Bullet renderer (rebuilt) — one path
Collapse `bullet(...)` and `plainBullet(...)` into a single `briefBullet`:
- marker column (metric-aligned) + `BriefProseLayout { segments }`.
- segments are the same `ProvenanceSegment` model (`.text`/`.label`/`.source`/`.stacked`).
- `.label` and `.text` are plain `Text` (wrap natively in the layout); `.source`/`.stacked` are the interactive views.
- One leading, one marker rule, one spacing — no divergence.

### Block spacing (owned by tokens)
- Bullet-to-bullet gap, group gap, header above/below — all from `BriefMarkdown` (already research-set: bullet 6 / group 16 / h2 32·12 / h3 24·8).
- The bullet container owns the gap; `SelectableLine` stops adding vertical padding to the flow (selection visual insets without changing layout).

### Marker
`Text("•")`-based (inherits true baseline, scales with token) — the simplest correct option, already proven in `tldrItem`. If a geometric dot is required later, use `alignmentGuide(.firstTextBaseline)` derived from font cap-height. No `.offset`.

### What stays untouched
`BriefFont` / `BriefTypeStyle` / `BriefTypeToken`, `BriefMarkdown` headers (H1–H4) + tokens, `BriefSpacing`, `BriefLayout`, `SelectableLine`'s **selection mechanism** (PreferenceKey frame reporting). `FlowLayout` stays for chip rows.

## Open question (decide while building)
- **Provenance hover background.** Keep the highlighter "swipe" background on hover, or underline-only? Currently leaning underline-only (one signal). Revisit against the real render.

## Migration
1. Build `BriefProseLayout` in DesignSystem; unit-check wrap + a long sentence + an inline source.
2. Rebuild the bullet/marker in `LiveContextView` on it; verify Variation A: token-controlled spacing, aligned markers, natural wrap, working provenance hover.
3. Once proven on A, the bullet renderer + `BriefProseLayout` are the design-system standard — fold back into `BriefMarkdown`/`ProvenanceTag` and reuse for C/D.

## Promotion note
This is being built on the Live Context surface first *by design* — it becomes the canonical document renderer. After it's validated here, promote `BriefProseLayout` + the unified bullet into the shared design system (replacing `FlowLayout`-for-prose), so every surface inherits the same typeset quality.
