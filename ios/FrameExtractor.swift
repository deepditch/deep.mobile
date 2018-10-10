//
//  FrameExtractor.swift
//  Uses the devices camera and makes real time frames availible for processing
//
//

import AVFoundation
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

class FrameExtractor : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
  private let captureSession = AVCaptureSession()
  private let sessionQueue = DispatchQueue(label: "session queue")
  private var cameraPermissionGranted = false
  private let position = AVCaptureDevice.Position.back
  private let quality = AVCaptureSession.Preset.medium
  private let context = CIContext()
  var damageDetected: ((MLMultiArray?) -> Void)?
  var frameCaptured: ((UIImage?) -> Void)?
  private var throttler: Throttler!
  
  
  override init() {
    print("init")
    super.init()
    checkPermission()
    throttler = Throttler(seconds: 0.25)
    sessionQueue.async { [unowned self] in // sessionQueue might be suspended after checkPermission. unowned self prevents a possible retain cycle.
      self.configureSession()
      self.captureSession.startRunning() // Session is started on the sessionQueue, frames are processed on a separate queue
    }
  }
  
  // MARK: AVSession configuration
  private func checkPermission() {
    switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
    case .authorized:
      cameraPermissionGranted = true
      break
    case .notDetermined:
      requestPermission()
      break
    default:
      cameraPermissionGranted = false
      break
    }
  }
  
  private func requestPermission() {
    sessionQueue.suspend() // AVCaptureDevice.requestAccess is async, so we suspend and wait for a response from the user
    AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] granted in
      self.cameraPermissionGranted = granted
      self.sessionQueue.resume() // Resume our queue once we have a response
    }
  }
  
  private func configureSession() {
    guard cameraPermissionGranted else { return }
    captureSession.sessionPreset = quality
    guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: position) else { return }
    guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
    guard captureSession.canAddInput(captureDeviceInput) else { return }
    captureSession.addInput(captureDeviceInput)
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer")) // Self is an AVCaptureVideoDataOutputSampleBufferDelegate, frames are processed on a different queue to avoid pile up
    guard captureSession.canAddOutput(videoOutput) else { return }
    captureSession.addOutput(videoOutput)
    guard let connection = videoOutput.connection(with: AVFoundation.AVMediaType.video) else { return }
    guard connection.isVideoOrientationSupported else { return }
    guard connection.isVideoMirroringSupported else { return }
    connection.videoOrientation = .portrait
    connection.isVideoMirrored = position == .front
  }
  
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    let ciImage = CIImage(cvPixelBuffer: imageBuffer)
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { fatalError("Unable to create \(CGImage.self) from \(ciImage).")  }
    let uiImage = UIImage(cgImage: cgImage)
    let orientation = CGImagePropertyOrientation(uiImage.imageOrientation)

    throttler.throttle(block: { [unowned self] in
      let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
      do {
        try handler.perform([self.classificationRequest])
      } catch {
        print("Failed to perform classification.\n\(error.localizedDescription)")
      }
    }, queue: DispatchQueue.global(qos: .userInitiated))
    
    DispatchQueue.main.async { [unowned self] in // Image is sent to the delegate on the main thread.
      self.frameCaptured?(uiImage)
    }
  }
  
  /// Updates the UI with the results of the classification.
  /// - Tag: ProcessClassifications
  func processClassifications(for request: VNRequest, error: Error?) {
    DispatchQueue.main.async { [unowned self] in
      guard let results = request.results else {
        print("Unable to classify image.\n\(error!.localizedDescription)")
        return
      }
      
      let classifications = results as! [VNCoreMLFeatureValueObservation]
      
      let obs : VNCoreMLFeatureValueObservation = (classifications.first)!
      let m: MLMultiArray = obs.featureValue.multiArrayValue!
      
      self.damageDetected?(m)
    }
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
}
