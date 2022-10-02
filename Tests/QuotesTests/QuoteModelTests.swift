import XCTest
@testable import Quotes

final class QuoteModelTests: XCTestCase {
    
    func testGetError() throws {
        enum GetError: Error {
            case test
        }
        class GetErrorProtocol: MockProtocol {
            class override var url: URL { QuoteModel.getURL }
            class override var responseError: Error? { GetError.test }
        } 
        guard URLProtocol.registerClass(GetErrorProtocol.self) else {
            XCTFail("unable to register protocol")
            return
        }
        let exp = XCTestExpectation()
        let viewModel = QuoteModel(session: URLSession.shared)
        viewModel.get { result in
            switch result {
            case .failure(let error): 
                XCTAssertEqual(error.localizedDescription, GetError.test.localizedDescription) 
            default: 
                XCTFail("should be failure with an error")   
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocol.unregisterClass(GetErrorProtocol.self)
    }

    func testNotHTTPResponse() {
        class GetNotHTTPResponseProtocol: MockProtocol {
            class override var url: URL { QuoteModel.getURL }
            class override func response() -> URLResponse {
                return URLResponse()
            }
        } 
        guard URLProtocol.registerClass(GetNotHTTPResponseProtocol.self) else {
            XCTFail("unable to register protocol")
            return
        }
        let exp = XCTestExpectation()
        let viewModel = QuoteModel(session: URLSession.shared)
        viewModel.get { result in
            switch result {
            case .failure(let error): 
                XCTAssertEqual(
                    error.localizedDescription, 
                    QuoteModel.QuoteModelError.notHTTPResponse.localizedDescription
                ) 
            default: 
                XCTFail("should be failure with an not HTTP response error")   
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocol.unregisterClass(GetNotHTTPResponseProtocol.self)
    }

    func testGetNotStatus200() throws {
        class GetNot200Protocol: MockProtocol {
            class override var url: URL { QuoteModel.getURL }
            class override var statusCode: Int { 400 }
        }
        guard URLProtocol.registerClass(GetNot200Protocol.self) else {
            XCTFail("unable to register protocol")
            return
        }
        let exp = XCTestExpectation()
        let viewModel = QuoteModel(session: URLSession.shared)
        viewModel.get { result in
            switch result {
            case .failure(let error): 
                XCTAssertEqual(
                    error.localizedDescription, 
                    QuoteModel.QuoteModelError.badStatus(code: 400).localizedDescription
                ) 
            default: 
                XCTFail("should be failure with an bad status code error")   
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocol.unregisterClass(GetNot200Protocol.self)
    }

    func testDecodeError() {
        class SuccessProtocol: MockProtocol {
            class override var url: URL { QuoteModel.getURL }
        }
        guard URLProtocol.registerClass(SuccessProtocol.self) else {
            XCTFail("unable to register protocol")
            return
        }
        let exp = XCTestExpectation()
        let viewModel = QuoteModel(session: URLSession.shared)
        viewModel.get { result in
            switch result {
            case .failure: 
                break 
            default: 
                XCTFail("should be failure with an no data error")   
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocol.unregisterClass(SuccessProtocol.self)
    }

    func testNoQuotesError() {
        class SuccessProtocol: MockProtocol {
            class override var url: URL { QuoteModel.getURL }
            class override var responseData: Data? { "[]".data(using: .utf8) }
        }
        guard URLProtocol.registerClass(SuccessProtocol.self) else {
            XCTFail("unable to register protocol")
            return
        }
        let exp = XCTestExpectation()
        let viewModel = QuoteModel(session: URLSession.shared)
        viewModel.get { result in
            switch result {
            case .failure(let error): 
                XCTAssertEqual(
                    error.localizedDescription, 
                    QuoteModel.QuoteModelError.noQuotes.localizedDescription
                )
            default: 
                XCTFail("should be failure with an no quotes error")   
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocol.unregisterClass(SuccessProtocol.self)
    }

    func testSuccess() {
        class SuccessProtocol: MockProtocol {
            class override var url: URL { QuoteModel.getURL }
            class override var responseData: Data? { 
                """
                [{"a":"author","q":"quote","h":"html"}]
                """.data(using: .utf8)
            }
        }
        guard URLProtocol.registerClass(SuccessProtocol.self) else {
            XCTFail("unable to register protocol")
            return
        }
        let exp = XCTestExpectation()
        let viewModel = QuoteModel(session: URLSession.shared)
        viewModel.get { result in
            switch result {
            case .failure: XCTFail("should not fail")
            case .success(let quote): 
                XCTAssertEqual(quote.a, "author")
                XCTAssertEqual(quote.q, "quote")
                XCTAssertEqual(quote.h, "html")   
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocol.unregisterClass(SuccessProtocol.self)
    }
}
