import SwiftUI

enum AnimationTokens {
    /// Standard spring — sidebar toggles, panel switches, toolbar appear
    static let standard = Animation.spring(response: 0.35, dampingFraction: 0.85)

    /// Snappy spring — floating toolbar, tooltips, quick interactions
    static let snappy = Animation.spring(response: 0.25, dampingFraction: 0.8)

    /// Gentle spring — focus mode, view mode transitions
    static let gentle = Animation.spring(response: 0.5, dampingFraction: 0.9)

    /// Bouncy spring — celebratory moments (word count goal reached)
    static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)

    /// Fade in — content appearing
    static let fadeIn = Animation.easeOut(duration: 0.2)

    /// Fade out — content disappearing
    static let fadeOut = Animation.easeIn(duration: 0.15)

    /// Color transition — hover states, selection changes
    static let colorTransition = Animation.easeInOut(duration: 0.15)

    // MARK: - Durations

    static let staggerDelay: Double = 0.05
    static let ghostTextCharDelay: Double = 0.01
    static let debounceInterval: Double = 0.25
    static let autosaveInterval: Double = 30.0
    static let ghostTextPause: Double = 1.5
}
