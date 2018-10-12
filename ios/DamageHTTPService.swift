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
  case report(_ image: UIImage, _ latitude: Double, _ longitude: Double)
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
    case let .report(image, latitude, longitude):
      guard let imageData = image.jpegData(compressionQuality: 1.0) else { return .requestPlain }
      let timestamp = String(Date().timeIntervalSince1970)
      let data = [MultipartFormData(provider: .data(imageData), name: "image", fileName: timestamp + ".jpg", mimeType:"image/jpeg")]
      let params = ["latitude": latitude, "longitude": longitude]
      return .uploadCompositeMultipart(data, urlParameters: params)
    }
  }
  
  var headers: [String: String]? {
    switch self {
    case .report:
      return ["Content-type": "multipart/form-data;"]
    }
  }
  
  var sampleData: Data {
    return "There is No smaple Data".data(using: String.Encoding.utf8)!
  }
}
