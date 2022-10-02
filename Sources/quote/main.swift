import Cocoa
import Quotes

let group = DispatchGroup()

group.enter()
let viewModel = QuoteModel(session: URLSession.shared)
viewModel.get() { result in
    switch result {
    case .failure(let error):
        print(error)
    case .success(let quote):
        print("\"\(quote.q)\"")
        print("By: \(quote.a)")
    }
    group.leave()
}

group.wait()
