//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVFoundation
import CallKit
import Combine
import CoreImage
import Foundation
import StreamWebRTC

#if compiler(<6.2)
extension CIContext: @retroactive @unchecked Sendable {}
extension CIImage: @retroactive @unchecked Sendable {}
#endif

#if compiler(>=6.0)
extension AnyCancellable: @retroactive @unchecked Sendable {}
extension AVCaptureDevice: @retroactive @unchecked Sendable {}
extension AVCapturePhotoOutput: @retroactive @unchecked Sendable {}
extension AVCaptureVideoDataOutput: @retroactive @unchecked Sendable {}
extension CMSampleBuffer: @retroactive @unchecked Sendable {}
#if os(iOS)
extension CXAnswerCallAction: @retroactive @unchecked Sendable {}
#endif
#if os(iOS)
extension CXSetHeldCallAction: @retroactive @unchecked Sendable {}
#endif
#if os(iOS)
extension CXSetMutedCallAction: @retroactive @unchecked Sendable {}
#endif
extension KeyPath: @retroactive @unchecked Sendable {}
extension RTCIceCandidate: @retroactive @unchecked Sendable {}
extension RTCMediaStreamTrack: @retroactive @unchecked Sendable {}
extension RTCSessionDescription: @retroactive @unchecked Sendable {}
extension RTCStatisticsReport: @retroactive @unchecked Sendable {}
extension WritableKeyPath: @retroactive @unchecked Sendable {}
extension Published.Publisher: @retroactive @unchecked Sendable {}
extension RTCVideoFrame: @retroactive @unchecked Sendable {}
extension AnyPublisher: @retroactive @unchecked Sendable {}
extension Publishers.Filter: @retroactive @unchecked Sendable {}
extension RTCVideoCapturer: @retroactive @unchecked Sendable {}
extension RTCVideoSource: @retroactive @unchecked Sendable {}
/// Allows audio buffers to cross concurrency boundaries.
extension AVAudioPCMBuffer: @retroactive @unchecked Sendable {}
extension AVCaptureDevice.Format: @retroactive @unchecked Sendable {}
#if os(iOS)
extension AVCaptureDevice.SystemPressureState: @retroactive @unchecked Sendable {}
#endif
#else
extension AnyCancellable: @unchecked Sendable {}
extension AVCaptureDevice: @unchecked Sendable {}
extension AVCapturePhotoOutput: @unchecked Sendable {}
extension AVCaptureVideoDataOutput: @unchecked Sendable {}
extension CMSampleBuffer: @unchecked Sendable {}
#if os(iOS)
extension CXAnswerCallAction: @unchecked Sendable {}
#endif
#if os(iOS)
extension CXSetHeldCallAction: @unchecked Sendable {}
#endif
#if os(iOS)
extension CXSetMutedCallAction: @unchecked Sendable {}
#endif
extension KeyPath: @unchecked Sendable {}
extension Notification: @unchecked Sendable {}
extension RTCIceCandidate: @unchecked Sendable {}
extension RTCMediaStreamTrack: @unchecked Sendable {}
extension RTCSessionDescription: @unchecked Sendable {}
extension RTCStatisticsReport: @unchecked Sendable {}
extension WritableKeyPath: @unchecked Sendable {}
extension Published.Publisher: @unchecked Sendable {}
extension RTCVideoFrame: @unchecked Sendable {}
extension AnyPublisher: @unchecked Sendable {}
extension Publishers.Filter: @unchecked Sendable {}
extension RTCVideoCapturer: @unchecked Sendable {}
extension RTCVideoSource: @unchecked Sendable {}
/// Allows audio buffers to cross concurrency boundaries.
extension AVAudioPCMBuffer: @unchecked Sendable {}
extension CIContext: @unchecked Sendable {}
extension CIImage: @unchecked Sendable {}
extension AVCaptureDevice.Format: @unchecked Sendable {}
#if os(iOS)
extension AVCaptureDevice.SystemPressureState: @unchecked Sendable {}
#endif
#endif
