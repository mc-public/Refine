# Refine

![](https://img.shields.io/badge/Platform_Compatibility-iOS15.0+-blue)
![](https://img.shields.io/badge/Swift_Compatibility-5.8-red)

**Refine** is a framework for performing **single** handwritten mathematical symbol recognition on the iOS platform. It is based on [DeTeXt](https://github.com/venkatasg/DeTeXt).

### Getting Started

The usage of this framework is very simple. To use `Refine` in your own project, you need to set it up as a package dependency:
```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "MyPackage",
  dependencies: [
    .package(
      url: "https://github.com/mc-public/Refine.git", 
      .upToNextMinor)
    )
  ],
  targets: [
    .target(
      name: "MyTarget",
      dependencies: [
        .product(name: "Refine", package: "Refine")
      ]
    )
  ]
)
```

Then you need to use `PredictionCanvas` in `SwiftUI`.

```swift
import SwiftUI
import Refine

struct ContentView: View {
    @StateObject var state =  PredictionCanvasState()
    var body: some View {
        VStack {
            PredictionCanvas(state: self.state)
                .border(.blue)
            Divider()
            List {
                Button {
                    self.state.cleanCanvas(cleanResult: true)
                } label: {
                    Text("Clean Prediction Result")
                }
                ForEach.init(state.predictionResult, id: \.id) { symbol in
                    symbol.image
                }
            }
        }
        .padding()
    }
}
```
