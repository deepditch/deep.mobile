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

struct Damage: Codable {
  var type: String
  var description: String
  var confidence: Double
}

extension Damage {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}

class DamageDetector: NSObject, CLLocationManagerDelegate {
  var damageDetected: ((_ image: UIImage, _ damages: [Damage], _ coords: CLLocationCoordinate2D, _ course: String) -> Void)?
  let manager = CLLocationManager()
  var hasMoved: Bool = false
  var location: CLLocation?
  var roadDamageModel: RoadDamageModel!
  
  init(compiledUrl: URL) {
    super.init()
    DispatchQueue.main.async {
      self.manager.requestWhenInUseAuthorization()
      self.manager.delegate = self
      self.manager.desiredAccuracy = kCLLocationAccuracyBest
      self.manager.activityType = .automotiveNavigation
      self.manager.startUpdatingLocation()
    }
    
    do {
      roadDamageModel = try RoadDamageModel(contentsOf: compiledUrl)
    } catch {
    
    }

  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard currentImage == nil, manager.location != nil else { return } // If an image is being processed, don't update the location

    if location == nil || manager.location!.distance(from: location!) > 1 {
      // We have moved a meter
      location = manager.location!
      hasMoved = true
    }
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("Error: \(error.localizedDescription)")
  }

  lazy var classificationRequest: VNCoreMLRequest = {
    do {
      let model = try VNCoreMLModel(for: roadDamageModel.model)

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
  private let visionQueue = DispatchQueue(label: "com.deep.ditch.visionqueue")
  
  // Detect road damage in an image. image is dropped if the device has not moved or an image is currently being processed
  func maybeDetect(for image: UIImage) {
    guard currentImage == nil, hasMoved else { return } // Drop requests if the previous image is not finished or the device is stationary
    self.currentImage = image
    processCurrentImage()
  }
  
  func processCurrentImage() {
    let orientation = CGImagePropertyOrientation(self.currentImage!.imageOrientation)
    
    guard let ciImage = CIImage(image: self.currentImage!) else {
      fatalError("Unable to create \(CIImage.self) from \(String(describing: self.currentImage)).")
    }
    
    let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
    
    visionQueue.async { // Image processing happens in a separate queue
      do {
        try handler.perform([self.classificationRequest])
      } catch {
        print("Failed to perform classification.\n\(error.localizedDescription)")
      }
    }
  }

  let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
  
  /// Updates the UI with the results of the classification.
  /// - Tag: ProcessClassifications
  func processClassifications(for request: VNRequest, error: Error?) {
    DispatchQueue.main.async { [unowned self] in
      defer { // Executed after function return.
        // New frame will be processed when a new image is recieved and the device has moved
        self.currentImage = nil
        self.hasMoved = false
      }
      
      guard self.currentImage != nil, self.location != nil else {
        print("The image or location was lost somehow")
        return
      }
      
      guard let results = request.results else {
        print("Unable to classify image.\n\(error!.localizedDescription)")
        return
      }

      let classifications = results as! [VNCoreMLFeatureValueObservation]
      let obs: VNCoreMLFeatureValueObservation = (classifications.first)!
      let outputs: MLMultiArray = obs.featureValue.multiArrayValue!
      let damages: [Damage] = self.mapOutputsToDamages(for: outputs)
      
      if damages.count > 0 { // Damage has been detected in the image
        let heading = self.directions[Int((self.location!.course / 45).rounded()) % 8]
        self.damageDetected?(self.currentImage!, damages, self.location!.coordinate, heading)
      }
    }
  }
  
  func mapOutputsToDamages(for outputs: MLMultiArray) -> [Damage] {
    var damages = [Damage]()
    
    if(outputs[0].doubleValue > 0.5) {
      damages.append(Damage(type: "D00",
                        description: "Crack",
                        confidence: outputs[0].doubleValue))
    }
    
    if(outputs[1].doubleValue > 0.5) {
      damages.append(Damage(type: "D01",
                        description: "Crack",
                        confidence: outputs[1].doubleValue))
    }
    
    if(outputs[2].doubleValue > 0.5) {
      damages.append(Damage(type: "D10",
                        description:"Crack",
                        confidence: outputs[2].doubleValue))
    }
    
    if(outputs[3].doubleValue > 0.5) {
      damages.append(Damage(type: "D11",
                        description: "Crack",
                        confidence: outputs[3].doubleValue))
    }
    
    if(outputs[4].doubleValue > 0.5) {
      damages.append(Damage(type: "D20",
                        description: "Alligator Crack",
                        confidence: outputs[4].doubleValue))
    }
    
    if(outputs[5].doubleValue > 0.5) {
      damages.append(Damage(type: "D40",
                        description: "Pothole",
                        confidence: outputs[5].doubleValue))
    }
    
    if(outputs[6].doubleValue > 0.5) {
      damages.append(Damage(type: "D43",
                        description: "Line Blur",
                        confidence: outputs[6].doubleValue))
    }
    
    if(outputs[7].doubleValue > 0.5) {
      damages.append(Damage(type: "D44",
                        description: "Crosswalk Blur",
                        confidence: outputs[7].doubleValue))
    }
    
    return damages
  }
}

