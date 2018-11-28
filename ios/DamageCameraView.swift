//
//  DamageCameraView.swift
//
//  Created by Drake Svoboda on 9/28/18.
//  Copyright © 2018 Drake Svoboda. All rights reserved.
//

import UIKit
import CoreML
import CoreLocation

class DamageCameraView: UIView {
  var onDamageDetected: RCTDirectEventBlock?
  var onDownloadProgress: RCTDirectEventBlock?
  var onDownloadComplete: RCTDirectEventBlock?
  var onError: RCTDirectEventBlock?
  var mlmodelService: MLModelService?  
  var damageDetector: DamageDetector?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  func startDetecting() {
    self.damageDetector!.damageDetected = { [unowned self] (image: UIImage, damages: [Damage], coords: CLLocationCoordinate2D, course: String) in
      guard self.onDamageDetected != nil else { return }
      guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
      
      var damageDicts = [[AnyHashable: Any]]()
      
      for damage in damages {
        damageDicts.append(damage.dictionary!)
      }
      
      self.onDamageDetected!(["location": ["latitude": coords.latitude, "longitude": coords.longitude],
                              "direction": course,
                              "damages": damageDicts,
                              "image": imageData.base64EncodedString()]);
    }
  }
  
  @objc(setOnDamageDetected:) // For react native to set the damage detected callback
  public func setOnDamageDetected(callback: @escaping RCTDirectEventBlock) {
    onDamageDetected = callback
  }

  @objc(setOnDownloadProgress:) // For react native to set the damage reported callback
  public func setOnDownloadProgress(callback: @escaping RCTDirectEventBlock) {
    onDownloadProgress = callback
  }
  
  @objc(setOnDownloadComplete:) // For react native to set the damage reported callback
  public func setOnDownloadComplete(callback: @escaping RCTDirectEventBlock) {
    onDownloadComplete = callback
  }
  
  @objc(setOnError:) // For react native to set the damage reported callback
  public func setOnError(callback: @escaping RCTDirectEventBlock) {
    onError = callback
  }
  
  @objc(setAuthToken:) // For react native to set the auth token
  public func setAuthToken(token: NSString) {
    mlmodelService = MLModelService(with: token as String)
    
    mlmodelService!.getModel(
      completion: { compiledUrl in
        self.damageDetector = DamageDetector(previewView: self, compiledUrl: compiledUrl)
        self.startDetecting()
      },
      progress: { progress in
        guard self.onDownloadProgress != nil else { return }
        self.onDownloadProgress!(["progress": progress])
      },
      error: { error in
        guard self.onError != nil else { return }
        self.onError!(["error": "Error retrieving the damage detection model"])
      }
    )
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


extension UIView {
  var parentViewController: UIViewController? {
    var parentResponder: UIResponder? = self
    while parentResponder != nil {
      parentResponder = parentResponder!.next
      if let viewController = parentResponder as? UIViewController {
        return viewController
      }
    }
    return nil
  }
}
