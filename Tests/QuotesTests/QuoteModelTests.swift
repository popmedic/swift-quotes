import XCTest
@testable import Quotes

final class QuoteModelTests: XCTestCase {

    func testGetQuoteError() throws {
        guard URLProtocol.registerClass(GetErrorProtocol.self) else {
            XCTFail("unable to register protocol")
            return
        }
        let exp = XCTestExpectation()
        let viewModel = QuoteModel(session: URLSession.shared)
        viewModel.getQuote { result in
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
        guard URLProtocol.registerClass(GetNotHTTPResponseProtocol.self) else {
            XCTFail("unable to register protocol")
            return
        }
        let exp = XCTestExpectation()
        let viewModel = QuoteModel(session: URLSession.shared)
        viewModel.getQuote { result in
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
        guard URLProtocol.registerClass(GetNot200Protocol.self) else {
            XCTFail("unable to register protocol")
            return
        }
        let exp = XCTestExpectation()
        let viewModel = QuoteModel(session: URLSession.shared)
        viewModel.getQuote { result in
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
        guard URLProtocol.registerClass(DecodeErrorProtocol.self) else {
            XCTFail("unable to register protocol")
            return
        }
        let exp = XCTestExpectation()
        let viewModel = QuoteModel(session: URLSession.shared)
        viewModel.getQuote { result in
            switch result {
            case .failure:
                break
            default:
                XCTFail("should be failure with an no data error")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocol.unregisterClass(DecodeErrorProtocol.self)
    }

    func testNoQuotesError() {
        guard URLProtocol.registerClass(NoQuotesErrorProtocol.self) else {
            XCTFail("unable to register protocol")
            return
        }
        let exp = XCTestExpectation()
        let viewModel = QuoteModel(session: URLSession.shared)
        viewModel.getQuote { result in
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
        URLProtocol.unregisterClass(NoQuotesErrorProtocol.self)
    }

    func testSuccess() {
        guard URLProtocol.registerClass(SuccessProtocol.self) else {
            XCTFail("unable to register protocol")
            return
        }
        let exp = XCTestExpectation()
        let viewModel = QuoteModel(session: URLSession.shared)
        viewModel.getQuote { result in
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
