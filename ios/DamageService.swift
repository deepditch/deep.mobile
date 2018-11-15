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
  var course: String
  var damages: [Damage]
  var confidence: Double
}

class DamageService {
  var apiProvider: MoyaProvider<APIHTTPService>!
  var reportToSend: DamageReport?
  var throttler: Throttler!
  
  init(with token: String) {
    throttler = Throttler(seconds: 7.5) // Reports are sent a maximum of 8 times per minute
    apiProvider = MakeApiProvider(with: token)
  }
  
  func maybeReport(image: UIImage, damages: [Damage], latitude: Double, longitude: Double, course: String, completion: @escaping Completion) {
    let highestConfidenceDamage = damages.max {a, b in a.confidence < b.confidence}
    
    if(reportToSend == nil || highestConfidenceDamage!.confidence > reportToSend!.confidence) {
      reportToSend = DamageReport(image: image,
                                  latitude: latitude,
                                  longitude: longitude,
                                  course: course,
                                  damages: damages,
                                  confidence: highestConfidenceDamage!.confidence)
      
      throttler.throttle {
        self.sendReport(completion: completion)
      }
    }
  }
  
  func sendReport(completion: @escaping Completion) {
    // Auth token has not been set yet
    guard reportToSend != nil, apiProvider != nil else { return }
    defer { reportToSend = nil }
    
    self.apiProvider.request(
    .report(reportToSend!.image,
            reportToSend!.latitude,
            reportToSend!.longitude,
            reportToSend!.course,
            reportToSend!.damages)) { result in
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
