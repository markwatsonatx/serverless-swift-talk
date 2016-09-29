//
//  AppDefaults.swift
//  ServerlessSwiftTalkClient
//
//  Created by Mark Watson on 9/29/16.
//  Copyright © 2016 IBM CDS Labs. All rights reserved.
//

import UIKit

struct AppState {
    
    static var username: String? = nil
    static var password: String? = nil
    
    static let serviceName: String = "ServerlessSwiftTalkClient"
    static let usernameKey: String = "Username"
    
    // MARK: Save Members
    
    static func saveUsername(_ username: String) {
        UserDefaults.standard.setValue(username, forKey: usernameKey)
    }
    
    static func savePassword(_ password: String, username: String) {
        deletePassword(username)
        //
        let keychainQuery: [AnyHashable: Any] = [
            kSecClass as AnyHashable: kSecClassGenericPassword,
            kSecAttrService as AnyHashable : serviceName as AnyObject,
            kSecAttrAccount as AnyHashable : username as AnyObject,
            kSecValueData as AnyHashable: password.data(using: .utf8, allowLossyConversion: false)! as AnyObject
        ]
        let status: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil)
        if (status == errSecSuccess) {
            AppState.password = password
        }
    }
    
    static func saveUsernamePassword(_ username: String, password: String) {
        self.saveUsername(username)
        self.savePassword(password, username: username)
    }
    
    // MARK: Load Members
    
    static func loadUsername() -> String? {
        if (AppState.username == nil) {
            AppState.username = UserDefaults.standard.value(forKey: usernameKey) as? String
        }
        return AppState.username;
    }
    
    static func loadPassword(_ username: String) -> String? {
        if (AppState.password == nil) {
            // load from keychain
            let keychainQuery: [AnyHashable: Any] =  [
                kSecClass as AnyHashable : kSecClassGenericPassword,
                kSecAttrService as AnyHashable : serviceName as AnyObject,
                kSecAttrAccount as AnyHashable : username as AnyObject,
                kSecReturnData as AnyHashable : kCFBooleanTrue,
                kSecMatchLimit as AnyHashable : kSecMatchLimitOne]
            var dataTypeRef: AnyObject?
            let status = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
            if status == errSecSuccess, let retrievedData = dataTypeRef as! Data? {
                AppState.password = NSString(data: retrievedData as Data, encoding: String.Encoding.utf8.rawValue) as? String
            }
        }
        return AppState.password
    }
    
    // MARK: Delete Members
    
    static func deleteUsernamePassword() {
        if (AppState.username != nil) {
            deletePassword(AppState.username!)
        }
        deleteUsername()
    }
    
    static func deleteUsername() {
        UserDefaults.standard.setValue(nil, forKey: usernameKey)
        AppState.username = nil
    }
    
    static func deletePassword(_ username: String) {
        let keychainQuery: [AnyHashable: Any] =  [
            kSecClass as AnyHashable: kSecClassGenericPassword,
            kSecAttrService as AnyHashable: serviceName as AnyObject,
            kSecAttrAccount as AnyHashable: username as AnyObject,
            kSecReturnData as AnyHashable: kCFBooleanTrue,
            kSecMatchLimit as AnyHashable: kSecMatchLimitOne]
        SecItemDelete(keychainQuery as CFDictionary)
    }
}

