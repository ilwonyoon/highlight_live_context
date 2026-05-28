import CoreGraphics

// MARK: - Spacing scale
// 4-base scale. Use these tokens instead of raw numbers in views.
// Naming is t-shirt (xxs..3xl) so semantic intent reads consistently.

enum BriefSpacing {
    static let xxs: CGFloat =  2
    static let xs:  CGFloat =  4
    static let sm:  CGFloat =  6
    static let md:  CGFloat =  8
    static let lg:  CGFloat = 12
    static let xl:  CGFloat = 16
    static let xxl: CGFloat = 20
    static let xxxl: CGFloat = 28
    static let huge: CGFloat = 40
    static let mega: CGFloat = 56

    /// Indent for content aligned to an 11pt icon + sm gap.
    /// Used when a label below a header needs to align under the source label.
    static let iconIndent: CGFloat = 11 + sm
}
