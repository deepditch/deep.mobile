//
//  RoadDamageService_Tests.swift
//  deep.mobileTests
//
//  Created by Drake Svoboda on 11/25/18.
//  Copyright © 2018 Facebook. All rights reserved.
//
import XCTest
import Moya
import CoreLocation

class TokenSource { // Stub
  func get() -> String?{
    return ""
  }
  
  func set(with token: String) {
    
  }
}

class RoadDamageService_Tests: XCTestCase {
  var damageService: DamageService?
  var callCount: Int?
  var completion: Completion?
  
  override func setUp() {
    damageService = DamageService()
    damageService!.apiProvider = MoyaProvider<APIHTTPService>(stubClosure: MoyaProvider.immediatelyStub)
    callCount = 0
    completion = { result in self.callCount! += 1 }
  }
  
  override func tearDown() {
    callCount = 0
  }
  
  func testRoadDamageReporting() {
    let report1 = DamageReport(image: UIImage(),
                               position: CLLocation(latitude: 0, longitude: 0),
                               course: "N",
                               damages: [Damage(type: "D01", description: "asdf", confidence: 0.8)],
                               confidence: 0.8)
    
    let report2 = DamageReport(image: UIImage(),
                               position: CLLocation(latitude: 0, longitude: 0),
                               course: "N",
                               damages: [Damage(type: "D01", description: "asdf", confidence: 0.2)],
                               confidence: 0.2)
    
    let report3 = DamageReport(image: UIImage(),
                               position: CLLocation(latitude: 0, longitude: 0),
                               course: "N",
                               damages: [Damage(type: "D01", description: "asdf", confidence: 0.5)],
                               confidence: 0.5)
    
    let report4 = DamageReport(image: UIImage(),
                               position: CLLocation(latitude: 0, longitude: 0),
                               course: "N",
                               damages: [Damage(type: "D01", description: "asdf", confidence: 0.9)],
                               confidence: 0.9)
    
    damageService!.maybeReport(report: report1, completion: self.completion!)
    damageService!.maybeReport(report: report2, completion: self.completion!)
    damageService!.maybeReport(report: report3, completion: self.completion!)
    damageService!.maybeReport(report: report4, completion: self.completion!)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15)) {
      XCTAssertTrue(self.callCount == 1) // Reporting is throttled so the completion handler should only be called 1 time
    }
  }
}
