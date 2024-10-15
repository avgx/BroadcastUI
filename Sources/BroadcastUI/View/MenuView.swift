import Combine
import Foundation
import SwiftUI

struct TopMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresented) private var isPresented
    
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            if isPresented {
                HStack(spacing: 16) {
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .imageScale(.small)
                            .foregroundColor(Color.white)
                            .padding()
                            .background(Capsule().fill(Color.white.opacity(0.2)))
                            .clipShape(Rectangle())
                    }
                }
            }
            
            HStack(spacing: 16) {
                Text(viewModel.fps)
                    .padding(viewModel.fps.isEmpty ? 0 : 8)
                    .foregroundColor(Color.white)
                    .background(Capsule().fill(Color.white.opacity(0.2)))
            }
        }
    }
}

struct BottomMenuView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            VStack(spacing: 40) {
                VStack(spacing: -6) {
                    HStack {
                        Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                            .resizable()
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                        Slider(
                            value: $viewModel.zoomLevel,
                            in: 1...5,
                            step: 1,
                            onEditingChanged: { value in
                                print("zoom level", value)
                                viewModel.changeZoomLevel(level: viewModel.zoomLevel)
                            }
                        )
                    }
                }

                HStack(alignment: .center) {
                    Spacer()
                    
                    Button(action: {
                        self.viewModel.toggleTorch()
                    }, label: {
                        Image(systemName: "flashlight.on.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(Color.white)
                            .clipShape(Rectangle())
                    })
                    
                    
                    Spacer()
                    
                    CameraButton(style: CameraButtonStyle.recording(.constant(self.viewModel.published)), action: {
                        self.viewModel.published.toggle()

                        if self.viewModel.published {
                            self.viewModel.startPublish()
                        } else {
                            self.viewModel.stopPublish()
                        }
                    })

                    Spacer()
                    
                    Button(action: {
                        self.viewModel.rotateCamera()
                    }, label: {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.camera.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(Color.white)
                            .clipShape(Rectangle())
                    })
                    
                    
                    Spacer()
                    
                }
            }
        }
    }
}

struct MenuView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            TopMenuView(viewModel: viewModel)

            Spacer()

            BottomMenuView(viewModel: viewModel)
        }
        .padding()
    }
}
