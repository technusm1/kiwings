//
//  DataTypes.swift
//  Kiwings
//
//  Created by Maheep Kumar Kathuria on 21/06/21.
//

import Foundation

struct KiwixLibraryFile: Codable {
    var path: String
    var isEnabled: Bool
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
