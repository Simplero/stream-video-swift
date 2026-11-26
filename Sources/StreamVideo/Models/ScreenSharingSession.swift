//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamWebRTC

public struct ScreenSharingSession {
    public let track: RTCVideoTrack?
    public let participant: CallParticipant
}

public enum ScreensharingType: Sendable {
    /// Screensharing only the app window.
    case inApp
    /// Screensharing even when the app is in background.
    case broadcast
    /// The app captures the frames itself (for example with ScreenCaptureKit
    /// on macOS) and hands them to ``ExternalScreenShareSource/shared``.
    case external
}
