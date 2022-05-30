//
//  SecureStorage.swift
//  SecureStorage
//
//  Created by Mikkel Sindberg Eriksen on 28/05/2022.
//

import Foundation
import Security

/// SecureStorage wraps keychain access for storing string values securely in the device key chain.
struct SecureStorage {

    /// Store the given value for the given key.
    ///
    /// Storing a value for a key that already exists is considered an erro and will result in ``SecureStorage.Error.duplicateItem``.
    /// Use ``update(with:for:)`` instead.
    /// - parameter value: The string value to store.
    /// - parameter key: The key to store the value for.
    /// - throws SecureStorage.Error
    func store(value: String, for key: String) throws {

        guard let data = value.data(using: .utf8) else {
            throw Error.internalError("Failed to create Data representation of value for key: \(key)")
        }

        let item = [
            kSecValueData: data,
            kSecAttrService: key,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary

        let status = SecItemAdd(item, nil)
        if let error = Error(osStatus: status, key: key) { throw error }
    }

    /// Retrieve the value for the given key.
    ///
    /// Trying to retrieving a value for a key that does not exist will result in ``SecureStorage.Error.itemNotFound``.
    /// - parameter key: The key to retrieve the value for.
    /// - throws SecureStorage.Error
    func retrieveValue(for key: String) throws -> String {

        let query = [
          kSecClass: kSecClassGenericPassword,
          kSecAttrService: key,
          kSecReturnData: true
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        if let error = Error(osStatus: status, key: key) { throw error }

        guard let data = result as? Data, let value = String(data: data, encoding: .utf8) else {
            throw Error.internalError("Could not convert value from data")
        }

        return value
    }

    /// Update the value for the given key.
    ///
    /// Trying to update a value for a key that does not exist will result in ``SecureStorage.Error.itemNotFound``.
    /// - parameter value: The value to update for the given key.
    /// - parameter key: The key to update the value for.
    /// - throws SecureStorage.error
    func update(with value: String, for key: String) throws {

        guard let data = value.data(using: .utf8) else {
            throw Error.internalError("Failed to create data representation of value")
        }

        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
        ] as CFDictionary

        let item = [
          kSecValueData: data
        ] as CFDictionary

        let status = SecItemUpdate(query, item)
        if let error = Error(osStatus: status, key: key) { throw error }
    }

    /// Delete the value for the given key.
    ///
    /// Trying to retrieving a value for a key that does not exist will result in ``SecureStorage.Error.itemNotFound``.
    /// - parameter key: The key to delete the value for.
    /// - throws SecureStorage.error
    func deleteValue(for key: String) throws {
        let query = [
          kSecClass: kSecClassGenericPassword,
          kSecAttrService:  key,
        ] as CFDictionary

        let status = SecItemDelete(query)
        if let error = Error(osStatus: status, key: key) { throw error }
    }
}

extension SecureStorage {

    enum Error: Swift.Error {

        /// An item already exists for the given key.
        case duplicateItem(String)

        /// An item was not found for the given key.
        case itemNotFound(String)

        /// Some other internal error happened, check the associated string value for details.
        case internalError(String)

        /// Initialize with the given OSStatus. Returns nil if OSStatus is ``errSecSuccess``.
        /// - parameter osStatus: The OSStatus to initialize the error from.
        /// - parameter key: The key for which the error occurred.
        init?(osStatus: OSStatus, key: String) {
            if (osStatus == errSecSuccess) {
                return nil
            } else if (osStatus == errSecItemNotFound) {
                self = .itemNotFound(key)
            } else if (osStatus == errSecDuplicateItem) {
                self = .duplicateItem(key)
            } else {
                self = .internalError("Unhandled OSStatus: \(osStatus) for key \(key)")
            }
        }
    }
}
