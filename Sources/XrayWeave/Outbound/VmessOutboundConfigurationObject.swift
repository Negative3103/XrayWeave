//
//  File.swift
//  XrayWeave
//
//  Created by Хасан Давронбеков on 20/06/25.
//

import Foundation

public struct VmessOutboundConfigurationObject: Encodable, XrayParsable {
    
    public struct VmessUser: Encodable {
        let id: String
        let alterId: Int
        let security: String

        public init(id: String, alterId: Int = 0, security: String = "auto") {
            self.id = id
            self.alterId = alterId
            self.security = security
        }
    }

    public let address: String
    public let port: Int
    public let users: [VmessUser]

    public init(_ parser: XrayWeave) throws {
        address = parser.host
        port = parser.port
        users = [
            VmessUser(
                id: parser.userID,
                alterId: Int(parser.parametersMap["aid"] ?? "0") ?? 0,
                security: parser.parametersMap["scy"] ?? "auto"
            )
        ]
    }
}
