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
  case report(_ image: UIImage, _ latitude: Double, _ longitude: Double, _ course: String, _ damages: [Damage])
  case getModel()
}

class Config {
  let config: NSDictionary
  init() {
    let path: String = Bundle.main.path(forResource: "Info", ofType: "plist")!
    config = NSDictionary(contentsOfFile: path)!
  }
}

extension DamageHTTPService: TargetType {
  var baseURL: URL { return URL(string: Config().config.object(forKey: "API Base Path") as! String)! }
  var path: String {
    switch self {
    case .report:
      return "/road-damage/new"
    case .getModel:
      return "/machine-learning/latest-model"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .report:
      return .post
    case .getModel:
      return .get
    }
  }
  
  var task: Task {
    switch self {
    case let .report(image, latitude, longitude, course, damages):
      guard let imageData = image.jpegData(compressionQuality: 1.0) else { return .requestPlain }
      
      var damageDicts = [[AnyHashable: Any]]()
      
      for damage in damages {
        damageDicts.append(damage.dictionary!)
      }
      
      let params = ["location": ["latitude": latitude, "longitude": longitude],
                    "direction": course,
                    "damages": damageDicts,
                    "image": imageData.base64EncodedString()] as [String : Any]
      
      return .requestParameters(parameters: params, encoding: JSONEncoding.default)
    case .getModel:
      return .requestPlain
    }
  }
  
  var headers: [String: String]? {
    switch self {
    case .report:
      return ["Content-type": "application/json"]
    case .getModel():
      return ["Content-type": "application/json"]
    }

  }
  
  var sampleData: Data {
    return "There is No smaple Data".data(using: String.Encoding.utf8)!
  }
}
