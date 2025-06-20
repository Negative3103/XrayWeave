//
//  File.swift
//  XrayWeave
//
//  Created by Хасан Давронбеков on 20/06/25.
//

import Foundation
public struct ShadowsocksOutboundConfigurationObject: Encodable, XrayParsable {

    public struct Server: Encodable {
        let address: String
        let port: Int
        let method: String
        let password: String
    }

    public let servers: [Server]

    public init(_ parser: XrayWeave) throws {
        let method = parser.parametersMap["method"] ?? ""
        let password = parser.parametersMap["password"] ?? ""

        guard !method.isEmpty else {
            throw NSError.newError("Shadowsocks method is missing")
        }
        guard !password.isEmpty else {
            throw NSError.newError("Shadowsocks password is missing")
        }

        servers = [
            Server(
                address: parser.host,
                port: parser.port,
                method: method,
                password: password
            )
        ]
    }
}
