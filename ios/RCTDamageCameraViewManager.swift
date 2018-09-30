//
//  RNFrameViewManager.swift
//  View manager used to bridge DamageCameraView to react native
//  deep.mobile
//
//  Created by Drake Svoboda on 9/28/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import UIKit

@objc(RCTDamageCameraManager)
class RCTDamageCameraManager: RCTViewManager {
  override func view() -> UIView! {
    return DamageCameraView();
  }
  
  @objc
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  @objc(resolver:rejecter:)
  func capture(_ resolve: @escaping RCTPromiseResolveBlock,
              rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
    resolve("Test resolve")
  }
}
