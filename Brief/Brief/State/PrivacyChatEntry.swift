import Foundation

// MARK: - PrivacyChatEntry — where the privacy chat was opened FROM
//
// The same chat surface serves several jobs. What it should say first, and what
// the composer invites you to type, depends on where you came from: the global
// shield, a "+ Add app or site" button, "+ Add a filter", or a specific filter
// row you want to edit. The entry point is captured once here and threaded into
// PrivacyScenario so the opening turns and placeholder match the user's intent.
//
//   shield / Live Context   → .global
//   "+ Add app or site"     → .addAppSite
//   "+ Add a filter"        → .addTopicFilter
//   a filter row's edit     → .editFilter(id:)

enum PrivacyChatEntry: Equatable {
    case global
    case addAppSite
    case addTopicFilter
    case editFilter(id: UUID)
}
