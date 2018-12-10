//
//  TokenSource.swift
//  deep.mobile
//
//  Created by Drake Svoboda on 12/8/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation

@objc(TokenSource)
class TokenSource: NSObject {
  let key: String = "@deep.ditch:auth:token"
  let defaults = UserDefaults.standard
  
  @objc
  public func get() -> String? {
    let token = defaults.string(forKey: self.key)
    guard token != nil else { return nil }
    return token
  }
  
  @objc
  func get(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    let token = self.get()
    
    if token == nil {
      reject("404", "no-token", nil)
    } else {
      resolve(token)
    }
  }
  
  @objc(set:)
  public func set(with token: String) {
    defaults.set(token, forKey: self.key)
  }
  
  @objc
  public func remove() {
    defaults.removeObject(forKey: self.key)
  }
}
