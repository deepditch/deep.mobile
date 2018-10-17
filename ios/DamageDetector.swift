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
import ARKit
import CoreLocation

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

class DamageDetector: NSObject, CLLocationManagerDelegate {
  var damageDetected: ((UIImage, [String], Double, Double) -> Void)?
  
  let manager = CLLocationManager()
  var hasMoved: Bool = true // First frame sent is processed
  var location: CLLocation?
  var lat: Double?
  var lng: Double?
  
  override init() {
    super.init()
    DispatchQueue.main.async {
      self.manager.requestWhenInUseAuthorization()
      self.manager.delegate = self
      self.manager.desiredAccuracy = kCLLocationAccuracyBest
      self.manager.startUpdatingLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard currentImage == nil else { return } // If an image is being processed, don't update the location
    guard manager.location != nil else { return }
    guard location != nil else {
      location = manager.location
      return
    }
    guard manager.location!.distance(from: location!) > 1 else { return } // Have we moved a meter
    
    location = manager.location!
    hasMoved = true
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("Error: \(error.localizedDescription)")
  }

  lazy var classificationRequest: VNCoreMLRequest = {
    do {
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
  
  // Image being held for analysis
  private var currentImage: UIImage?
  
  // Queue for dispatching vision classification requests
  private let visionQueue = DispatchQueue(label: "serial vision queue")
  
  // Detect road damage in an image
  func maybeDetect(for image: UIImage) {
    guard currentImage == nil, hasMoved else { // Disregard requests if the previous image is not finished or the device is stationary
      return
    }
    
    self.currentImage = image
    processCurrentImage()
  }
  
  func processCurrentImage() {
    let orientation = CGImagePropertyOrientation(self.currentImage!.imageOrientation)
    guard let ciImage = CIImage(image: self.currentImage!) else { fatalError("Unable to create \(CIImage.self) from \(String(describing: self.currentImage)).") }
    
    let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
    visionQueue.async { // Image processing happens in a separate queue
      do {
        try handler.perform([self.classificationRequest])
      } catch {
        print("Failed to perform classification.\n\(error.localizedDescription)")
      }
    }
  }

  /// Updates the UI with the results of the classification.
  /// - Tag: ProcessClassifications
  func processClassifications(for request: VNRequest, error: Error?) {
    DispatchQueue.main.async { [unowned self] in
      defer { // New frame will be processed when a new image is recieved, the location is updated, and the device is moving
        self.currentImage = nil
      //  self.hasMoved = false
      }
      
      guard let results = request.results else {
        print("Unable to classify image.\n\(error!.localizedDescription)")
        return
      }

      let classifications = results as! [VNCoreMLFeatureValueObservation]

      let obs : VNCoreMLFeatureValueObservation = (classifications.first)!
      let m: MLMultiArray = obs.featureValue.multiArrayValue!

      let types = self.mapOutputs(vec: m)
      
      if types.count > 0, self.currentImage != nil, self.location != nil { // Damage has been detected in the image
        self.damageDetected?(self.currentImage!, types, self.location!.coordinate.latitude, self.location!.coordinate.longitude)
      }
    }
  }
  
  func mapOutputs(vec: MLMultiArray) -> [String] {
    var arr = [String]()
    
    if(vec[0].doubleValue > 0.5) {
      arr.append("D00: Crack")
    }
    
    if(vec[1].doubleValue > 0.5) {
      arr.append("D01: Crack")
    }
    
    if(vec[2].doubleValue > 0.5) {
      arr.append("D10: Crack")
    }
    
    if(vec[3].doubleValue > 0.5) {
      arr.append("D11: Crack")
    }
    
    if(vec[4].doubleValue > 0.5) {
      arr.append("D20: Alligator Crack")
    }
    
    if(vec[5].doubleValue > 0.5) {
      arr.append("D40: Pothole")
    }
    
    if(vec[6].doubleValue > 0.5) {
      arr.append("D43: Line Blur")
    }
    
    if(vec[7].doubleValue > 0.5) {
      arr.append("D44: Crosswalk Blur")
    }
    
    return arr
  }
}

