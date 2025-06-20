// XrayWeave
// Written by Bogdan Belogurov, 2023.

import Foundation

public enum OutboundConfigurationObject: Encodable, XrayParsable {

    case vless(VlessOutboundConfigurationObject)
    case vmess(VmessOutboundConfigurationObject)
    case shadowsocks(ShadowsocksOutboundConfigurationObject)

    init(_ parser: XrayWeave) throws {
        switch parser.outboundProtocol {
        case .vless:
            self = .vless(try VlessOutboundConfigurationObject(parser))
        case .vmess:
            self = .vmess(try VmessOutboundConfigurationObject(parser))
        case .shadowsocks:
            self = .shadowsocks(try ShadowsocksOutboundConfigurationObject(parser))
        case .freedom:
            throw NSError.newError("Fix me 🥲")
        default:
            throw NSError.newError("Unsupported outbound protocol: \(parser.outboundProtocol)")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .vless(let object):
            try container.encode(["vnext": [object]])
        case .vmess(let object):
            try container.encode(["vnext": [object]])
        case .shadowsocks(let object):
            try container.encode(["servers": object.servers])
        }
    }
}
