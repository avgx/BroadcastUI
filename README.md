# BroadcastUI
SwiftUI view fo push rtmp stream via HaishinKit

### Example

```swift
struct ContentView: View {
    @State var show = false
    
    var body: some View {
        VStack {
            Button(action: { show.toggle() }, label: {
                Text("Broadcast")
            })
        }
        .fullScreenCover(isPresented: $show, onDismiss: {
            print("Streaming dismissed")
        }, content: {
            BroadcastUI(uri: "rtmp://x.rtmp.youtube.com/live2", streamName: "xxxx-xxxx-xxxx-xxxx-xxxx") 
        })
        
    }
}
```


