import Cocoa

public struct Quote: Codable {
    public var q: String
    public var a: String
    public var h: String
}

public struct QuoteModel {
    public static var getQuoteURL: URL = {
        guard let url = URL(string: getQuoteLocation) else {
            preconditionFailure("\(getQuoteLocation) is not a proper URL")
        }
        return url
    }()
    let session: URLSession
    public init(session: URLSession = URLSession.shared) {
        self.session = session
    }
}

public extension QuoteModel {
    enum QuoteModelError: Error {
        case notHTTPResponse
        case badStatus(code: Int)
        case noData
        case noQuotes
    }
}

public extension QuoteModel {
    func getQuote(_ completion: @escaping (Result<Quote, Error>) -> Void) {
        let task = session.dataTask(
            with: QuoteModel.getQuoteURL,
            completionHandler: { data, response, error in
                do {
                    // make sure there is not an error
                    if let error = error {
                        throw error
                    }

                    // make sure the response is a HTTP response
                    guard let response = response as? HTTPURLResponse else {
                        throw QuoteModelError.notHTTPResponse
                    }

                    // make sure the response has a 200 status code
                    guard response.statusCode == 200 else {
                        throw QuoteModelError.badStatus(code: response.statusCode)
                    }

                    // make sure there is data
                    guard let data = data else {
                       throw QuoteModelError.noData
                    }

                    // decode the responses data to a quote array
                    let decoder = JSONDecoder()
                    let quotes = try decoder.decode([Quote].self, from: data)
                    // make sure we have a quote
                    guard let quote = quotes.first else {
                        throw QuoteModelError.noQuotes
                    }
                    // send back the quote
                    completion(.success(quote))
                } catch {
                    completion(.failure(error))
                }
            }
        )
        task.resume()
    }
}

private let getQuoteLocation = "https://zenquotes.io/api/random"
