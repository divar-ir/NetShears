import XCTest
@testable import NetShears

final class NetShearsTests: XCTestCase {
    let expectation = XCTestExpectation()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        NetShears.shared.startInterceptor()
    }
    
    override func tearDownWithError() throws {
        PersistHelper.clear()
        NetShears.shared.stopInterceptor()
        Storage.shared.clearRequests()
        try super.tearDownWithError()
    }
    
    func testModifyResponse() {
        let modifier = RequestEvaluatorModifierResponse(response: .init(
            url: "https://example.com/",
            data: #"{"message": "ok"}"#.data(using: .utf8)!,
            httpMethod: "POST",
            headers: ["result": "true"]
        ))
        
        NetShears.shared.modify(modifier: modifier)
        
        var request = URLRequest(url: URL(string: "https://example.com/")!)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            let dict = try! JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as! [String: String]
            XCTAssertEqual((response as! HTTPURLResponse).statusCode, 200)
            XCTAssertEqual((response as! HTTPURLResponse).allHeaderFields["result"] as! String, "true")
            XCTAssertEqual(dict["message"], "ok")
            self.expectation.fulfill()
        }.resume()
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testModifyRequestBeforeModifiyingResponse() {
        let modifier = RequestEvaluatorModifierResponse(response: .init(
            url: "https://example.com/sandbox/ok",
            data: #"{"message": "ok"}"#.data(using: .utf8)!
        ))
        
        NetShears.shared.modify(modifier: RequestEvaluatorModifierEndpoint(redirectedRequest: .init(originalUrl: "v1", redirectUrl: "sandbox")))
        NetShears.shared.modify(modifier: modifier)
        
        let task = URLSession.shared.dataTask(with: URL(string: "https://example.com/v1/ok")!) { data, response, _ in
            let dict = try! JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as! [String: String]
            XCTAssertEqual((response as! HTTPURLResponse).statusCode, 200)
            XCTAssertEqual(dict["message"], "ok")
            self.expectation.fulfill()
        }
        
        task.resume()
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testMonitorModifiedResponseRequest() {
        NetShears.shared.startLogger()
        
        let modifier = RequestEvaluatorModifierResponse(response: .init(
            url: "https://example.com/",
            data: #"{"message": "ok"}"#.data(using: .utf8)!
        ))
        
        NetShears.shared.modify(modifier: modifier)
        
        URLSession.shared.dataTask(with: URL(string: "https://example.com/")!) { data, response, _ in
            XCTAssertTrue(Storage.shared.requests.contains(where: { $0.url == modifier.response.url }))
            self.expectation.fulfill()
        }.resume()
        
        wait(for: [expectation], timeout: 1)
    }

    func testIgnoreOnUrlRequest() {
        //given
        let url = "https://example.com/"
        NetShears.shared.ignore = .enabled(ignoreHandler: { request in
            request.url.contains("example")
        })

        //when
        NetShears.shared.startLogger()
        URLSession.shared.dataTask(with: URL(string: url)!) { data, response, _ in
            //then
            XCTAssertTrue(Storage.shared.requests.contains(where: { $0.url == url }))
            XCTAssertTrue(Storage.shared.filteredRequests.isEmpty)
            self.expectation.fulfill()
        }.resume()

        wait(for: [expectation], timeout: 2)
    }

    func testIgnoreOnHeaderRequest() {
        //given
        let headerKey = "language"
        let headerValue = "rus"
        var request = URLRequest(url: URL(string: "https://example.com/")!)
        request.setValue(headerValue, forHTTPHeaderField: headerKey)
        NetShears.shared.ignore = .enabled(ignoreHandler: { request in
            if let value = request.headers[headerKey] {
                return value == headerValue
            }
            return false
        })

        //when
        NetShears.shared.startLogger()
        URLSession.shared.dataTask(with: request) { data, response, _ in
            //then
            XCTAssertTrue(Storage.shared.requests.contains(where: { $0.headers.contains { (key,value) in
                key == headerKey && value == headerValue
            }}))
            XCTAssertTrue(Storage.shared.filteredRequests.isEmpty)
            self.expectation.fulfill()
        }.resume()

        wait(for: [expectation], timeout: 2)
    }
}
