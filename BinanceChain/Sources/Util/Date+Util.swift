import Foundation
import CryptoKit

extension Date {

    init(millisecondsSince1970: Double) {
        self.init(timeIntervalSince1970: millisecondsSince1970 / 1000)
    }
    
}

extension Data {
    func sha256() -> Data {
        let digest = SHA256.hash(data: self)
        return Data(digest)
    }
}
