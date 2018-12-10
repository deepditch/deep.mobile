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
  var onDamageReported: RCTDirectEventBlock?
  var onDownloadProgress: RCTDirectEventBlock?
  var onDownloadComplete: RCTDirectEventBlock?
  var onError: RCTDirectEventBlock?
  var damageService: DamageService 
  var damageDetector: DamageDetector?
  
  override init(frame: CGRect) {
    damageService = DamageService()
    super.init(frame: frame)
    
    DispatchQueue.global(qos: .background).async { [unowned self] in // Download and initialize the machine learning model on a background queue as to not block the ui thread
      MLModelService().getModel(
        completion: { modelUrl in
          self.damageDetector = DamageDetector(previewView: self, model: modelUrl) // Initialize the DamageDetector with a model. self displays preview frames from the camera
          self.configureDetection()
        },
        progress: { progress in
          guard self.onDownloadProgress != nil else { return }
          self.onDownloadProgress!(["progress": progress]) // Send download progress to the React Native layer
        },
        errorHandler: { error in
          guard self.onError != nil else { return }
          self.onError!(["error": "Error retrieving the damage detection model"]) // Send error the the React Native layer
        }
      )
    }
  }
  
  func configureDetection() { // Attatch a callback for when damage is detected by the damageDetector
    guard self.damageDetector != nil else { return }
    
    self.damageDetector!.damageDetected = { [unowned self] report in
      let report = self.damageService.maybeReport(report: report) { result in
        guard (self.onDamageReported != nil) else { return } // Check to see if React Native has set the callback yet
        
        switch result {
        case let .success(response): // We got a response from the server, however, this may be an error response
          let data = response.data
          let statusCode = response.statusCode
          self.onDamageReported!(["data": data, "status": statusCode]); // Send response to the React Native layer
          
        case let .failure(error): // Server did not recieve request, or server did not send response
          self.onDamageReported!(["status": "err"]); // Send an error to the React Native layer
        }
      }
      
      guard self.onDamageDetected != nil else { return } // Check to see if React Native has set the callback yet
   
      // Serialize and send the report to the React Native layer
      var list = [[AnyHashable: Any]]()
      
      for damage in report.damages {
        list.append(damage.dictionary!)
      }
      
      self.onDamageDetected!(["damages": list]);
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

  @objc(setOnDownloadProgress:) // For react native to set the download progress callback
  public func setOnDownloadProgress(callback: @escaping RCTDirectEventBlock) {
    onDownloadProgress = callback
  }

  @objc(setOnDownloadComplete:) // For react native to set the download completed callback
  public func setOnDownloadComplete(callback: @escaping RCTDirectEventBlock) {
    onDownloadComplete = callback
  }
  
  @objc(setOnError:) // For react native to set the damage reported callback
  public func setOnError(callback: @escaping RCTDirectEventBlock) {
    onError = callback
  }

  @objc(setPreviousReports:) // For react native to set the auth token
  public func setPreviousReports(previousReports: NSDictionary) {
    damageService.setPreviousReports(with: previousReports as! [String: Any])
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    guard self.damageDetector != nil else { return }
    self.damageDetector!.configureVideoOrientation()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

