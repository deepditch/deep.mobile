//
//  DamageCameraView.swift
//
//  Created by Drake Svoboda on 9/28/18.
//  Copyright © 2018 Drake Svoboda. All rights reserved.
//

import UIKit
import CoreML
import CoreLocation

class DamageCameraView: UIImageView {
  var onDamageDetected: RCTDirectEventBlock?
  var onDamageReported: RCTDirectEventBlock?
  var frameExtractor: FrameExtractor!
  var damageDetector: DamageDetector?
  var damageService: DamageService?
  var mlmodelService: MLModelService?
  var throttler: Throttler!
  
  init() {
    super.init(image: nil)
  }
  
  func startDetecting() {
    frameExtractor = FrameExtractor()
    
    throttler = Throttler(seconds: 0.125, queue: DispatchQueue.global(qos: .userInitiated)) // Damage detection is run a maximum of 8 times per second
    
    frameExtractor.frameCaptured = { [unowned self] (image: UIImage?) in
      self.image = image // Update the UI
      
      guard self.damageDetector != nil else { return }
      
      self.throttler.throttle {
        guard self.damageDetector != nil else { return }
        self.damageDetector!.maybeDetect(for: image!)
      }
    }
    
    self.damageDetector!.damageDetected = { [unowned self] (image: UIImage, damages: [Damage], coords: CLLocationCoordinate2D, course: String) in
      self.damageService!.maybeReport(image: image, damages: damages, latitude: coords.latitude, longitude: coords.longitude, course: course) { result in
        if(self.onDamageReported != nil) {
          switch result {
          case let .success(response):
            let data = response.data // Data, your JSON response is probably in here!
            let statusCode = response.statusCode // Int - 200, 401, 500, etc
            
            self.onDamageReported!([
              "data": data,
              "status": statusCode
              ]);
            
          case let .failure(error): // Server did not recieve request, or server did not send response
            self.onDamageReported!([
              "status": "err"
              ]);
          }
        }
      }
      
      if(self.onDamageDetected != nil) {
        var list = [[AnyHashable: Any]]()
        
        for damage in damages {
          list.append(damage.dictionary!)
        }
        
        self.onDamageDetected!(["damages": list]);
      }
    }
  }
  
  @objc(setOnDamageDetected:) // For react native to set the damage detected callback
  public func setOnDamageDetected(callback: @escaping RCTDirectEventBlock) {
    onDamageDetected = callback
  }
  
  @objc(setOnDamageReported:) // For react native to set the damage reported callback
  public func setOnDamageReported(callback: @escaping RCTDirectEventBlock) {
    onDamageReported = callback
  }
  
  @objc(setAuthToken:) // For react native to set the auth token
  public func setAuthToken(token: NSString) {
    damageService = DamageService(with: token as String)
    mlmodelService = MLModelService(with: token as String)
    
    mlmodelService!.getModel() { compiledUrl in
      self.damageDetector = DamageDetector(compiledUrl: compiledUrl)
      self.startDetecting()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
