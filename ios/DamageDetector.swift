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
  var damageDetected: ((DamageReport) -> Void)?
  
  var locationManager: CLLocationManager!
  var location: CLLocation?
  var hasMoved: Bool = false
  
  var roadDamageModel: RoadDamageModel!
  
  init(previewView: UIView, compiledUrl: URL) {
    super.init(previewView: previewView)
    
    do {
      roadDamageModel = try RoadDamageModel(contentsOf: compiledUrl)
    } catch {
    
    }
  }
  
  override func setupAVCapture() {
    DispatchQueue.main.async {
      super.setupAVCapture()
      self.setupGPS()
      self.startCaptureSession()
    }
  }
  
  func setupGPS() {
    self.locationManager = CLLocationManager()
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.activityType = .automotiveNavigation
    self.locationManager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard currentImage == nil, manager.location != nil else { return } // If an image is being processed, don't update the location

    if location == nil || manager.location!.distance(from: location!) > 10 {
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
  
  private var currentImage: UIImage?
  
  private let visionQueue = DispatchQueue(label: "com.deep.ditch.visionqueue")
  
  private let context = CIContext()
  
  func fixOrientation(for img: UIImage) -> UIImage {
    if (img.imageOrientation == .up) {
      return img
    }
    
    UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
    let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
    img.draw(in: rect)
    
    let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    return normalizedImage
  }
  
  private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
    let ciImage = CIImage(cvPixelBuffer: imageBuffer)
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
    let img = UIImage(cgImage: cgImage, scale: 1, orientation: UIImageOrientationFromDeviceOrientation())
    return fixOrientation(for: img)
  }
  
  override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard self.currentImage == nil, self.hasMoved else { return }
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    
    self.currentImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer)
    guard self.currentImage != nil else { return }
    
    let exifOrientation = exifOrientationFromDeviceOrientation()
    
    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
    
    do {
      try imageRequestHandler.perform([self.classificationRequest])
    } catch {
      print(error)
    }
  }

  let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"]
  
  /// Updates the UI with the results of the classification.
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
    
    if damages.count > 0 { // Damage has been detected in the image
      let heading = self.directions[Int((Float(Int(self.location!.course) % 360) / 45).rounded())]
      let highestConfidenceDamage = damages.max {a, b in a.confidence < b.confidence}
      let report = DamageReport(image: self.currentImage!,
                                position: self.location!,
                                course: heading,
                                damages: damages,
                                confidence: highestConfidenceDamage!.confidence)
      
      self.damageDetected?(report)
    }
  }
  
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
  
  public func UIImageOrientationFromDeviceOrientation() -> UIImage.Orientation {
    let curDeviceOrientation = UIDevice.current.orientation
    let exifOrientation: UIImage.Orientation
    
    switch curDeviceOrientation {
    case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
      exifOrientation = .left
    case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
      exifOrientation = .up
    case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
      exifOrientation = .right
    case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
      exifOrientation = .down
    default:
      exifOrientation = .up
    }
    return exifOrientation
  }
}

