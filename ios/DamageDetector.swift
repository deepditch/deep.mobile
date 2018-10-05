//
//  DamageDetector.swift
//  deep.mobile
//
//  Created by Drake Svoboda on 10/5/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ImageIO

extension CGImagePropertyOrientation {
  /**
   Converts a `UIImageOrientation` to a corresponding
   `CGImagePropertyOrientation`. The cases for each
   orientation are represented by different raw values.
   
   - Tag: ConvertOrientation
   */
  init(_ orientation: UIImage.Orientation) {
    switch orientation {
    case .up: self = .up
    case .upMirrored: self = .upMirrored
    case .down: self = .down
    case .downMirrored: self = .downMirrored
    case .left: self = .left
    case .leftMirrored: self = .leftMirrored
    case .right: self = .right
    case .rightMirrored: self = .rightMirrored
    }
  }
}

class DamageDetector {
  lazy var classificationRequest: VNCoreMLRequest = {
    do {
      /*
       Use the Swift class `MobileNet` Core ML generates from the model.
       To use a different Core ML classifier model, add it to the project
       and replace `MobileNet` with that model's generated Swift class.
       */
      let model = try VNCoreMLModel(for: RoadDamageModel().model)
      
      let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
        self?.processClassifications(for: request, error: error)
      })
      
      request.imageCropAndScaleOption = .centerCrop
      
      return request
    } catch {
      fatalError("Failed to load Vision ML model: \(error)")
    }
  }()
  
  func detect(for image: UIImage) {
    let orientation = CGImagePropertyOrientation(image.imageOrientation)
    guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
    
    DispatchQueue.global(qos: .userInitiated).async {
      let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
      do {
        try handler.perform([self.classificationRequest])
      } catch {
        /*
         This handler catches general image processing errors. The `classificationRequest`'s
         completion handler `processClassifications(_:error:)` catches errors specific
         to processing that request.
         */
        print("Failed to perform classification.\n\(error.localizedDescription)")
      }
    }
  }
  
  /// Updates the UI with the results of the classification.
  /// - Tag: ProcessClassifications
  func processClassifications(for request: VNRequest, error: Error?) {
    DispatchQueue.main.async {
      guard let results = request.results else {
        print("Unable to classify image.\n\(error!.localizedDescription)")
        return
      }
      
      print("frame")
    }
  }
}