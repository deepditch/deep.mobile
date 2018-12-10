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

struct DamageReport {
  var image: UIImage
  var position: CLLocation
  var course: String
  var damages: [Damage]
  var confidence: Double
}

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

class DamageDetector: FrameExtractor, CLLocationManagerDelegate {
  private var roadDamageModel: RoadDamageModel!
  private var currentImage: UIImage?
  var damageDetected: ((DamageReport) -> Void)?
  
  private let imageHelper = ImageHelper()
  
  var locationManager: CLLocationManager!
  var location: CLLocation?
  var hasMoved: Bool = false
  
  init(previewView: UIView, model compiledModel: URL) {
    super.init(previewView: previewView)
    
    do {
      roadDamageModel = try RoadDamageModel(contentsOf: compiledModel)
    } catch { }
  }
  
  override func setupAVCapture() {
    DispatchQueue.main.async {
      super.setupAVCapture()
      self.setupGPS()
      self.startCaptureSession()
    }
  }
  
  // Setup location services
  func setupGPS() {
    self.locationManager = CLLocationManager()
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.activityType = .automotiveNavigation
    self.locationManager.startUpdatingLocation()
  }
  
  // Called on a location update
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard currentImage == nil, manager.location != nil else { return } // If an image is being processed, don't update the location

    if location == nil || manager.location!.distance(from: location!) > 10 {
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
  
  // The camera has captured a new frame
  override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    self.inferenceImage(pixelBuffer: buffer)
  }
  
  func inferenceImage(pixelBuffer: CVPixelBuffer) {
    guard self.currentImage == nil, self.hasMoved else { return } // We only process a new frame once the old frame has finished and we have recieved a location update
    
    // Set up a classification request
    self.currentImage = imageHelper.imageFromBuffer(imageBuffer: pixelBuffer)
    guard self.currentImage != nil else { return }
    
    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientationFromDeviceOrientation(), options: [:])
    
    do {
      // Attempt to process the request
      try imageRequestHandler.perform([self.classificationRequest])
    } catch {
      print(error)
    }
  }
  
  /// Called when self.classificaitonRequests is completed
  /// - Tag: ProcessClassifications
  func processClassifications(for request: VNRequest, error: Error?) {
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
    
    let heading = self.mapCourseToHeadingString(for: self.location!.course)
    
    let highestConfidenceDamage = damages.max {a, b in a.confidence < b.confidence}
    
    let report = DamageReport(image: self.currentImage!,
                              position: self.location!,
                              course: heading,
                              damages: damages,
                              confidence: highestConfidenceDamage!.confidence)
    
    self.damageDetected?(report)
  }
  
  let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"]
  
  // Maps a degree measure to its compass direction
  func mapCourseToHeadingString(for course: Double) -> String {
    return self.directions[Int((Float(Int(course) % 360) / 45).rounded())]
  }
  
  // Maps the models outputs to a list of Damages
  func mapOutputsToDamages(for outputs: MLMultiArray) -> [Damage] {
    var damages = [Damage]()
    
      damages.append(Damage(type: "D00",
                        description: "Crack",
                        confidence: outputs[0].doubleValue))

      damages.append(Damage(type: "D01",
                        description: "Crack",
                        confidence: outputs[1].doubleValue))
    
      damages.append(Damage(type: "D10",
                        description:"Crack",
                        confidence: outputs[2].doubleValue))
    
      damages.append(Damage(type: "D11",
                        description: "Crack",
                        confidence: outputs[3].doubleValue))

      damages.append(Damage(type: "D20",
                        description: "Alligator Crack",
                        confidence: outputs[4].doubleValue))

      damages.append(Damage(type: "D40",
                        description: "Pothole",
                        confidence: outputs[5].doubleValue))
    
      damages.append(Damage(type: "D43",
                        description: "Line Blur",
                        confidence: outputs[6].doubleValue))
    
      damages.append(Damage(type: "D44",
                        description: "Crosswalk Blur",
                        confidence: outputs[7].doubleValue))
    
    return damages
  }
}

