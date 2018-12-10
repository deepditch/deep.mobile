
//
//  deep_mobileTests.swift
//  deep.mobileTests
//
//  Created by Drake Svoboda on 11/25/18.
//  Copyright © 2018 Facebook. All rights reserved.
//
import XCTest
import UIKit
import CoreML
import Vision
import ARKit
import CoreLocation

class RoadDamageModel_Tests: XCTestCase {
  var image: URL? = nil
  var detector: DamageDetector?
  var completionWasCalled: Bool = false
  
  override func setUp() {
    let bundle = Bundle(for:type(of:self))
    
    image = URL(fileURLWithPath: bundle.path(forResource: "test_image", ofType: "png")!)
    
    do {
      let model_file = URL(fileURLWithPath: bundle.path(forResource: "RoadDamageModel", ofType: "mlmodelc")!)
      detector = DamageDetector(previewView: UIView(), model: model_file)
    } catch { fatalError("fail") }
    
    detector?.damageDetected = { report in
      self.completionWasCalled = true
    }
  }
  
  override func tearDown() {
    detector = nil
  }
  
  func makeBuffer(from image: UIImage) -> CVPixelBuffer? {
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
    var pixelBuffer : CVPixelBuffer?
    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
    guard (status == kCVReturnSuccess) else {
      return nil
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
    
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
    
    context?.translateBy(x: 0, y: image.size.height)
    context?.scaleBy(x: 1.0, y: -1.0)
    
    UIGraphicsPushContext(context!)
    image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
    UIGraphicsPopContext()
    CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    
    return pixelBuffer
  }
  
  func testModelInference() {
    guard let image = UIImage(contentsOfFile: self.image!.path) else { fatalError("fail") }
    guard let buffer = makeBuffer(from: image) else { fatalError("fail") }
    
    detector!.inferenceImage(pixelBuffer: buffer)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
      XCTAssertTrue(self.completionWasCalled) // The model should have finished processing within a second
    }
  }
  
  func myResultsMethod(request: VNRequest, error: Error?) {
    guard let results = request.results as? [VNClassificationObservation]
      else { fatalError("fail") }
  }
}
