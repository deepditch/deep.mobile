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

class DamageService {
  var apiProvider: MoyaProvider<APIHTTPService>?
  var reportToSend: DamageReport?
  var throttler: Throttler!
  
  var PreviousReports = ["D00": [CLLocation](),
                        "D01": [CLLocation](),
                        "D10": [CLLocation](),
                        "D11": [CLLocation](),
                        "D20": [CLLocation](),
                        "D40": [CLLocation](),
                        "D43": [CLLocation](),
                        "D44": [CLLocation]()]
  
  init() {
    throttler = Throttler(seconds: 7.5) // Reports are sent a maximum of 8 times per minute
  }
  
  func setToken(with token: String) {
    apiProvider = MakeApiProvider(with: token)
  }
  
  func setPreviousReports(with previousReports: [String: Any]) {
    for (key, reports) in previousReports {
      PreviousReports[key] = (reports as! [[Double]]).map { vals in return CLLocation(latitude: vals[0], longitude: vals[1])}
    }
  }
  
  func maybeReport(report: DamageReport, completion: @escaping Completion) -> DamageReport {
    var report = report
    
    // Report a damage if it has a confidence greater than .5 or we are within a 10 meter radius of a previously reported damage
    report.damages = report.damages.filter { damage in
      return damage.confidence >= 0.5 ||
        PreviousReports[damage.type]?.contains { location in
          return location.distance(from: report.position) < 10
        } ?? false
    }
    
    guard report.damages.count > 0 else { return report }
    
    if(reportToSend == nil || report.confidence > reportToSend!.confidence) {
      reportToSend = report
      throttler.throttle {
        self.sendReport(completion: completion)
      }
    }
    
    return report
  }
  
  func sendReport(completion: @escaping Completion) {
    // Auth token has not been set yet
    guard reportToSend != nil, apiProvider != nil else { return }
    defer { reportToSend = nil }
    
    self.apiProvider!.request(
    .report(report: reportToSend!)) { result in
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
