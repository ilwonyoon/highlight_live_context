# Brief — Highlight take-home prototype

SwiftUI macOS app prototype for the Highlight "Memory" assignment, reframed as the **Brief** (the Chief of Staff briefing surface).

## Structure

```
Brief/
├── project.yml                 XcodeGen spec — source of truth for the .xcodeproj
├── Brief/
│   ├── BriefApp.swift          app entry, opens TypeSpecimenView
│   ├── Info.plist              registers Fonts/ via ATSApplicationFontsPath
│   ├── DesignSystem/
│   │   ├── BriefFont.swift     type tokens + .briefStyle modifier
│   │   ├── BriefColor.swift    warm-paper + highlighter-trace color tokens
│   │   ├── BriefSource.swift   the 8 Connection sources
│   │   └── …                   BriefIcon, ProvenanceTag
│   ├── Mocks/                  Live Context loader + Codable models
│   │   ├── LiveContextStore.swift      loads + merges all sources into one timeline
│   │   ├── LiveContextEvent.swift      common envelope protocol + source tag
│   │   ├── MeetingModels.swift         voice (meeting + transcript)
│   │   ├── MessageModels.swift         slack / gmail / chrome / github / cursor
│   │   ├── LinearModels.swift          linear (issue / comment / status)
│   │   ├── ReferenceModels.swift       persona / cast / notion / history rollup
│   │   └── LiveContextStore+Verify.swift  debug self-check (env-gated)
│   ├── Views/
│   │   └── TypeSpecimenView.swift  type system visual verification
│   └── Resources/
│       ├── Fonts/              Test Söhne + Test Family (otf)
│       ├── Icons/              source SVGs
│       └── Mocks/              mock Live Context data (jsonl + json + docs)
│           ├── _persona.json, _cast.json, notion-refs.json, history-rollup.json
│           ├── meetings/slack/chrome/gmail/linear/cursor/github .jsonl  (hot streams)
│           └── _research-dossier.md, _scenario-spine.md, _history-2mo.md  (docs)
```

## Build (XcodeGen)

The `.xcodeproj` is **generated** from `project.yml` — never hand-edited. Requires `xcodegen` (`brew install xcodegen`).

```sh
cd Brief
xcodegen generate          # (re)create Brief.xcodeproj from project.yml
open Brief.xcodeproj        # then ⌘R in Xcode
# — or build from CLI —
xcodebuild -project Brief.xcodeproj -scheme Brief -configuration Debug \
  -destination 'platform=macOS' build
```

Re-run `xcodegen generate` whenever you add/move files or edit `project.yml`. Fonts, Icons, and Mocks are copied into the app bundle as folder references (declared in `project.yml`).

You should see the type specimen window open with all tokens rendered.

## Mock Live Context data

`Resources/Mocks/` holds the prototype's data: a fictional persona (Dani Reyes, Head of Product) and her two-day + two-month Live Context across 8 sources. Storage is **one append-only stream per source** (mirroring Highlight's per-Connection MCP architecture); `LiveContextStore` merges them into a single time-sorted timeline at load. See `Resources/Mocks/_scenario-spine.md` for the story and `_research-dossier.md` for the real-world grounding.

To self-check that the data decodes cleanly (counts, sort order, reference resolution):

```sh
BRIEF_VERIFY_MOCKS=1 \
  "$(xcodebuild -project Brief.xcodeproj -scheme Brief -showBuildSettings \
     | awk -F' = ' '/BUILT_PRODUCTS_DIR/{print $2; exit}')/Brief.app/Contents/MacOS/Brief"
```

Prints a summary to stderr and exits 0 if there are no load errors.

## Type token reference

See `DesignSystem/BriefFont.swift` and the spec in
`~/.claude/projects/-Users-ilwonyoon-Documents-highlight-live-context/memory/project_typography_research.md`.

## Notes

- Test fonts have no OpenType features and a limited character set (`A-Z a-z 0-9 .,-`). Mockup copy avoids special characters.
- Font PostScript names include the `Test` prefix while using test fonts. When licensed, swap names in `BriefFont.swift`.
- macOS native controls (sidebar, menubar, popovers) should retain SF Pro — Söhne enters at the content layer only.
