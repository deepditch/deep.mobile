//
//  ViewController.swift
//  RealTimeCamera
//  A view that dispalays camera frames in real time
//
//  Created by Drake Svoboda on 9/28/18.
//  Copyright © 2018 Drake Svoboda. All rights reserved.
//

import UIKit
import CoreML

class DamageCameraView: UIImageView {
  var onDamageDetected: RCTDirectEventBlock?
  var frameExtractor: FrameExtractor!
  var damageDetector: DamageDetector!
  var damageService: DamageService!
  var throttler: Throttler!
  var authToken: NSString = ""
  
  
  init() {
    super.init(image: nil)
    
    frameExtractor = FrameExtractor()
    damageDetector = DamageDetector()
    damageService = DamageService()
    
    throttler = Throttler(seconds: 0.25)
    
    frameExtractor.frameCaptured = { [unowned self] (image: UIImage?) in
      self.image = image // Update the UI
      
      self.throttler.throttle(block: { [unowned self] in
        self.damageDetector.maybeDetect(for: image!)
      }, queue: DispatchQueue.global(qos: .userInitiated))
    }
    
    damageDetector.damageDetected = { [unowned self] (image: UIImage, types: [String], lat: Double, lng: Double) in
      self.damageService.report(image: image, types: types, latitude: lat, longitude: lng)
      
      if(self.onDamageDetected != nil) {
        self.onDamageDetected!([
          "damages": types
        ]);
      }
    }
  }
  
  @objc(setOnDamageDetected:)
  public func setOnDamageDetected(callback: @escaping RCTDirectEventBlock) {
    onDamageDetected = callback
  }
  
  @objc(setAuthToken:)
  public func setAuthToken(token: NSString) {
    damageService.setAuthToken(with: token as String)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
