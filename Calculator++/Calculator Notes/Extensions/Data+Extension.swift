import Foundation

extension Data {
    func invert() -> Data {
        return Data(self.reversed())
    }
}
