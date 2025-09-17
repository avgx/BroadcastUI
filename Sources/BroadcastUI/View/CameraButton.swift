import SwiftUI

public struct CameraButtonStyle: ButtonStyle {
    var fillStyle: any ShapeStyle = .foreground
    var borderStyle: any ShapeStyle = .white//.foreground
    var strokeStyle = StrokeStyle(
        lineWidth: 3,
        lineCap: .round,
        lineJoin: .round,
        miterLimit: 0
    )

    @Binding var isOn: Bool
    
    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle().strokeBorder(AnyShapeStyle(borderStyle), style: strokeStyle)
            
            RoundedRectangle(cornerRadius: isOn ? 8 : 40)
                .fill(AnyShapeStyle(fillStyle))
                .padding(isOn ? 24 : 8)
                .opacity(configuration.isPressed ? 0.5 : 1)
        }
        .frame(width: 80, height: 80)
        .animation(.spring, value: configuration.isPressed)
        .animation(.spring, value: isOn)
    }
}

extension CameraButtonStyle {
    fileprivate init() {
        self.init(isOn: .constant(false))
    }
}

extension CameraButtonStyle {

    public static var photo: CameraButtonStyle { CameraButtonStyle() }

    public static func recording(_ isOn: Binding<Bool>) -> CameraButtonStyle {
        CameraButtonStyle(fillStyle: .red, isOn: isOn)
    }
}

struct CameraButton: View {
    var style: CameraButtonStyle
    var action: () -> Void = { }
    var body: some View {
        Button(action: action) {
            // NO LABEL
        }
        .buttonStyle(style)
    }
}

#Preview {
    VStack {
        CameraButton(style: .recording(.constant(true)), action: { })
        
        CameraButton(style: .recording(.constant(false)), action: { })
    }
    .padding()
    .background(.black)    
}
