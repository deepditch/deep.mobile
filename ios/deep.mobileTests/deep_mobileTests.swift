//
//  deep_mobileTests.swift
//  deep.mobileTests
//
//  Created by Drake Svoboda on 11/25/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import XCTest

class RoadDamageModel_Tests: XCTestCase {
  var pixelBuffer : CVPixelBuffer? = nil

  override func setUp() {
    var pixelBuffer: UnsafeMutablePointer<CVPixelBuffer?>!
    if pixelBuffer == nil {
      pixelBuffer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: MemoryLayout<CVPixelBuffer?>.size)
    }
    CVPixelBufferCreate(kCFAllocatorDefault, 224, 224, kCVPixelFormatType_32RGBA, attributes, pixelBuffer)
  }

  override func tearDown() {
  }

  func testModelInference() {
    lazy var classificationRequest: VNCoreMLRequest = {
      do {
        let model = try VNCoreMLModel(for: RoadDamageModel().model)
        
        let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
          DispatchQueue.main.async { [weak self] in
            self?.processClassifications(for: request, error: error)
          }
        })
        
        request.imageCropAndScaleOption = .centerCrop
        
        return request
      } catch {
        fatalError("Failed to load Vision ML model: \(error)")
      }
    }()
    
    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
    
    try imageRequestHandler.perform([self.classificationRequest])
  }

  func testModelPerformance() {
    self.measure {
      return true
    }
  }
}
