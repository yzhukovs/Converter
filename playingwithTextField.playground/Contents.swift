import UIKit
import PlaygroundSupport
import SwiftUI


 // Make a SwiftUI view
 struct ContentView: View {
    @State public var  someNumber = 0.0
    @State public var text2 = 0.0
     var body: some View {
        let someNumberProxy = Binding<String>(
            get: { String(format: "%.02f", Double(self.someNumber)) },
            set: {
                if let value = NumberFormatter().number(from: $0) {
                    self.someNumber = value.doubleValue
                }
            }
        )

        return VStack {
            TextField("Number", text: someNumberProxy)

            Text("number: \(someNumber)")
        }
     }
}

func formatTime(time:Double)-> String {
       let minutes = Int(time) / 60
       let seconds = Double(Int(time) % 60) + time - Double(Int(time))
       
       return "\(minutes):\(NSString(format: "%2.2f", seconds))"
       
   }


let viewController = UIHostingController(rootView: ContentView())
let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 668, height: 942))
window.makeKeyAndVisible()
window.rootViewController = viewController
PlaygroundPage.current.liveView = window
PlaygroundPage.current.needsIndefiniteExecution = true
