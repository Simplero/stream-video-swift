//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import CoreMedia
import CoreVideo
import Foundation
import StreamWebRTC

/// Frames for a screen share the app captures itself (``ScreensharingType/external``).
///
/// Start the share with `call.startScreensharing(type: .external)`, then call
/// ``push(_:timeStampNs:)`` for every captured frame. Frames pushed while no
/// external share runs are dropped.
public final class ExternalScreenShareSource: @unchecked Sendable {
    public static let shared = ExternalScreenShareSource()

    private struct Session {
        var videoCapturer: RTCVideoCapturer
        var videoCapturerDelegate: RTCVideoCapturerDelegate
    }

    private let lock = NSLock()
    private var session: Session?

    init() {}

    /// Whether a call is sending the frames pushed now.
    public var isActive: Bool {
        lock.lock(); defer { lock.unlock() }
        return session != nil
    }

    /// Sends one frame. `timeStampNs` is the capture time in nanoseconds.
    public func push(_ pixelBuffer: CVPixelBuffer, timeStampNs: Int64) {
        lock.lock()
        let session = self.session
        lock.unlock()
        guard let session else { return }
        let frame = RTCVideoFrame(
            buffer: RTCCVPixelBuffer(pixelBuffer: pixelBuffer),
            rotation: ._0,
            timeStampNs: timeStampNs
        )
        session.videoCapturerDelegate.capturer(session.videoCapturer, didCapture: frame)
    }

    /// Sends one frame from a capture sample buffer (its presentation time is the time stamp).
    public func push(_ sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        push(pixelBuffer, timeStampNs: Int64(CMTimeGetSeconds(time) * Double(NSEC_PER_SEC)))
    }

    func start(videoCapturer: RTCVideoCapturer, videoCapturerDelegate: RTCVideoCapturerDelegate) {
        lock.lock(); defer { lock.unlock() }
        session = .init(videoCapturer: videoCapturer, videoCapturerDelegate: videoCapturerDelegate)
    }

    func stop() {
        lock.lock(); defer { lock.unlock() }
        session = nil
    }
}

/// Connects ``ExternalScreenShareSource`` to the screen share capturer.
final class ExternalScreenShareCaptureHandler: StreamVideoCapturerActionHandler, @unchecked Sendable {
    private let source: ExternalScreenShareSource

    init(source: ExternalScreenShareSource) {
        self.source = source
    }

    func handle(_ action: StreamVideoCapturer.Action) async throws {
        switch action {
        case let .startCapture(_, _, _, _, videoCapturer, videoCapturerDelegate, _):
            source.start(videoCapturer: videoCapturer, videoCapturerDelegate: videoCapturerDelegate)
        case .stopCapture:
            source.stop()
        default:
            break
        }
    }
}
