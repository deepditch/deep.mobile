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
  var throttler: Throttler!
  
  
  init() {
    super.init(image: nil)
    
    frameExtractor = FrameExtractor()
    damageDetector = DamageDetector()
    throttler = Throttler(seconds: 0.25)
    
    frameExtractor.frameCaptured = { [unowned self] image in
      self.image = image // Update the UI
      
      self.throttler.throttle(block: { [unowned self] in
        self.damageDetector.detect(for: image!)
      }, queue: DispatchQueue.global(qos: .userInitiated))
    }
    
    damageDetector.damageDetected = { [unowned self] vec in
      if(self.onDamageDetected != nil) {
        var arr = [String]()
        
        if(vec![0].doubleValue > 0.5) {
          arr.append("D00: Crack")
        }
        
        if(vec![1].doubleValue > 0.5) {
          arr.append("D01: Crack")
        }
        
        if(vec![2].doubleValue > 0.5) {
          arr.append("D10: Crack")
        }
        
        if(vec![3].doubleValue > 0.5) {
          arr.append("D11: Crack")
        }
        
        if(vec![4].doubleValue > 0.5) {
          arr.append("D20: Alligator Crack")
        }
        
        if(vec![5].doubleValue > 0.5) {
          arr.append("D40: Pothole")
        }
        
        if(vec![6].doubleValue > 0.5) {
          arr.append("D43: Line Blur")
        }
        
        if(vec![7].doubleValue > 0.5) {
          arr.append("D44: Crosswalk Blur")
        }
        
        if(arr.count > 0) {
          self.onDamageDetected!([
            "Damages": arr
          ]);
        }
      }
    }
  }
  
  @objc(setOnDamageDetected:)
  public func setOnDamageDetected(callback: @escaping RCTDirectEventBlock) {
    onDamageDetected = callback
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
