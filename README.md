# FakeSwiftUI

[![CI Status](https://img.shields.io/travis/youga/FakeSwiftUI.svg?style=flat)](https://travis-ci.org/youga/FakeSwiftUI)
[![Version](https://img.shields.io/cocoapods/v/FakeSwiftUI.svg?style=flat)](https://cocoapods.org/pods/FakeSwiftUI)
[![License](https://img.shields.io/cocoapods/l/FakeSwiftUI.svg?style=flat)](https://cocoapods.org/pods/FakeSwiftUI)
[![Platform](https://img.shields.io/cocoapods/p/FakeSwiftUI.svg?style=flat)](https://cocoapods.org/pods/FakeSwiftUI)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Text
```swift
import FakeSwiftUI
import RxSwift
import RxRelay

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Text("FakeSwiftUI Rocks")
            .font(50)
            .clipShape(Circle())
            .overlay(Circle().stroke([.blue, .yellow], lineWidth: 3))
            .padding(.symmetric(4, 16))
            .background([UIColor.red, .blue])
            .centerX(offset: 0)
            .centerY(offset: 0)
            .on(view)
    }
}
```

## Requirements

## Installation

FakeSwiftUI is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FakeSwiftUI', git => 'https://github.com/dexterliu1214/FakeSwiftUI'
```

## Author

dexterliu1214@gmail.com

## License

FakeSwiftUI is available under the MIT license. See the LICENSE file for more info.
