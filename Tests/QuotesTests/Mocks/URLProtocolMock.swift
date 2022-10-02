import Cocoa

class MockProtocol: URLProtocol {
    // Change these in sub-classes to provide a different response
    // the url is what you should change to add responses
    //     ie if you want to make "http://staging.blah/route/here" fail,
    //     change this URL to "http://staging.blah/route/here" and it will match the canInit
    //     and use the mock for the call
    class var url: URL { URL(string: "")! }
    // status code to return, override in subclass if want different
    class var statusCode: Int { 200 }
    // httpVersion for the response, override in subclass if want different
    class var httpVersion: String? { nil }
    // response header fields for response, override in subclass if want different
    class var responseHeaderFields: [String: String]? { ["Content": "application/json"] }
    // response data, override in subclass if want different
    class var responseData: Data? { "{\"key\":\"value\"}".data(using: .utf8) }
    // response error, will superseed other responses, override in subclass if want different
    class var responseError: Error? { nil }
    
    static var session: URLSession {
        let config = URLSessionConfiguration.ephemeral
        var protocols: [AnyClass] = [Self.self]
        protocols.append(contentsOf: config.protocolClasses ?? [])
        config.protocolClasses = protocols
        return URLSession(configuration: config)
    }
    
    class func response() -> URLResponse {
        guard let  response = HTTPURLResponse(url: Self.url,
                                              statusCode: Self.statusCode,
                                              httpVersion: Self.httpVersion,
                                              headerFields: Self.responseHeaderFields) else {
            preconditionFailure("bad response")
        }
        return response
    }
    override class func canInit(with request: URLRequest) -> Bool {
        request.url == Self.url
    }
    // this will run first so make sure that we handle tasks as well!!!
    override class func canInit(with task: URLSessionTask) -> Bool {
        task.currentRequest?.url == Self.url
    }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    override func startLoading() {
        if let error = Self.responseError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        client?.urlProtocol(self, didReceive: Self.response(), cacheStoragePolicy: .notAllowed)
        if let data = Self.responseData { client?.urlProtocol(self, didLoad: data) }
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {
        // no-op
    }
}

// These are some mocks for the protocols

class HappyProtocol: MockProtocol {
    class override var url: URL { URL(string: "https://www.apple.com")! }
}



