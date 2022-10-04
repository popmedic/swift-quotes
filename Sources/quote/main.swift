import Foundation
import TSCBasic
import TSCUtility
import Quotes

guard let tty = TerminalController(stream: stdoutStream) else {
    fatalError("unable to initialize terminal controller")
}

let animation = PercentProgressAnimation(
    stream: stdoutStream,
    header: "🎙 . . . Quote . . . 🎤"
)

let group = DispatchGroup()

group.enter()
let viewModel = QuoteModel(session: SuccessStub.session) { progress in
    animation.update(
        step: Int(progress * 100.0),
        total: 100,
        text: ""
    )
}
viewModel.getQuote { result in
    animation.complete(success: true)
    switch result {
    case .failure(let error):
        print(error)
    case .success(let quote):
        print(tty.wrap("\"\(quote.q)\"", inColor: .cyan, bold: true))
        print(tty.wrap("By: \(quote.a)", inColor: .yellow))
    }
    group.leave()
}

group.wait()
