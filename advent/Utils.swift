
import Foundation

enum Errors: Error {
    case parseError(input: String)
    case otherError(message: String)
}
