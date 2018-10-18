//
//  DamageService.swift
//  deep.mobile
//
//  Created by Drake Svoboda on 10/11/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import Moya

func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
  UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
  image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
  let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
  UIGraphicsEndImageContext()
  return newImage
}

class DamageService {
  var damageProvider: MoyaProvider<DamageHTTPService>?
  
  init() { }
  
  func setAuthToken(with token: String) {
    let authMiddleware = { (target: DamageHTTPService) -> Endpoint in
      let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
      return defaultEndpoint.adding(newHTTPHeaderFields: ["authorization": "Bearer " + token])
    }
    
    self.damageProvider = MoyaProvider(endpointClosure: authMiddleware)
  }
  
  func maybeReport(image: UIImage, types: [String], latitude: Double, longitude: Double, completion: @escaping Completion) {
    guard damageProvider != nil else { return }
    let sizedImage = imageWithImage(image: image, scaledToSize: CGSize(width: 300, height: 300))
    self.damageProvider!.request(.report(sizedImage, latitude, longitude)) { result in
      switch result {
      case let .success(response):
        let data = response.data // Data, your JSON response is probably in here!
        let statusCode = response.statusCode // Int - 200, 401, 500, etc
        print(statusCode, data)
        
      case let .failure(error): // Server did not recieve request, or server did not send response
        print(error)
      }
      
      completion(result)
    }
  }
}
