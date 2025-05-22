import Foundation

public struct TunInboundConfigurationObject: Encodable {
    let interfaceName: String?
    let mtu: Int?
    let autoRoute: Bool
    let strictRoute: Bool
    let sniff: Bool

    public init(interfaceName: String? = nil, mtu: Int? = 1500, autoRoute: Bool = true, strictRoute: Bool = false, sniff: Bool = true) {
        self.interfaceName = interfaceName
        self.mtu = mtu
        self.autoRoute = autoRoute
        self.strictRoute = strictRoute
        self.sniff = sniff
    }
}
