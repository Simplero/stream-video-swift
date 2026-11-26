//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVFoundation
import Foundation

final class CameraBackgroundAccessHandler: StreamVideoCapturerActionHandler {

    // MARK: - StreamVideoCapturerActionHandler

    func handle(_ action: StreamVideoCapturer.Action) async throws {
        #if os(macOS)
        // Multitasking camera access is an iPadOS concept.
        return
        #else
        guard #available(iOS 16, *) else {
            return
        }

        switch action {
        case let .checkBackgroundCameraAccess(videoCaptureSession)
            where videoCaptureSession.isMultitaskingCameraAccessSupported == true && videoCaptureSession
            .isMultitaskingCameraAccessEnabled == false:
            videoCaptureSession.beginConfiguration()
            videoCaptureSession.isMultitaskingCameraAccessEnabled = true
            videoCaptureSession.commitConfiguration()
        default:
            break
        }
        #endif
    }
}
