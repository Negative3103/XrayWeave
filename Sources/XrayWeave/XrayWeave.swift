// XrayWeave
// Written by Bogdan Belogurov, 2023.

import Foundation

public struct XrayWeave {

    public let outboundProtocol: OutboundProtocol
    public let userID: String
    public let host: String
    public let port: Int
    public let network: StreamSettings.Network
    public let security: StreamSettings.Security
    public let fragment: String
    let parametersMap: [String: String]

    public init(urlString: String) throws {
        if urlString.starts(with: "ss://") {
            let encoded = urlString.replacingOccurrences(of: "ss://", with: "")
            
            // Разделение base64@host:port
            let parts = encoded.split(separator: "@")
            guard parts.count == 2 else {
                throw NSError.newError("Invalid ss:// format")
            }
            
            // Декодируем method:password
            guard let userData = Data(base64Encoded: String(parts[0])) else {
                throw NSError.newError("Invalid base64 in ss://")
            }
            let userString = String(decoding: userData, as: UTF8.self)
            let userParts = userString.split(separator: ":")
            guard userParts.count == 2 else {
                throw NSError.newError("Invalid method:password in ss://")
            }
            
            let method = String(userParts[0])
            let password = String(userParts[1])
            
            // Парсим host и port
            let hostAndPort = parts[1].split(separator: "#")[0]
            let hostParts = hostAndPort.split(separator: ":")
            guard hostParts.count == 2 else {
                throw NSError.newError("Invalid host:port in ss://")
            }
            
            let host = String(hostParts[0])
            let port = Int(hostParts[1]) ?? 443
            let tag = parts[1].split(separator: "#").dropFirst().joined(separator: "#")
            
            // Присваиваем
            self.outboundProtocol = .shadowsocks
            self.userID = "" // не используется
            self.host = host
            self.port = port
            self.network = .tcp // shadowsocks всегда tcp
            self.security = .none
            self.fragment = tag
            
            self.parametersMap = [
                "method": method,
                "password": password,
                "type": "tcp",
                "security": "none"
            ]
            
            return
        }
        
        if urlString.starts(with: "vmess://") {
            let base64Part = urlString.replacingOccurrences(of: "vmess://", with: "")
            guard let data = Data(base64Encoded: base64Part) else {
                throw NSError.newError("Invalid base64 in vmess URI")
            }
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw NSError.newError("Invalid JSON in decoded vmess URI")
            }
            
            print("✅ Декодирован JSON:", jsonObject)

            self.outboundProtocol = .vmess
            self.userID = (jsonObject["id"] as? String) ?? ""
            self.host = (jsonObject["add"] as? String) ?? ""
            self.port = Int(jsonObject["port"] as? String ?? "") ?? (jsonObject["port"] as? Int ?? 443)
            self.network = StreamSettings.Network(rawValue: (jsonObject["net"] as? String ?? "tcp")) ?? .tcp
            self.security = StreamSettings.Security(rawValue: (jsonObject["tls"] as? String ?? "none")) ?? .none
            self.fragment = (jsonObject["ps"] as? String) ?? ""
            
            self.parametersMap = [
                "aid": jsonObject["aid"] as? String ?? "0",
                "scy": jsonObject["scy"] as? String ?? "auto",
                "fp": jsonObject["fp"] as? String ?? "",
                "alpn": jsonObject["alpn"] as? String ?? "",
                "sni": jsonObject["sni"] as? String ?? "",
                "pbk": jsonObject["pbk"] as? String ?? "",
                "sid": jsonObject["sid"] as? String ?? "",
                "spx": jsonObject["spx"] as? String ?? "",
                "type": jsonObject["net"] as? String ?? "tcp",
                "security": jsonObject["tls"] as? String ?? "none"
            ]
            
            return
        }
        
        guard let urlComponents = URLComponents(string: urlString) else {
            throw NSError.newError("Can't create URL components")
        }

        guard let outboundProtocol = urlComponents.scheme.flatMap(OutboundProtocol.init) else {
            throw NSError.newError("Unsupported protocol \(String(describing: urlComponents.scheme))")
        }

        guard let userID = urlComponents.user, !userID.isEmpty else {
            throw NSError.newError("There is no user")
        }

        guard let host = urlComponents.host, !host.isEmpty else {
            throw NSError.newError("There is no host")
        }

        guard let port = urlComponents.port, (1...65535).contains(port) else {
            throw NSError.newError("Port isn't valid")
        }

        let map = (urlComponents.queryItems ?? []).reduce(into: [String: String](), { result, item in
            result[item.name] = item.value
        })

        guard let network = map["type"].flatMap(StreamSettings.Network.init) else {
            throw NSError.newError("There is no valid network type")
        }

        guard let security = map["security"].flatMap(StreamSettings.Security.init) else {
            throw NSError.newError("There is no valid security type")
        }

        self.outboundProtocol = outboundProtocol
        self.userID = userID
        self.host = host
        self.port = port
        self.network = network
        self.security = security
        self.fragment = urlComponents.fragment ?? String()
        parametersMap = map
    }

    public func getConfiguration() throws -> XrayConfiguration {
        return try XrayConfiguration(self)
    }
}
