import AVFoundation
import HaishinKit
import SwiftUI
import VideoToolbox
import Logging

public struct BroadcastUI: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @ObservedObject var viewModel = ViewModel()

    private var lfView: MTHKSwiftUiView!
    private var menuView: MenuView!

    /// uri = rtmp://my.cloud.com/live
    /// streamName = 69789EB7-3D44-4BD4-8499-B8D71D758343
    public init(uri: String, streamName: String) {
        viewModel.config(uri: uri, streamName: streamName)
        lfView = MTHKSwiftUiView(rtmpStream: $viewModel.rtmpStream)
        menuView = MenuView(viewModel: viewModel)
    }

    public var body: some View {
        ZStack {
            lfView
                .ignoresSafeArea()
                .onTapGesture { location in
                    self.viewModel.tapScreen(touchPoint: location)
                }

            menuView
        }
        .onAppear {
            ViewModel.logger.info("UI onAppear")
            self.viewModel.registerForPublishEvent()
        }
        .onDisappear {
            ViewModel.logger.info("UI onDisappear")
            self.viewModel.unregisterForPublishEvent()
        }
        .onChange(of: scenePhase) { newValue in
            switch newValue {
            case .active:
                ViewModel.logger.info("UI active")
            default:
                ViewModel.logger.info("UI not active")
            }
        }
    }
}
