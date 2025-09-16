import HaishinKit
import SwiftUI

@MainActor
final class PreferenceViewModel: ObservableObject {
    @Published var showIngestSheet: Bool = false

    var uri: String = Preference.default.uri
    var streamName: String = Preference.default.streamName

    private(set) var bitRateModes: [VideoCodecSettings.BitRateMode] = [.average]

    // MARK: - AudioCodecSettings.
    @Published var audioFormat: AudioCodecSettings.Format = .aac

    // MARK: - VideoCodecSettings.
    @Published var bitRateMode: VideoCodecSettings.BitRateMode = .average
    var isLowLatencyRateControlEnabled: Bool = false

    init() {
        if #available(iOS 16.0, *) {
            bitRateModes.append(.constant)
        }
    }

    @MainActor
    func config(uri: String, streamName: String) {
        self.uri = uri
        self.streamName = streamName
    }
    
    func makeVideoCodecSettings(_ settings: VideoCodecSettings) -> VideoCodecSettings {
        var newSettings = settings
        newSettings.bitRateMode = bitRateMode
        newSettings.isLowLatencyRateControlEnabled = isLowLatencyRateControlEnabled
        return newSettings
    }

    func makeAudioCodecSettings(_ settings: AudioCodecSettings) -> AudioCodecSettings {
        var newSettings = settings
        newSettings.format = audioFormat
        return newSettings
    }

    func makeURL() -> URL? {
        if uri.contains("rtmp://") {
            return URL(string: uri + "/" + streamName)
        }
        return URL(string: uri)
    }
}
