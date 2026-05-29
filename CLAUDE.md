# Brief — project instructions

## Interaction

- **Do NOT use the AskUserQuestion tool in this repo.** When you need a
  decision from Ilwon, just write the options/question inline in your reply as
  plain text and let him answer in chat. No multiple-choice tool UI.

## Project

SwiftUI macOS app (`Brief/`) for the Highlight take-home — reframed as the
**Brief**, a Chief-of-Staff briefing surface over the user's **Live Context**.
Build with XcodeGen (`cd Brief && xcodegen generate`), then
`xcodebuild -project Brief.xcodeproj -scheme Brief -configuration Debug -destination 'platform=macOS' build`.

Design decisions, naming, scope, and window-chrome rules live in the auto-memory
under `~/.claude/projects/-Users-ilwonyoon-Documents-highlight-live-context/memory/`.
