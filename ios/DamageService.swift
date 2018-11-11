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

struct MLModelResponse : Decodable {
  let url: String?
}

class DamageService {
  var damageProvider: MoyaProvider<DamageHTTPService>?
  var reportToSend: DamageReport?
  var throttler: Throttler!
  
  init() {
    throttler = Throttler(seconds: 7.5) // Reports are sent a maximum of once per 15 seconds
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
  
  func getModel(completion: @escaping (String?) -> Void) {
    self.damageProvider!.request(.getModel()) { result in
      switch result {
      case let .success(response):
        do {
          let filteredResponse = try response.filterSuccessfulStatusCodes()
          let resonseData = try filteredResponse.map(MLModelResponse.self) // user is of type User
          completion(resonseData.url)
        } catch let error {
          
        }
      case let .failure(error): // Server did not recieve request, or server did not send response
        print(error)
      }
    }
  }
  
  func maybeReport(image: UIImage, damages: [Damage], latitude: Double, longitude: Double, course: String, completion: @escaping Completion) {
    let sizedImage = ScaleImage(image: image, size: CGSize(width: 300, height: 300))
    let highestConfidenceDamage = damages.max {a, b in a.confidence < b.confidence}
    
    if(reportToSend == nil || highestConfidenceDamage!.confidence > reportToSend!.confidence) {
      reportToSend = DamageReport(image: sizedImage,
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
    guard reportToSend != nil, damageProvider != nil else { return }
    defer { reportToSend = nil }
    
    self.damageProvider!.request(
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
