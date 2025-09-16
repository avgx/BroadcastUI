import AVFoundation
import RTMPHaishinKit
import Combine
import HaishinKit
import Logging
import SwiftUI
import VideoToolbox

final class ViewModel: ObservableObject {
//    let maxRetryCount: Int = 5
//    static let logger = Logger(label: "broadcast")
//    
//    private var uri: String = ""
//    private var streamName: String = ""
//    
//    private var rtmpConnection = RTMPConnection()
//    @Published var rtmpStream: RTMPStream!
//    private var sharedObject: RTMPSharedObject!
//    @Published var currentPosition: AVCaptureDevice.Position = .back
//    private var retryCount: Int = 0
    @Published var published = false
    @Published var zoomLevel: CGFloat = 1.0
    @Published var videoRate = CGFloat(VideoCodecSettings.default.bitRate / 1000)
    @Published var audioRate = CGFloat(AudioCodecSettings.default.bitRate / 1000)
    @Published var fps: String = ""
//    private var nc = NotificationCenter.default
//
//    var subscriptions = Set<AnyCancellable>()
//
//    var frameRate: String = "30.0" {
//        willSet {
//            rtmpStream.frameRate = Float64(newValue) ?? 30.0
//            objectWillChange.send()
//        }
//    }
//
//    var frameRateData = ["15.0", "30.0", "60.0"]
//
//    @MainActor
//    func config(uri: String, streamName: String) {
//        self.uri = uri
//        self.streamName = streamName
//        rtmpStream = RTMPStream(connection: rtmpConnection)
//        rtmpStream.videoMixerSettings.mode = .offscreen
//        rtmpStream.screen.startRunning()
//        if let orientation = DeviceUtil.videoOrientation(by: UIDevice.current.orientation) {
//            rtmpStream.videoOrientation = orientation
//        }
//        rtmpStream.sessionPreset = .hd1280x720
//        rtmpStream.videoSettings.videoSize = .init(width: 1280, height: 720)
//        nc.publisher(for: UIDevice.orientationDidChangeNotification, object: nil)
//            .sink { [weak self] _ in
//                guard let orientation = DeviceUtil.videoOrientation(by: UIDevice.current.orientation), let self = self else {
//                    return
//                }
//                self.rtmpStream.videoOrientation = orientation
//            }
//            .store(in: &subscriptions)
//    }
//
//    var task: Task<Void, Never>? = nil
//    
//    func registerForPublishEvent() {
//        rtmpStream.attachAudio(AVCaptureDevice.default(for: .audio)) { _, error in
//            if let error {
//                Self.logger.error("\(error)")
//            }
//        }
//        rtmpStream.attachCamera(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentPosition)) { _, error  in
//            if let error {
//                Self.logger.error("\(error)")
//            }
//        }
//        
//        nc.publisher(for: AVAudioSession.interruptionNotification, object: nil)
//            .sink { notification in
//                Self.logger.info("\(notification)")
//            }
//            .store(in: &subscriptions)
//
//        nc.publisher(for: AVAudioSession.routeChangeNotification, object: nil)
//            .sink { notification in
//                Self.logger.info("\(notification)")
//            }
//            .store(in: &subscriptions)
//    }
//
//    func unregisterForPublishEvent() {
//        rtmpStream.close()
//    }
//
//    @MainActor
    func startPublish() {
//        UIApplication.shared.isIdleTimerDisabled = true
//        Self.logger.info("connect \(uri)")
//
//        rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
//        rtmpConnection.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
//        rtmpConnection.connect(uri)
//        
//        self.task = Task { @MainActor [weak self] in
//            while true {
//                try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
//                if Task.isCancelled {
//                    break
//                }
//                
//                if let info = self?.rtmpStream.info {
//                    self?.fps = "\(info.currentBytesPerSecond/1024)kB/s"
//                }
//            }
//            self?.fps = ""
//        }
    }
//
    @MainActor
    func stopPublish() {
//        UIApplication.shared.isIdleTimerDisabled = false
//        rtmpConnection.close()
//        rtmpConnection.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
//        rtmpConnection.removeEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
//        
//        self.task?.cancel()
    }
//
    func toggleTorch() {
//        rtmpStream.torch.toggle()
    }
//
    func pausePublish() {
//        rtmpStream.paused.toggle()
    }
//
    @MainActor
    func tapScreen(touchPoint: CGPoint) {
//        let pointOfInterest = CGPoint(x: touchPoint.x / UIScreen.main.bounds.size.width, y: touchPoint.y / UIScreen.main.bounds.size.height)
//        Self.logger.info("pointOfInterest: \(pointOfInterest)")
//        guard
//            let device = rtmpStream.videoCapture(for: 0)?.device, device.isFocusPointOfInterestSupported else {
//            return
//        }
//        do {
//            try device.lockForConfiguration()
//            device.focusPointOfInterest = pointOfInterest
//            device.focusMode = .continuousAutoFocus
//            device.unlockForConfiguration()
//        } catch let error as NSError {
//            Self.logger.error("while locking device for focusPointOfInterest: \(error)")
//        }
    }
//
    func rotateCamera() {
//        let position: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
//        rtmpStream.attachCamera(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)) { _, error  in
//            Self.logger.error("\(error)")
//        }
//        currentPosition = position
    }
//
    func changeZoomLevel(level: CGFloat) {
//        guard let device = rtmpStream.videoCapture(for: 0)?.device, 1 <= level && level < device.activeFormat.videoMaxZoomFactor else {
//            return
//        }
//        do {
//            try device.lockForConfiguration()
//            device.ramp(toVideoZoomFactor: level, withRate: 5.0)
//            device.unlockForConfiguration()
//        } catch let error as NSError {
//            Self.logger.error("while locking device for ramp: \(error)")
//        }
    }
//
    func changeVideoRate(level: CGFloat) {
//        rtmpStream.videoSettings.bitRate = Int(level * 1000)
    }
//
    func changeAudioRate(level: CGFloat) {
//        rtmpStream.audioSettings.bitRate = Int(level * 1000)
    }
//
//    @objc
//    private func rtmpStatusHandler(_ notification: Notification) {
//        let e = Event.from(notification)
//        guard let data: ASObject = e.data as? ASObject, let code: String = data["code"] as? String else {
//            return
//        }
//        Self.logger.info("rtmpStatus \(code)")
//        DispatchQueue.main.async { [weak self] in
//            self?.fps = code
//        }
//        
//        switch code {
//        case RTMPConnection.Code.connectSuccess.rawValue:
//            retryCount = 0
//            rtmpStream.publish(streamName)
//        // sharedObject!.connect(rtmpConnection)
//        case RTMPConnection.Code.connectFailed.rawValue, RTMPConnection.Code.connectClosed.rawValue:
//            guard retryCount <= maxRetryCount else {
//                return
//            }
//            Thread.sleep(forTimeInterval: pow(2.0, Double(retryCount)))
//            rtmpConnection.connect(uri)
//            retryCount += 1
//        default:
//            break
//        }
//    }
//
//    @objc
//    private func rtmpErrorHandler(_ notification: Notification) {
//        Self.logger.error("\(notification)")
//        rtmpConnection.connect(uri)
//    }
}
