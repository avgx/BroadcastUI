import AVFoundation
import RTMPHaishinKit
import HaishinKit
import SwiftUI
import VideoToolbox
import Logging

struct Preference: Sendable {
    // Temp
    static nonisolated(unsafe) var `default` = Preference()

    var uri: String = "rtmp://192.168.1.6/live"
    var streamName: String = "live"

    func makeURL() -> URL? {
        if uri.contains("rtmp://") {
            return URL(string: uri + "/" + streamName)
        }
        return URL(string: uri)
    }
}


public struct BroadcastUI: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var initDone = false
    @State private var preference = PreferenceViewModel()
//    @ObservedObject var viewModel = ViewModel()
//
//    private var lfView: MTHKSwiftUiView!
//    private var menuView: MenuView!

    /// uri = rtmp://my.cloud.com/live
    /// streamName = 69789EB7-3D44-4BD4-8499-B8D71D758343
    public init(uri: String, streamName: String) {
        preference.config(uri: uri, streamName: streamName)
//        lfView = MTHKSwiftUiView(rtmpStream: $viewModel.rtmpStream)
//        menuView = MenuView(viewModel: viewModel)
//        Preference.default.uri = uri
//        Preference.default.streamName = streamName
    }

    public var body: some View {
        if initDone {
            IngestView()
                .environmentObject(preference)
        } else {
            ProgressView()
            .onAppear {
                Task {
                    await SessionBuilderFactory.shared.register(RTMPSessionFactory())
                    await MainActor.run {
                        initDone = true
                    }
                }
            }
        }
//        ZStack {
//            lfView
//                .ignoresSafeArea()
//                .onTapGesture { location in
//                    self.viewModel.tapScreen(touchPoint: location)
//                }
//
//            menuView
//        }
//        .onAppear {
//            ViewModel.logger.info("UI onAppear")
//            self.viewModel.registerForPublishEvent()
//        }
//        .onDisappear {
//            ViewModel.logger.info("UI onDisappear")
//            self.viewModel.unregisterForPublishEvent()
//        }
//        .onChange(of: scenePhase) { newValue in
//            switch newValue {
//            case .active:
//                ViewModel.logger.info("UI active")
//            default:
//                ViewModel.logger.info("UI not active")
//            }
//        }
    }
}

#Preview {
    BroadcastUI(uri: "rtmp://192.168.1.6/live", streamName: "app")
}
