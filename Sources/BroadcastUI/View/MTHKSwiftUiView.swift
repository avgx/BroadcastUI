import Foundation
import HaishinKit
import SwiftUI

struct MTHKSwiftUiView: UIViewRepresentable {
    protocol PreviewSource {
        func connect(to view: MTHKView)
    }

    typealias UIViewType = MTHKView

    let previewSource: PreviewSource
    private var view = MTHKView(frame: .zero)

    init(previewSource: PreviewSource) {
        self.previewSource = previewSource
    }

    func makeUIView(context: Context) -> MTHKView {
        previewSource.connect(to: view)
        return view
    }

    func updateUIView(_ uiView: MTHKView, context: Context) {
    }
}
