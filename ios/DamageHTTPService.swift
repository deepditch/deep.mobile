//
//  DamageService.swift
//  deep.mobile
//
//  Created by Drake Svoboda on 10/10/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import Moya

enum DamageHTTPService {
  case report(_ image: UIImage, _ latitude: Double, _ longitude: Double, _ damages: [Damage])
}

extension DamageHTTPService: TargetType {
  var baseURL: URL { return URL(string: "http://216.126.231.155/api")! }
  var path: String {
    switch self {
    case .report:
      return "/road-damage/new"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .report:
      return .post
    }
  }
  
  var task: Task {
    switch self {
    case let .report(image, latitude, longitude, damages):
      guard let imageData = image.jpegData(compressionQuality: 1.0) else { return .requestPlain }
      
      var list = [[AnyHashable: Any]]()
      
      for damage in damages {
        list.append(damage.dictionary!)
      }
      
      let params = ["location": ["latitude": latitude, "longitude": longitude], "direction": "N", "damages": list, "image": imageData.base64EncodedString()] as [String : Any]
      
      return .requestParameters(parameters: params, encoding: JSONEncoding.default)
    }
  }
  
  var headers: [String: String]? {
    switch self {
    case .report:
      return ["Content-type": "application/json"]
    }
  }
  
  var sampleData: Data {
    return "There is No smaple Data".data(using: String.Encoding.utf8)!
  }
}
