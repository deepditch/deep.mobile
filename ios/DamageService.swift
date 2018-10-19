//
//  DamageService.swift
//  deep.mobile
//
//  Created by Drake Svoboda on 10/11/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import Moya

func ScaleImage(image: UIImage, size: CGSize) -> UIImage {
  UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
  image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: size.width, height: size.height)))
  let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
  UIGraphicsEndImageContext()
  return newImage
}

struct DamageReport {
  var image: UIImage
  var latitude: Double
  var longitude: Double
  var damages: [Damage]
  var confidence: Double
}

class DamageService {
  var damageProvider: MoyaProvider<DamageHTTPService>?
  var reportToSend: DamageReport?
  var throttler: Throttler!
  
  init() {
    throttler = Throttler(seconds: 15) // Reports are sent a maximum of once per 15 seconds
  }
  
  func setAuthToken(with token: String) {
    // Attach JWT to each request
    let authMiddleware = { (target: DamageHTTPService) -> Endpoint in
      let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
      return defaultEndpoint.adding(newHTTPHeaderFields: ["authorization": "Bearer " + token])
    }
    
    // Initialize moya provider
    self.damageProvider = MoyaProvider(endpointClosure: authMiddleware)
  }
  
  func maybeReport(image: UIImage, damages: [Damage], latitude: Double, longitude: Double, completion: @escaping Completion) {
    let sizedImage = ScaleImage(image: image, size: CGSize(width: 300, height: 300))
    let highestConfidenceDamage = damages.max {a, b in a.confidence < b.confidence}
    
    if(reportToSend == nil || highestConfidenceDamage!.confidence > reportToSend!.confidence) {
      reportToSend = DamageReport(image: sizedImage, latitude: latitude, longitude: longitude, damages: damages, confidence: highestConfidenceDamage!.confidence)
      
      throttler.throttle { [unowned self] in
        self.sendReport(completion: completion)
      }
    }
  }
  
  func sendReport(completion: @escaping Completion) {
    // Auth token has not been set yet
    guard reportToSend != nil, damageProvider != nil else { return }
    defer { reportToSend = nil }
    
    self.damageProvider!.request(.report(reportToSend!.image, reportToSend!.latitude, reportToSend!.longitude)) { result in
      switch result {
      case let .success(response):
        let data = response.data
        let statusCode = response.statusCode
        print(statusCode, data)
        
      case let .failure(error): // Server did not recieve request, or server did not send response
        print(error)
      }
      
      completion(result)
    }
  }
}
