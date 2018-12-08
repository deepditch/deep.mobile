//
//  DamageService.swift
//  deep.mobile
//
//  Created by Drake Svoboda on 10/10/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import Moya
import Result

enum APIHTTPService {
  case report(report: DamageReport)
  case getModel()
}

class Config {
  let config: NSDictionary
  init() {
    let path: String = Bundle.main.path(forResource: "Info", ofType: "plist")!
    config = NSDictionary(contentsOfFile: path)!
  }
}

extension APIHTTPService: TargetType {
  var baseURL: URL { return URL(string: Config().config.object(forKey: "API Base Path") as! String)! }
  var path: String {
    switch self {
    case .report:
      return "/road-damage/new"
    case .getModel:
      return "/machine-learning/get-latest"
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
    case let .report(report):
      guard let imageData = report.image.jpegData(compressionQuality: 1.0) else { return .requestPlain }
      
      var damageDicts = [[AnyHashable: Any]]()
      
      for damage in report.damages {
        damageDicts.append(damage.dictionary!)
      }
      
      let params = ["location": ["latitude": report.position.coordinate.latitude,
                                 "longitude": report.position.coordinate.longitude],
                    "direction": report.course,
                    "damages": damageDicts,
                    "image": imageData.base64EncodedString()] as [String: Any]
      
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
    return "There is no sample Data".data(using: String.Encoding.utf8)!
  }
}

struct JWTPlugin: PluginType {
  let getToken: () -> String?
  let setToken: (String) -> Void
  
  func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
    guard let token = getToken() else { return request }
    
    var request = request
    request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
    return request
  }
  
  func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
    switch result {
    case .success(let response):
      let urlResponse = response.response as! HTTPURLResponse
      guard let token = urlResponse.allHeaderFields["Authorization"] as? String else { return }
      
      var trimmedToken = token
      
      if token.hasPrefix("Bearer ") {
        trimmedToken = String(token.dropFirst("Bearer ".count))
      }
      
      setToken(trimmedToken)
      
    default: return
    }
  }
}


func MakeApiProvider() -> MoyaProvider<APIHTTPService> {
  // Initialize moya provider
  let tokenSource = TokenSource()
  return MoyaProvider<APIHTTPService>(plugins: [ JWTPlugin(getToken: { return tokenSource.get() },
                                                           setToken: { token in tokenSource.set(with: token) }) ])
}
