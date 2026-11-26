//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

#if os(macOS)
import Foundation
import StreamWebRTC

// SPIKE (native macOS port).
//
// StreamWebRTC 156.0.7's macOS slice compiles Stream's rendering additions
// but does not export their headers (`mac_framework_objc` in
// GetStream/webrtc sdk/BUILD.gn has a fixed header list without the
// `stream_enable_rendering_backend` block). Mirror the two enums here so
// the public `VideoRenderingOptions` API exists on macOS. Remove once the
// headers ship in the macOS slice.

/// Mirrors `RTCVideoRenderingBackend` (RTCVideoRenderingView.h).
public enum RTCVideoRenderingBackend: Int, Sendable, CustomStringConvertible {
    case `default` = 0
    case sharedMetal = 1

    public var description: String {
        switch self {
        case .default: return ".default"
        case .sharedMetal: return ".sharedMetal"
        }
    }
}

/// Mirrors `RTCFrameBufferPolicy` (RTCPeerConnectionFactory+Stream.h).
public enum RTCFrameBufferPolicy: Int, Sendable, CustomStringConvertible {
    case none = 0
    case wrapOnlyExistingNV12 = 1
    case copyToNV12 = 2
    case convertWithPoolToNV12 = 3

    public var description: String {
        switch self {
        case .none: return ".none"
        case .wrapOnlyExistingNV12: return ".wrapOnlyExistingNV12"
        case .copyToNV12: return ".copyToNV12"
        case .convertWithPoolToNV12: return ".convertWithPoolToNV12"
        }
    }
}

extension RTCPeerConnectionFactory {
    /// The macOS binary implements `-[RTCPeerConnectionFactory setFrameBufferPolicy:]`
    /// (the selector is present in the slice), only the header is missing.
    /// Set it through KVC until the header is exported.
    var frameBufferPolicy: RTCFrameBufferPolicy {
        get {
            guard responds(to: NSSelectorFromString("frameBufferPolicy")),
                  let raw = value(forKey: "frameBufferPolicy") as? Int,
                  let policy = RTCFrameBufferPolicy(rawValue: raw)
            else { return .none }
            return policy
        }
        set {
            guard responds(to: NSSelectorFromString("setFrameBufferPolicy:")) else { return }
            setValue(newValue.rawValue, forKey: "frameBufferPolicy")
        }
    }
}
#endif
