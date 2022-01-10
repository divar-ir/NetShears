![Logo](./logo.png)

# NetShears

NetShears is a Network interceptor framework written in Swift.

NetShears adds a Request interceptor mechanisms to be able to modify the HTTP/HTTPS Request before being sent . This mechanism can be used to implement authentication policies, add headers to a request , add log trace or even redirect requests.


## Features

- [x] Intercept HTTP/HTTPS request header
- [x] Intercept HTTP/HTTPS request endpoint
- [x] View traffic logs
- [x] Request obserever
- [ ] Intercept HTTP/HTTPS response body
- [ ] Block HTTP requets

## How it works

NetShears has three main functionality :

1 - Network request observer which can be used to observe every HTTP/HTTPS request using delegation.
```swift
Netshears.shared.startListener() 
```

2 - Request interceptor mechanisms to be able to modify the HTTP/HTTPS Request before being sent.
```swift
Netshears.shared.startInterceptor() 
```

3 - Show network traffics.
```swift
Netshears.shared.startLogger() 
```

## Interceptor

Make sure to call ```startInterceptor()``` before adding modifiers.
```swift
Netshears.shared.startInterceptor()
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

# Traffic Monitoring

Make sure to call ```startLogger()``` before showing netwrok traffic logs.
```swift
Netshears.shared.startLogger()
```

In order to show network traffics in your app simply call presentNetworkMonitor method and then a view will present containing traffic logs.

```swift
NetShears.shared.presentNetworkMonitor()
```

<p align="center">
<img src="https://raw.githubusercontent.com/divar-ir/NetShears/master/traffic_screen.png" alt="Icon"/>
</p>

## gRPC 

You can view gRPC calls by constructing the Request and Response from GRPC models:

```swift
public func addGRPC(url: String,
                        host: String,
                        requestObject: Data?,
                        responseObject: Data?,
                        success: Bool,
                        statusCode: Int,
                        statusMessage: String?,
                        duration: Double?,
                        HPACKHeadersRequest: [String: String]?,
                        HPACKHeadersResponse: [String: String]?)
```
Example

```swift
// Your GRPC services that is generated from SwiftGRPC
private let client = NoteServiceServiceClient.init(address: "127.0.0.1:12345", secure: false)


func insertNote(note: Note, completion: @escaping(Note?, CallResult?) -> Void) {
    _ = try? client.insert(note, completion: { (createdNote, result) in

        NetShears.shared.addGRPC(url: "https://test.com/grpc",
                         requestObject: try? note.jsonUTF8Data(),
                         responseObject: try? createdNote.jsonUTF8Data(),
                         success: result.success,
                         statusCode: result.statusCode.rawValue,
                         statusMessage: result.statusMessage)
    })
}
```

# Request Observer

For observing requests you need to first call startListener then just simply adopt RequestBroadcast <RequestBroadcastDelegate> delegate.
```swift
NetShears.shared.startListener()

RequestBroadcast.shared.setDelegate(self)

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
    .package(url: "https://github.com/divar-ir/NetShears.git", from: "3.0.1"),
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
* [pmusolino/Wormholy](https://github.com/pmusolino/Wormholy)

## License
[MIT](https://choosealicense.com/licenses/mit/)
