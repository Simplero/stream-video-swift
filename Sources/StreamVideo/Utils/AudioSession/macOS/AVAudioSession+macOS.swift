//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

#if os(macOS)
import AVFoundation
import Foundation

// SPIKE (native macOS port).
//
// `AVAudioSession` and its route/port classes are `API_UNAVAILABLE(macos)`.
// macOS has no app-level audio session: the HAL (Core Audio) owns device
// selection and there is no category/mode/interruption model. The SDK's
// audio state machine (RTCAudioStore) is written against AVAudioSession
// values, so on macOS we shadow those types with module-internal stand-ins
// that hold values and do nothing. Declarations in this module win name
// lookup over the unavailable AVFAudio ones, so the iOS code compiles
// unchanged.
//
// Real macOS audio work (device list, default input/output, voice
// processing) belongs in the AudioDeviceModule / Core Audio layer, not here.

open class AVAudioSession: NSObject, @unchecked Sendable {

    // MARK: Nested value types (mirror AVFAudio's names)

    public struct Category: RawRepresentable, Hashable, Sendable {
        public var rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public init(_ rawValue: String) { self.rawValue = rawValue }

        public static let ambient = Category("AVAudioSessionCategoryAmbient")
        public static let soloAmbient = Category("AVAudioSessionCategorySoloAmbient")
        public static let playback = Category("AVAudioSessionCategoryPlayback")
        public static let record = Category("AVAudioSessionCategoryRecord")
        public static let playAndRecord = Category("AVAudioSessionCategoryPlayAndRecord")
        public static let multiRoute = Category("AVAudioSessionCategoryMultiRoute")
    }

    public struct Mode: RawRepresentable, Hashable, Sendable {
        public var rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public init(_ rawValue: String) { self.rawValue = rawValue }

        public static let `default` = Mode("AVAudioSessionModeDefault")
        public static let voiceChat = Mode("AVAudioSessionModeVoiceChat")
        public static let gameChat = Mode("AVAudioSessionModeGameChat")
        public static let videoRecording = Mode("AVAudioSessionModeVideoRecording")
        public static let measurement = Mode("AVAudioSessionModeMeasurement")
        public static let moviePlayback = Mode("AVAudioSessionModeMoviePlayback")
        public static let videoChat = Mode("AVAudioSessionModeVideoChat")
        public static let spokenAudio = Mode("AVAudioSessionModeSpokenAudio")
        public static let voicePrompt = Mode("AVAudioSessionModeVoicePrompt")
    }

    public struct CategoryOptions: OptionSet, Hashable, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }

        public static let mixWithOthers = CategoryOptions(rawValue: 0x1)
        public static let duckOthers = CategoryOptions(rawValue: 0x2)
        public static let allowBluetooth = CategoryOptions(rawValue: 0x4)
        public static let allowBluetoothHFP = CategoryOptions(rawValue: 0x4)
        public static let defaultToSpeaker = CategoryOptions(rawValue: 0x8)
        public static let interruptSpokenAudioAndMixWithOthers = CategoryOptions(rawValue: 0x11)
        public static let allowBluetoothA2DP = CategoryOptions(rawValue: 0x20)
        public static let allowAirPlay = CategoryOptions(rawValue: 0x40)
        public static let overrideMutedMicrophoneInterruption = CategoryOptions(rawValue: 0x80)
    }

    public enum PortOverride: UInt, Sendable {
        case none = 0
        case speaker = 0x73706B72
    }

    public enum RouteSharingPolicy: UInt, Sendable {
        case `default` = 0
        case longFormAudio = 1
        case independent = 2
        case longFormVideo = 3
    }

    public enum RenderingMode: Int, Sendable {
        case notApplicable = 0
        case monoStereo = 1
        case surround = 2
        case spatialAudio = 3
        case dolbyAudio = 4
        case dolbyAtmos = 5
    }

    public enum RouteChangeReason: UInt, Sendable {
        case unknown = 0
        case newDeviceAvailable = 1
        case oldDeviceUnavailable = 2
        case categoryChange = 3
        case override = 4
        case wakeFromSleep = 6
        case noSuitableRouteForCategory = 7
        case routeConfigurationChange = 8
    }

    public enum InterruptionType: UInt, Sendable {
        case began = 1
        case ended = 0
    }

    public struct InterruptionOptions: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let shouldResume = InterruptionOptions(rawValue: 1)
    }

    public enum RecordPermission: UInt, Sendable {
        case undetermined = 1970168948
        case denied = 1684369017
        case granted = 1735552628
    }

    public struct Port: RawRepresentable, Hashable, Sendable {
        public var rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public init(_ rawValue: String) { self.rawValue = rawValue }

        public static let lineIn = Port("LineIn")
        public static let builtInMic = Port("MicrophoneBuiltIn")
        public static let headsetMic = Port("MicrophoneWired")
        public static let lineOut = Port("LineOut")
        public static let headphones = Port("Headphones")
        public static let bluetoothA2DP = Port("BluetoothA2DPOutput")
        public static let builtInReceiver = Port("Receiver")
        public static let builtInSpeaker = Port("Speaker")
        public static let HDMI = Port("HDMIOutput")
        public static let airPlay = Port("AirPlay")
        public static let bluetoothLE = Port("BluetoothLE")
        public static let bluetoothHFP = Port("BluetoothHFP")
        public static let usbAudio = Port("USBAudio")
        public static let carAudio = Port("CarAudio")
        public static let virtual = Port("Virtual")
        public static let PCI = Port("PCI")
        public static let fireWire = Port("FireWire")
        public static let displayPort = Port("DisplayPort")
        public static let AVB = Port("AVB")
        public static let thunderbolt = Port("Thunderbolt")
    }

    // MARK: Notifications (never posted on macOS)

    public static let routeChangeNotification = Notification.Name("AVAudioSessionRouteChangeNotification")
    public static let interruptionNotification = Notification.Name("AVAudioSessionInterruptionNotification")
    public static let mediaServicesWereResetNotification = Notification.Name("AVAudioSessionMediaServicesWereResetNotification")
    public static let mediaServicesWereLostNotification = Notification.Name("AVAudioSessionMediaServicesWereLostNotification")
    public static let silenceSecondaryAudioHintNotification = Notification.Name("AVAudioSessionSilenceSecondaryAudioHintNotification")

    // MARK: Shared instance and state

    private static let shared = AVAudioSession()
    public static func sharedInstance() -> AVAudioSession { shared }

    public private(set) var category: Category = .soloAmbient
    public private(set) var mode: Mode = .default
    public private(set) var categoryOptions: CategoryOptions = []
    public private(set) var routeSharingPolicy: RouteSharingPolicy = .default
    public var availableModes: [Mode] { [.default, .voiceChat, .videoChat] }
    public private(set) var preferredInput: AVAudioSessionPortDescription?
    public var availableInputs: [AVAudioSessionPortDescription]? { [] }
    public var currentRoute: AVAudioSessionRouteDescription { AVAudioSessionRouteDescription() }
    public var maximumOutputNumberOfChannels: Int { 2 }
    public var maximumInputNumberOfChannels: Int { 1 }
    public var outputNumberOfChannels: Int { 2 }
    public var inputNumberOfChannels: Int { 1 }
    public private(set) var preferredOutputNumberOfChannels: Int = 2
    public var renderingMode: RenderingMode { .monoStereo }
    public var prefersEchoCancelledInput: Bool { true }
    public var isEchoCancelledInputEnabled: Bool { true }
    public var isEchoCancelledInputAvailable: Bool { true }
    public private(set) var prefersNoInterruptionsFromSystemAlerts: Bool = false
    public var isOtherAudioPlaying: Bool { false }
    public var secondaryAudioShouldBeSilencedHint: Bool { false }
    public var sampleRate: Double { 48000 }
    public var ioBufferDuration: TimeInterval { 0.01 }
    public var outputVolume: Float { 1 }
    public var recordPermission: RecordPermission {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized: return .granted
        case .notDetermined: return .undetermined
        default: return .denied
        }
    }

    public func requestRecordPermission(_ response: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio, completionHandler: response)
    }

    public func setCategory(_ category: Category, mode: Mode, options: CategoryOptions) throws {
        self.category = category
        self.mode = mode
        categoryOptions = options
    }

    public func setCategory(_ category: Category, mode: Mode, policy: RouteSharingPolicy, options: CategoryOptions) throws {
        try setCategory(category, mode: mode, options: options)
        routeSharingPolicy = policy
    }

    public func setCategory(_ category: Category, options: CategoryOptions) throws {
        try setCategory(category, mode: mode, options: options)
    }

    public func setCategory(_ category: Category) throws {
        try setCategory(category, mode: mode, options: categoryOptions)
    }

    public func setMode(_ mode: Mode) throws { self.mode = mode }
    public func setActive(_ active: Bool) throws {}
    public func setActive(_ active: Bool, options: UInt) throws {}
    public func overrideOutputAudioPort(_ portOverride: PortOverride) throws {}
    public func setPreferredInput(_ inPort: AVAudioSessionPortDescription?) throws { preferredInput = inPort }
    public func setPreferredOutputNumberOfChannels(_ count: Int) throws { preferredOutputNumberOfChannels = count }
    public func setPreferredInputNumberOfChannels(_ count: Int) throws {}
    public func setPrefersNoInterruptionsFromSystemAlerts(_ inValue: Bool) throws {
        prefersNoInterruptionsFromSystemAlerts = inValue
    }
    public func setPrefersEchoCancelledInput(_ value: Bool) throws {}
}

open class AVAudioSessionPortDescription: NSObject, @unchecked Sendable {
    public let portType: AVAudioSession.Port
    public let portName: String
    public let uid: String
    public var channels: [AnyObject]? { nil }
    public var dataSources: [AnyObject]? { nil }

    public init(portType: AVAudioSession.Port = .builtInMic, portName: String = "", uid: String = "") {
        self.portType = portType
        self.portName = portName
        self.uid = uid
    }
}

open class AVAudioSessionRouteDescription: NSObject, @unchecked Sendable {
    public let inputs: [AVAudioSessionPortDescription]
    public let outputs: [AVAudioSessionPortDescription]

    public init(
        inputs: [AVAudioSessionPortDescription] = [],
        outputs: [AVAudioSessionPortDescription] = []
    ) {
        self.inputs = inputs
        self.outputs = outputs
    }
}

public let AVAudioSessionRouteChangeReasonKey = "AVAudioSessionRouteChangeReasonKey"
public let AVAudioSessionRouteChangePreviousRouteKey = "AVAudioSessionRouteChangePreviousRouteKey"
public let AVAudioSessionInterruptionTypeKey = "AVAudioSessionInterruptionTypeKey"
public let AVAudioSessionInterruptionOptionKey = "AVAudioSessionInterruptionOptionKey"
#endif
