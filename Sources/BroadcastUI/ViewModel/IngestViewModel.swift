import AVFoundation
import HaishinKit
import SwiftUI
import Logging

@MainActor
final class IngestViewModel: ObservableObject {
    static let logger = Logger(label: "broadcast")
    @Published var currentFPS: FPS = .fps30
    @Published private(set) var error: Error?
    @Published var isShowError = false
    @Published private(set) var isTorchEnabled = false
    @Published private(set) var readyState: SessionReadyState = .closed
    @Published var audioSource: AudioSource = .empty {
        didSet {
            guard audioSource != oldValue else {
                return
            }
            selectAudioSource(audioSource)
        }
    }
    @Published private(set) var audioSources: [AudioSource] = []
    // If you want to use the multi-camera feature, please make create a MediaMixer with a capture mode.
    // let mixer = MediaMixer(captureSesionMode: .multi)
    private(set) var mixer = MediaMixer(captureSessionMode: .multi)
    private var tasks: [Task<Void, Swift.Error>] = []
    private var session: (any Session)?
    private var currentPosition: AVCaptureDevice.Position = .back
    private var audioSourceService = AudioSourceService()
    @ScreenActor private var videoScreenObject: VideoTrackScreenObject?
    @ScreenActor private var currentVideoEffect: VideoEffect?

    init() {
        Task { @ScreenActor in
            videoScreenObject = VideoTrackScreenObject()
        }
    }

    func startIngest(_ preference: PreferenceViewModel) {
        Task {
            guard let session else {
                return
            }
            do {
                try await session.connect {
                    Task { @MainActor in
                        self.isShowError = true
                    }
                }
            } catch {
                self.error = error
                self.isShowError = true
                Self.logger.error("\(error)")
            }
        }
    }

    func stopIngest() {
        Task {
            do {
                try await session?.close()
            } catch {
                Self.logger.error("\(error)")
            }
        }
    }

    func makeSession(_ preference: PreferenceViewModel) async {
        // Make session.
        do {
            session = try await SessionBuilderFactory.shared.make(preference.makeURL())
                .setMethod(.ingest)
                .build()
            guard let session else {
                return
            }
            await mixer.addOutput(session.stream)
            tasks.append(Task {
                for await readyState in await session.readyState {
                    self.readyState = readyState
                    switch readyState {
                    case .open:
                        UIApplication.shared.isIdleTimerDisabled = false
                    default:
                        UIApplication.shared.isIdleTimerDisabled = true
                    }
                }
            })
        } catch {
            self.error = error
            isShowError = true
        }
        do {
            if let session {
                try await session.stream.setAudioSettings(preference.makeAudioCodecSettings(session.stream.audioSettings))
            }
        } catch {
            self.error = error
            isShowError = true
        }
        do {
            if let session {
                try await session.stream.setVideoSettings(preference.makeVideoCodecSettings(session.stream.videoSettings))
            }
        } catch {
            self.error = error
            isShowError = true
        }
    }

    func startRunning(_ preference: PreferenceViewModel) {
        Task {
            await audioSourceService.setUp()
            await mixer.configuration { session in
                // It is required for the stereo setting.
                session.automaticallyConfiguresApplicationAudioSession = false
            }
            // SetUp a mixer.
            await mixer.setMonitoringEnabled(DeviceUtil.isHeadphoneConnected())
            var videoMixerSettings = await mixer.videoMixerSettings
            videoMixerSettings.mode = .offscreen
            await mixer.setVideoMixerSettings(videoMixerSettings)
            // Attach devices
            let back = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentPosition)
            try? await mixer.attachVideo(back, track: 0)
            let front = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            try? await mixer.attachVideo(front, track: 1) { videoUnit in
                videoUnit.isVideoMirrored = true
            }
            await mixer.startRunning()
            await makeSession(preference)
        }
        orientationDidChange()
        Task { @ScreenActor in
            guard let videoScreenObject else {
                return
            }
            videoScreenObject.cornerRadius = 16.0
            videoScreenObject.track = 1
            videoScreenObject.horizontalAlignment = .right
            videoScreenObject.layoutMargin = .init(top: 16, left: 0, bottom: 0, right: 16)
            videoScreenObject.size = .init(width: 160 * 2, height: 90 * 2)
            await mixer.screen.size = .init(width: 720, height: 1280)
            await mixer.screen.backgroundColor = UIColor.black.cgColor
            try? await mixer.screen.addChild(videoScreenObject)
        }
        Task {
            for await sources in await audioSourceService.sourcesUpdates() {
                audioSources = sources
                if let first = sources.first, audioSource == .empty {
                    audioSource = first
                }
            }
        }
    }

    func stopRunning() {
        Task {
            await mixer.stopRunning()
            try? await mixer.attachAudio(nil)
            try? await mixer.attachVideo(nil, track: 0)
            try? await mixer.attachVideo(nil, track: 1)
            if let session {
                await mixer.removeOutput(session.stream)
            }
            tasks.forEach { $0.cancel() }
            tasks.removeAll()
        }
    }

    func flipCamera() {
        Task {
            if await mixer.isMultiCamSessionEnabled {
                var videoMixerSettings = await mixer.videoMixerSettings
                if videoMixerSettings.mainTrack == 0 {
                    videoMixerSettings.mainTrack = 1
                    await mixer.setVideoMixerSettings(videoMixerSettings)
                    Task { @ScreenActor in
                        videoScreenObject?.track = 0
                    }
                } else {
                    videoMixerSettings.mainTrack = 0
                    await mixer.setVideoMixerSettings(videoMixerSettings)
                    Task { @ScreenActor in
                        videoScreenObject?.track = 1
                    }
                }
            } else {
                let position: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
                try? await mixer.attachVideo(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)) { videoUnit in
                    videoUnit.isVideoMirrored = position == .front
                }
                currentPosition = position
            }
        }
    }

    func setVisualEffet(_ videoEffect: VideoEffectItem) {
        Task { @ScreenActor in
            if let currentVideoEffect {
                _ = await mixer.screen.unregisterVideoEffect(currentVideoEffect)
            }
            if let videoEffect = videoEffect.makeVideoEffect() {
                currentVideoEffect = videoEffect
                _ = await mixer.screen.registerVideoEffect(videoEffect)
            }
        }
    }

    func toggleTorch() {
        Task {
            await mixer.setTorchEnabled(!isTorchEnabled)
            isTorchEnabled.toggle()
        }
    }

    func setFrameRate(_ fps: Float64) {
        Task {
            do {
                // Sets to input frameRate.
                try? await mixer.configuration(video: 0) { video in
                    do {
                        try video.setFrameRate(fps)
                    } catch {
                        Self.logger.error("\(error)")
                    }
                }
                try? await mixer.configuration(video: 1) { video in
                    do {
                        try video.setFrameRate(fps)
                    } catch {
                        Self.logger.error("\(error)")
                    }
                }
                // Sets to output frameRate.
                try await mixer.setFrameRate(fps)
            } catch {
                Self.logger.error("\(error)")
            }
        }
    }

    func orientationDidChange() {
        Task { @ScreenActor in
            if let orientation = await DeviceUtil.videoOrientation(by: UIApplication.shared.statusBarOrientation) {
                await mixer.setVideoOrientation(orientation)
            }
            if await UIDevice.current.orientation.isLandscape {
                await mixer.screen.size = .init(width: 1280, height: 720)
            } else {
                await mixer.screen.size = .init(width: 720, height: 1280)
            }
        }
    }

    private func selectAudioSource(_ audioSource: AudioSource) {
        Task {
            try await audioSourceService.selectAudioSource(audioSource)
            await mixer.stopCapturing()
            try await mixer.attachAudio(AVCaptureDevice.default(for: .audio))
            await mixer.startCapturing()
        }
    }
}

extension IngestViewModel: MTHKSwiftUiView.PreviewSource {
    nonisolated func connect(to view: HaishinKit.MTHKView) {
        Task {
            await mixer.addOutput(view)
        }
    }
}
