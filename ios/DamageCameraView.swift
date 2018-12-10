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
  }
  
  //override func layoutSubviews() {
   // super.layoutSubviews()
   // guard damageDetector != nil else { return }
   // damageDetector?.previewView.frame = bounds
  //}
  
  func startDetecting() {
    self.damageDetector!.damageDetected = { [unowned self] report in
      let report = self.damageService.maybeReport(report: report) { result in
        if(self.onDamageReported != nil) {
          switch result {
          case let .success(response):
            let data = response.data
            let statusCode = response.statusCode
            
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
        
        for damage in report.damages {
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
  
  @objc(setPreviousReports:) // For react native to set the auth token
  public func setPreviousReports(previousReports: NSDictionary) {
    damageService.setPreviousReports(with: previousReports as! [String: Any])
  }
  
  @objc(setAuthToken:) // For react native to set the auth token
  public func setAuthToken(token: NSString) {
    damageService.setToken(with: token as String)
    DispatchQueue.global(qos: .background).async { [unowned self] in
      MLModelService(with: token as String).getModel(
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
