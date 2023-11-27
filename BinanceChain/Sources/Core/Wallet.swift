import Foundation
import CryptoKit

public class BinanceWallet: CustomStringConvertible {

    public var endpoint: String = BinanceChain.Endpoint.testnet.rawValue
    public var publicKey: Data
    public var sequence: Int = 0
    public var accountNumber: Int = 0
    public var chainId: String = ""

    private var externalPublicKey: Data?

    // MARK: - Constructors

    public init(publicKey: Data) {
        self.publicKey = publicKey
    }

    // MARK: - Wallet

    public typealias Completion = (_ error: Error?)->()

    public func synchronise(completion: Completion? = nil) {

        guard let url = URL(string: self.endpoint) else {
            if let completion = completion {
                completion(BinanceError(message: "Invalid endpoint URL"))
            }
            return
        }

        let binance = BinanceChain(endpoint: url)
        let group = DispatchGroup()
        var error: Error?

        // Update node info
        group.enter()
        binance.nodeInfo() { (response) in
            if let value = response.error {
                error = value
            } else {
                self.chainId = response.nodeInfo.network
            }
            group.leave()
        }

        // Update account sequence
        group.enter()
        binance.account(address: self.account) { (response) in
            if let value = response.error {
                error = value
            } else {
                self.accountNumber = response.account.accountNumber
                self.sequence = response.account.sequence
            }
            group.leave()
        }

        // Synchronise complete
        group.notify(queue: .main) {
            guard let completion = completion else { return }
            completion(error)
        }

    }

    public func incrementSequence() {
        self.sequence += 1
    }

    public func nextAvailableOrderId() -> String {
        return String(format: "%@-%d", self.address.uppercased(), self.sequence+1)
    }

    public var account: String {
        return self.account()
    }
    
    public func account(hrp: String? = nil) -> String {
        do {
            let hrp = hrp ?? ((self.endpoint == BinanceChain.Endpoint.testnet.rawValue) ? "tbnb" : "bnb")
            let sha = self.publicKey.sha256()
            let ripemd = RIPEMD160.hash(sha)
            let convertbits = try SegwitAddrCoder().convertBits(from: 8, to: 5, pad: false, idata: ripemd)
            let address = Bech32().encode(hrp, values: convertbits)
            return address
        } catch {
            return "Invalid Key"
        }
    }

    public var address: String {
        let sha = self.publicKey.sha256()
        let ripemd = RIPEMD160.hash(sha)
        return ripemd.hexlify
    }

    public func address(from account: String) -> String {
        do {
            let (_, data) = try Bech32().decode(account)
            let bits = try SegwitAddrCoder().convertBits(from: 5, to: 8, pad: false, idata: data)
            return bits.hexlify
        } catch {
            return "Invalid Key"
        }
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        return String(format: "Wallet [address=%@ accountNumber=%d, sequence=%d, chain_id=%@, account=%@, publicKey=%@, endpoint=%@]",
                      address, accountNumber, sequence, chainId, account, publicKey.hexlify, endpoint)
    }

}
