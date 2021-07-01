![Logo](./logo.png)

# NetShears

NetShears is a Network interceptor framework written in Swift.

NetShears adds a Request interceptor mechanisms to be able to modify the HTTP/HTTPS Request before being sent . This mechanism can be used to implement authentication policies, add headers to a request , add log trace or even redirect requests.


## Features

- [x] Intercept HTTP/HTTPS request header
- [x] Intercept HTTP/HTTPS request endpoint
- [ ] Intercept HTTP/HTTPS response body
- [ ] View traffic logs
- [ ] Block HTTP requets

## How it works

NetShears working by swizzling the URLProtocol.


## How to use
Start NetShears by calling  ```startRecording()```  in didFinishLaunchingWithOptions

```swift
import NetShears

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

	NetShears.startRecording()

}
```
Header Modification:

```swift
let header = HeaderModifyModel(key: "API-Version", value: "123")
let headerModifier = RequestEvaluatorModifierHeader(header: header)
NetShears.shared.modify(modifier: headerModifier)
```

Endpoint Modification: 

```swift
let endpoint = RedirectedRequestModel(originalUrl: "/register", redirectUrl: "/login")
let endpointModifier = RequestEvaluatorModifierEndpoint(redirectedRequest: endpoint)
NetShears.shared.modify(modifier: endpointModifier)
```

## Installation

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.

```swift
// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "YourProject",
  dependencies: [
    .package(url: "https://github.com/divar-ir/NetShears.git", from: "1.0.0"),
  ],
  targets: [
    .target(name: "YourProject", dependencies: ["NetShears"])
  ]
)
```

```bash
$ swift build
```

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'NetShears'
end
```

Replace `YOUR_TARGET_NAME` and then, in the `Podfile` directory, type:

```bash
$ pod install
```

## Contributing
Please see our [Contributing Guide](./CONTRIBUTING.md).

## Inspiration

* [depoon/NetworkInterceptor](https://github.com/depoon/NetworkInterceptor)

## License
[MIT](https://choosealicense.com/licenses/mit/)
