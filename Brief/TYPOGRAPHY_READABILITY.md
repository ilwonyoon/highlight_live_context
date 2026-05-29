# Body-text readability — token rationale

> Why the Brief document body uses the spacing/line-height values it does. Researched 2026-05-28 (Butterick, Bringhurst, WCAG 1.4.12, Gestalt/NN-g, plus real CSS from GitHub / Tailwind `prose` / Medium). The point: spacing is set by evidence, not feel. Body size = **14px**.

## The core problem this fixes
The body read "loose and flat." Two causes, both about *rhythm contrast*, not the font:
1. **No within-group vs between-group contrast.** Bullets in one item were spaced the same as separate groups, so nothing read as a unit (Gestalt proximity: grouped things must be *closer to each other* than to their neighbors).
2. **Headers didn't bond downward.** Space above ≈ space below, so a header floated between sections instead of attaching to the content it introduces.

## The numbers (and the rule behind each)

| Token | Value | Rule | Source |
|---|---|---|---|
| body line-height | **1.55** (≈22px) | WCAG 1.5 floor; raise with measure | WCAG 1.4.12; Pimp My Type (wider→more leading); Medium ~1.58 |
| paragraph gap | **16px** | ≈0.73× line-height ("just over one line") | Butterick; Tailwind prose 0.71× |
| list item gap (within group) | **6px** | ≈0.3× line-height — tight, so items cohere | GitHub 0.25em; Tailwind 0.5em |
| group gap (list↔para, group↔group) | **16px** | = paragraph gap; **~2.5× the within-item gap** (1:2.5) | Gestalt proximity (NN/g) |
| nested indent (per level) | **24px** | one step/level, **max 3 levels** | Tailwind 1.625em; MDN depth limit |
| H2 space above / below | **32 / 12** | **~2.6:1** (above > below) | Butterick; USWDS ≥1.5:1; Tailwind 2:1 |
| H3 space above / below | **24 / 8** | **3:1**, smaller than H2 (rank via space) | Tailwind H3 1.6/0.6 |
| content max-width | **680px** | ≈66 chars/line for 14px | Bringhurst 45–75 / 66 ideal; Tailwind 65ch |

## Three rules to keep
1. **Within : between ≈ 1 : 2.5.** Items in a group tight (6px); gap to the next group ≈ paragraph gap (16px). This is what makes groups read as groups.
2. **Header space above > below (~2.5:1).** The header attaches to its section. Rank comes from size + weight + *space-above* together — never size alone.
3. **Measure ≈ 66 chars (680px at 14px).** Cap the text column; side padding is separate and not counted in the measure.

## SwiftUI note
`.lineSpacing()` adds gap *between* lines (not total line box). For a 22px line box at 14px, `.lineSpacing` ≈ 5–6pt. Our `BriefTypeStyle` already computes `extraLineSpacing = (lineHeight − 1) × fontSize`, so setting the token's `lineHeight` to 1.55 yields ≈7.7pt added — verify cap-to-cap against the render and trim if it reads loose.

## Sources
Butterick *Practical Typography* (line-spacing, line-length, space-above-and-below) · WCAG 2.2 SC 1.4.12 · Bringhurst measure rule (webtypography.net 2.1.2) · Pimp My Type (line-length↔line-height) · USWDS Typography · NN/g Proximity Principle · github-markdown-css · tailwindcss-typography `prose`.
