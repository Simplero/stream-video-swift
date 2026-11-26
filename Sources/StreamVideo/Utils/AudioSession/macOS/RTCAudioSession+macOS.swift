//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

#if os(macOS)
import AVFoundation
import Foundation

// SPIKE (native macOS port).
//
// StreamWebRTC's macOS slice does not ship `RTCAudioSession`,
// `RTCAudioSessionConfiguration` or `RTCAudioSessionDelegate` (upstream
// WebRTC builds `audio_session_objc` only under `is_ios`). On macOS the ADM
// (AudioEngineDevice / audio_device_mac) talks to Core Audio directly and
// never consults an audio session. These stand-ins keep RTCAudioStore's
// reducers compiling; they store values and never fail.

protocol RTCAudioSessionDelegate: AnyObject {
    func audioSessionDidBeginInterruption(_ session: RTCAudioSession)
    func audioSessionDidEndInterruption(_ session: RTCAudioSession, shouldResumeSession: Bool)
    func audioSessionDidChangeRoute(
        _ session: RTCAudioSession,
        reason: AVAudioSession.RouteChangeReason,
        previousRoute: AVAudioSessionRouteDescription
    )
    func audioSessionMediaServerReset(_ session: RTCAudioSession)
}

extension RTCAudioSessionDelegate {
    func audioSessionDidBeginInterruption(_ session: RTCAudioSession) {}
    func audioSessionDidEndInterruption(_ session: RTCAudioSession, shouldResumeSession: Bool) {}
    func audioSessionDidChangeRoute(
        _ session: RTCAudioSession,
        reason: AVAudioSession.RouteChangeReason,
        previousRoute: AVAudioSessionRouteDescription
    ) {}
    func audioSessionMediaServerReset(_ session: RTCAudioSession) {}
}

final class RTCAudioSessionConfiguration: NSObject, @unchecked Sendable {
    var category: String = AVAudioSession.Category.playAndRecord.rawValue
    var categoryOptions: AVAudioSession.CategoryOptions = [.allowBluetoothHFP, .defaultToSpeaker]
    var mode: String = AVAudioSession.Mode.voiceChat.rawValue
    var sampleRate: Double = 48000
    var ioBufferDuration: TimeInterval = 0.01
    var inputNumberOfChannels: Int = 1
    var outputNumberOfChannels: Int = 1

    private static var _webRTC = RTCAudioSessionConfiguration()

    static func current() -> RTCAudioSessionConfiguration { RTCAudioSessionConfiguration() }
    static func webRTC() -> RTCAudioSessionConfiguration { _webRTC }
    static func setWebRTC(_ configuration: RTCAudioSessionConfiguration) { _webRTC = configuration }
}

final class RTCAudioSession: NSObject, @unchecked Sendable {
    private static let shared = RTCAudioSession()
    static func sharedInstance() -> RTCAudioSession { shared }

    let session: AVAudioSession = .sharedInstance()
    private(set) var isActive: Bool = false
    var useManualAudio: Bool = false
    var isAudioEnabled: Bool = false
    var category: String { session.category.rawValue }
    var mode: String { session.mode.rawValue }
    var categoryOptions: AVAudioSession.CategoryOptions { session.categoryOptions }
    var currentRoute: AVAudioSessionRouteDescription { session.currentRoute }
    var maximumOutputNumberOfChannels: Int { session.maximumOutputNumberOfChannels }
    var outputNumberOfChannels: Int { session.outputNumberOfChannels }

    private let delegates = NSHashTable<AnyObject>.weakObjects()
    private let lock = NSRecursiveLock()

    func add(_ delegate: RTCAudioSessionDelegate) { delegates.add(delegate) }
    func remove(_ delegate: RTCAudioSessionDelegate) { delegates.remove(delegate) }
    func lockForConfiguration() { lock.lock() }
    func unlockForConfiguration() { lock.unlock() }

    func setActive(_ active: Bool) throws { isActive = active }

    func setCategory(
        _ category: AVAudioSession.Category,
        mode: AVAudioSession.Mode,
        options: AVAudioSession.CategoryOptions
    ) throws {
        try session.setCategory(category, mode: mode, options: options)
    }

    func setMode(_ mode: AVAudioSession.Mode) throws { try session.setMode(mode) }
    func overrideOutputAudioPort(_ port: AVAudioSession.PortOverride) throws {}
    func setPreferredOutputNumberOfChannels(_ noOfChannels: Int) throws {
        try session.setPreferredOutputNumberOfChannels(noOfChannels)
    }

    func setConfiguration(_ configuration: RTCAudioSessionConfiguration) throws {
        try session.setCategory(
            .init(rawValue: configuration.category),
            mode: .init(rawValue: configuration.mode),
            options: configuration.categoryOptions
        )
    }

    func audioSessionDidActivate(_ audioSession: AVAudioSession) { isActive = true }
    func audioSessionDidDeactivate(_ audioSession: AVAudioSession) { isActive = false }
}
#endif
